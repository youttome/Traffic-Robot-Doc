import os
import time
import csv
import argparse
import threading
import tempfile
import traceback

from collections import defaultdict, deque
from datetime import datetime
from dotenv import load_dotenv
load_dotenv()

import cv2
from ultralytics import YOLO

from detectors.vehicle_detector import VehicleDetector
from detectors.plate_detector import PlateDetector
from tracker.centroid_tracker import CentroidTracker
from ocr.ocr_reader import multi_pass_ocr
from utils.speed_estimator import calculate_speed
from utils.config import (
    SPEED_LIMIT,
    FRAME_SKIP as CONFIG_FRAME_SKIP,
    MAX_DISAPPEARED,
    MAX_DISTANCE,
)


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
RUNTIME_DIR = os.path.abspath(os.getenv("TRAFFIC_AI_RUNTIME_DIR", BASE_DIR))
UPLOAD_DIR = os.path.abspath(os.getenv("TRAFFIC_AI_UPLOAD_DIR", os.path.join(RUNTIME_DIR, "uploads")))
EXPORT_DIR = os.path.abspath(os.getenv("TRAFFIC_AI_EXPORT_DIR", os.path.join(RUNTIME_DIR, "exports")))

DISPLAY_WIDTH = int(os.getenv("DISPLAY_WIDTH", "960"))
FRAME_DELAY_MODE = os.getenv("FRAME_DELAY_MODE", "fast")  # fast | realtime

SIGNAL_CYCLE_SECONDS = int(os.getenv("SIGNAL_CYCLE_SECONDS", "60"))
SIGNAL_HALF_SECONDS = int(os.getenv("SIGNAL_HALF_SECONDS", "30"))
SIGNAL_REFERENCE_EPOCH = float(os.getenv("SIGNAL_REFERENCE_EPOCH", "0"))

# Hold emergency request for at least this many seconds after last confirmed emergency frame
EMERGENCY_REQUEST_HOLD_SECONDS = float(os.getenv("EMERGENCY_REQUEST_HOLD_SECONDS", "3.0"))

DEFAULT_EMERGENCY_MODEL_PATH = os.path.join(
    BASE_DIR, "runs", "detect", "emergency_detector", "weights", "best.onnx"
)
FALLBACK_EMERGENCY_MODEL_PATH = os.path.join(
    BASE_DIR, "runs", "detect", "runs", "emergency_detector", "weights", "best.onnx"
)
EMERGENCY_MODEL_PATH = os.getenv("EMERGENCY_MODEL_PATH", DEFAULT_EMERGENCY_MODEL_PATH)
if not os.path.exists(EMERGENCY_MODEL_PATH):
    fallback_model_path = None
    for candidate in (DEFAULT_EMERGENCY_MODEL_PATH, FALLBACK_EMERGENCY_MODEL_PATH):
        if os.path.exists(candidate):
            fallback_model_path = candidate
            break

    if fallback_model_path:
        if EMERGENCY_MODEL_PATH != fallback_model_path:
            print(
                f"[CONFIG] EMERGENCY_MODEL_PATH not found: {EMERGENCY_MODEL_PATH}. "
                f"Using bundled model: {fallback_model_path}"
            )
        EMERGENCY_MODEL_PATH = fallback_model_path
EMERGENCY_CONFIDENCE = float(os.getenv("EMERGENCY_CONFIDENCE", "0.20"))
MAX_EMERGENCY_SNAPSHOTS = int(os.getenv("MAX_EMERGENCY_SNAPSHOTS", "3"))

OCR_MIN_CONFIDENCE_TO_CACHE = float(os.getenv("OCR_MIN_CONFIDENCE_TO_CACHE", "0.50"))
CAMERA_WARMUP_FRAMES = int(os.getenv("CAMERA_WARMUP_FRAMES", "8"))

EMERGENCY_REQUEST_FILE = os.path.join(EXPORT_DIR, "emergency_request.txt")

ROAD_NAMES = {
    "cam0": "ROAD_1",
    "cam1": "ROAD_2",
}

# Stop line per camera as ratios: x1,y1,x2,y2
# Defaults are horizontal lines; adjust per camera if needed
STOP_LINE_CONFIG = {
    "cam0": (
        float(os.getenv("CAM0_STOP_X1_RATIO", "0.00")),
        float(os.getenv("CAM0_STOP_Y1_RATIO", "0.62")),
        float(os.getenv("CAM0_STOP_X2_RATIO", "1.00")),
        float(os.getenv("CAM0_STOP_Y2_RATIO", "0.62")),
    ),
    "cam1": (
        float(os.getenv("CAM1_STOP_X1_RATIO", "0.00")),
        float(os.getenv("CAM1_STOP_Y1_RATIO", "0.62")),
        float(os.getenv("CAM1_STOP_X2_RATIO", "1.00")),
        float(os.getenv("CAM1_STOP_Y2_RATIO", "0.62")),
    ),
}

os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

# File lock for central request file
EMERGENCY_FILE_LOCK = threading.Lock()

# Lock around shared YOLO inference for thread safety on Raspberry Pi
EMERGENCY_INFERENCE_LOCK = threading.Lock()

# Central state for all camera requests
REQUEST_STATE_LOCK = threading.Lock()
REQUEST_STATE = {
    "cam0": {
        "road_name": ROAD_NAMES["cam0"],
        "request_active": False,
        "hold_until": 0.0,
        "last_confirmed_at": 0.0,
    },
    "cam1": {
        "road_name": ROAD_NAMES["cam1"],
        "request_active": False,
        "hold_until": 0.0,
        "last_confirmed_at": 0.0,
    },
}


def now_iso():
    return datetime.now().isoformat(timespec="seconds")


def write_text_file_atomic(path: str, content: str):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    fd, tmp_path = tempfile.mkstemp(dir=os.path.dirname(path), prefix=".tmp_", text=True)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            f.write(content)
            f.flush()
            os.fsync(f.fileno())
        os.replace(tmp_path, path)
    finally:
        if os.path.exists(tmp_path):
            try:
                os.remove(tmp_path)
            except OSError:
                pass


def write_text_file(path: str, content: str):
    write_text_file_atomic(path, content)


def append_text_file(path: str, content: str):
    with open(path, "a", encoding="utf-8") as f:
        f.write(content)
        f.flush()


def write_central_request_payload(road_name: str | None):
    road_code_map = {
        None: "0",
        "NONE": "0",
        "ROAD_1": "1",
        "ROAD_2": "2",
    }

    value = road_code_map.get(road_name, "0")
    content = f"road={value}\nts={now_iso()}\n"

    with EMERGENCY_FILE_LOCK:
        write_text_file(EMERGENCY_REQUEST_FILE, content)

def recompute_and_write_central_request():
    """
    Central logic:
    - If one or more cameras have active request, write one road.
    - Priority: most recent confirmed request wins.
    - If no active requests, write NONE.
    """
    with REQUEST_STATE_LOCK:
        active_items = []
        for cam_name, info in REQUEST_STATE.items():
            if info["request_active"]:
                active_items.append(
                    (info["last_confirmed_at"], cam_name, info["road_name"])
                )

        if not active_items:
            selected_road = None
        else:
            active_items.sort(reverse=True)
            selected_road = active_items[0][2]

    write_central_request_payload(selected_road)
    return selected_road


def update_camera_request_state(camera_name: str, should_request_open: bool):
    """
    Prevents a NONE from one camera from erasing the other camera's valid request.
    Uses hold time to debounce request clearing.
    """
    current_time = time.time()

    with REQUEST_STATE_LOCK:
        state = REQUEST_STATE[camera_name]

        if should_request_open:
            state["request_active"] = True
            state["last_confirmed_at"] = current_time
            state["hold_until"] = current_time + EMERGENCY_REQUEST_HOLD_SECONDS
        else:
            # Only clear after hold time expires
            if current_time >= state["hold_until"]:
                state["request_active"] = False

    selected_road = recompute_and_write_central_request()
    return selected_road


def orientation(a, b, c):
    value = (b[1] - a[1]) * (c[0] - b[0]) - (b[0] - a[0]) * (c[1] - b[1])
    if value == 0:
        return 0
    return 1 if value > 0 else 2


def on_segment(a, b, c):
    return (
        min(a[0], c[0]) <= b[0] <= max(a[0], c[0])
        and min(a[1], c[1]) <= b[1] <= max(a[1], c[1])
    )


def segments_intersect(a, b, c, d):
    o1 = orientation(a, b, c)
    o2 = orientation(a, b, d)
    o3 = orientation(c, d, a)
    o4 = orientation(c, d, b)

    if o1 != o2 and o3 != o4:
        return True

    if o1 == 0 and on_segment(a, c, b):
        return True
    if o2 == 0 and on_segment(a, d, b):
        return True
    if o3 == 0 and on_segment(c, a, d):
        return True
    if o4 == 0 and on_segment(c, b, d):
        return True

    return False


class DualRoadSignalController:
    def __init__(self, cycle_seconds: int = 60, half_seconds: int = 30, reference_epoch: float = 0.0):
        self.cycle_seconds = cycle_seconds
        self.half_seconds = half_seconds
        self.reference_epoch = reference_epoch if reference_epoch > 0 else 0.0

    def get_state(self, camera_name: str) -> str:
        reference_time = self.reference_epoch if self.reference_epoch > 0 else 0.0
        elapsed = int(time.time() - reference_time)
        phase = elapsed % self.cycle_seconds

        if phase < self.half_seconds:
            return "green" if camera_name == "cam0" else "red"
        return "red" if camera_name == "cam0" else "green"


class EmergencyDetector:
    def __init__(self, model_path: str):
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Emergency model not found: {model_path}")

        self.model = YOLO(model_path)
        self.default_names = {0: "emergency vehicle"}
        self.emergency_keywords = {
            "emergency",
            "emergency vehicle",
            "ambulance",
            "police",
            "police car",
            "fire truck",
            "fire engine",
        }

    def _get_label(self, cls_id: int) -> str:
        names = getattr(self.model, "names", None)

        if isinstance(names, dict):
            label = str(names.get(cls_id, self.default_names.get(cls_id, str(cls_id))))
        elif isinstance(names, list):
            if 0 <= cls_id < len(names):
                label = str(names[cls_id])
            else:
                label = str(self.default_names.get(cls_id, cls_id))
        else:
            label = str(self.default_names.get(cls_id, cls_id))

        return label.lower().strip()

    def detect(self, frame):
        try:
            with EMERGENCY_INFERENCE_LOCK:
                results = self.model(frame, conf=EMERGENCY_CONFIDENCE, verbose=False)[0]
        except Exception:
            return False, 0.0, None, None

        has_emergency = False
        best_conf = 0.0
        best_box = None
        best_label = None

        for box in results.boxes:
            cls_id = int(box.cls[0])
            conf = float(box.conf[0])

            label = self._get_label(cls_id)
            normalized = label.replace("emegency", "emergency")

            is_emergency = normalized in self.emergency_keywords or cls_id == 0

            if is_emergency and conf > best_conf:
                has_emergency = True
                best_conf = conf
                best_box = tuple(map(int, box.xyxy[0].cpu().tolist()))
                best_label = normalized

        return has_emergency, best_conf, best_box, best_label


class EmergencySnapshotManager:
    def __init__(self, snapshot_dir: str, limit: int = 3):
        self.snapshot_dir = snapshot_dir
        self.limit = limit
        self.saved_paths = []
        self.best_conf = 0.0
        self.best_frame = None
        self.best_frame_no = 0
        self.active = False

    def reset(self):
        self.saved_paths = []
        self.best_conf = 0.0
        self.best_frame = None
        self.best_frame_no = 0
        self.active = False

    def update(self, frame, frame_no: int, conf: float, snapshot_active: bool):
        was_active = self.active

        if snapshot_active:
            self.active = True
            if conf > self.best_conf:
                self.best_conf = conf
                self.best_frame = frame.copy()
                self.best_frame_no = frame_no
        elif was_active and not snapshot_active:
            self.save_best()
            self.active = False
            self.best_conf = 0.0
            self.best_frame = None
            self.best_frame_no = 0

    def save_best(self):
        if self.best_frame is None or len(self.saved_paths) >= self.limit:
            return None

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"emergency_frame_{self.best_frame_no}_{timestamp}_conf_{self.best_conf:.3f}.jpg"
        path = os.path.join(self.snapshot_dir, filename)

        ok = cv2.imwrite(path, self.best_frame)
        if ok:
            self.saved_paths.append(path)
            return path
        return None

    def force_save(self):
        return self.save_best()


class CameraProcessor:
    def __init__(
        self,
        camera_name: str,
        source: str,
        emergency_detector: EmergencyDetector,
        signal_controller: DualRoadSignalController,
        road_name: str,
        request_file_path: str,
    ):
        self.camera_name = camera_name
        self.source_input = source
        self.signal_controller = signal_controller
        self.road_name = road_name
        self.request_file_path = request_file_path

        self.camera_dir = os.path.join(EXPORT_DIR, camera_name)
        self.snapshot_dir = os.path.join(self.camera_dir, "snapshots")
        self.log_dir = os.path.join(self.camera_dir, "logs")
        self.plates_dir = os.path.join(self.camera_dir, "plates")
        self.run_status_path = os.path.join(self.log_dir, "run_status.txt")
        self.summary_path = os.path.join(self.log_dir, "session_summary.txt")
        self.plates_log_path = None

        os.makedirs(self.camera_dir, exist_ok=True)
        os.makedirs(self.snapshot_dir, exist_ok=True)
        os.makedirs(self.log_dir, exist_ok=True)
        os.makedirs(self.plates_dir, exist_ok=True)

        self.detector = VehicleDetector()
        self.plate_detector = PlateDetector()
        self.emergency_detector = emergency_detector
        self.emergency_snapshots = EmergencySnapshotManager(self.snapshot_dir, MAX_EMERGENCY_SNAPSHOTS)

        self.reset()

    def reset(self):
        self.tracker = CentroidTracker(
            max_disappeared=MAX_DISAPPEARED,
            max_distance=MAX_DISTANCE,
        )

        self.red_light = False
        self.frame_no = 0
        self.elapsed_sec = 0.0
        self.fps_display = 0.0
        self.active_vehicles = 0
        self.total_tracked = 0
        self.speed_violations = 0
        self.line_violations = 0
        self.avg_speed = 0.0

        self.track_positions = defaultdict(list)
        self.track_frames = {}
        self.track_speed_cache = {}

        self.line_crossed_ids = set()
        self.speed_violation_ids = set()
        self.line_violation_ids = set()

        self.violation_events = deque(maxlen=200)

        self.started_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.csv_path = None
        self.csv_file = None
        self.csv_writer = None

        self.plates_log_file = None
        self.plates_log_writer = None
        self.plate_results = {}
        self.plate_meta = {}

        self.emergency_active = False
        self.emergency_label = None
        self.flag_value = "NONE"

        self.emergency_history = deque(maxlen=3)
        self.emergency_miss_streak = 0
        self.current_emergency_box = None
        self.last_signal_state = None
        self.last_ocr_reason = None

        self.emergency_snapshots.reset()

    def write_flag(self, value: str):
        # Central logic already writes the shared request file.
        # Keep local value updated for logs and CSV only.
        self.flag_value = value

    def clear_flag(self):
        self.flag_value = "NONE"

    def log_event(self, message: str):
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        append_text_file(self.run_status_path, f"[{timestamp}] {message}\n")

    def open_logs(self):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

        self.csv_path = os.path.join(self.camera_dir, f"traffic_report_{timestamp}.csv")
        self.csv_file = open(self.csv_path, "w", newline="", encoding="utf-8")
        self.csv_writer = csv.writer(self.csv_file)
        self.csv_writer.writerow([
            "timestamp",
            "frame_no",
            "elapsed_sec",
            "track_id",
            "plate_text",
            "plate_confidence",
            "plate_validated",
            "x1",
            "y1",
            "x2",
            "y2",
            "speed_kmh",
            "speed_violation",
            "crossed_stop_line",
            "red_light_violation",
            "emergency_active",
            "request_value",
            "signal_state",
            "ocr_reason",
        ])

        self.plates_log_path = os.path.join(self.log_dir, f"plates_log_{timestamp}.csv")
        self.plates_log_file = open(self.plates_log_path, "w", newline="", encoding="utf-8")
        self.plates_log_writer = csv.writer(self.plates_log_file)
        self.plates_log_writer.writerow([
            "timestamp",
            "frame_no",
            "track_id",
            "plate_text",
            "confidence",
            "validated",
            "image_path",
        ])

    def close_logs(self):
        if self.csv_file:
            self.csv_file.close()
        if self.plates_log_file:
            self.plates_log_file.close()

        self.csv_file = None
        self.csv_writer = None
        self.plates_log_file = None
        self.plates_log_writer = None

    def save_session_summary(self, source_name: str):
        summary = f"""started_at: {self.started_at}
source: {source_name}
road_name: {self.road_name}
signal_reference_epoch: {SIGNAL_REFERENCE_EPOCH}
csv_path: {self.csv_path or ""}
plates_log_path: {self.plates_log_path or ""}
frames_processed: {self.frame_no}
elapsed_sec: {self.elapsed_sec:.2f}
active_vehicles_last_frame: {self.active_vehicles}
total_tracked: {self.total_tracked}
speed_violations: {self.speed_violations}
line_violations: {self.line_violations}
avg_speed_last_frame: {self.avg_speed:.2f}
recognized_plates: {len(self.plate_results)}
emergency_active_end: {self.emergency_active}
request_value_end: {self.flag_value}
emergency_snapshots_saved: {len(self.emergency_snapshots.saved_paths)}
"""
        write_text_file(self.summary_path, summary)

    def save_plate_log(self, track_id: int, frame_no: int, plate_text: str, confidence: float, validated: bool, image_path: str):
        if self.plates_log_writer:
            self.plates_log_writer.writerow([
                now_iso(),
                frame_no,
                track_id,
                plate_text,
                round(confidence, 3),
                1 if validated else 0,
                image_path,
            ])

    def resize_for_processing(self, frame):
        h, w = frame.shape[:2]
        if w <= DISPLAY_WIDTH:
            return frame
        new_h = int(h * (DISPLAY_WIDTH / w))
        return cv2.resize(frame, (DISPLAY_WIDTH, new_h))

    @staticmethod
    def boxes_overlap(box1, box2):
        if box1 is None or box2 is None:
            return 0.0

        x1 = max(box1[0], box2[0])
        y1 = max(box1[1], box2[1])
        x2 = min(box1[2], box2[2])
        y2 = min(box1[3], box2[3])

        if x2 <= x1 or y2 <= y1:
            return 0.0

        inter = (x2 - x1) * (y2 - y1)
        area1 = max((box1[2] - box1[0]) * (box1[3] - box1[1]), 1)
        area2 = max((box2[2] - box2[0]) * (box2[3] - box2[1]), 1)
        return inter / min(area1, area2)

    def is_same_emergency_object(self, vehicle_box, emergency_box):
        if emergency_box is None:
            return False

        if self.boxes_overlap(vehicle_box, emergency_box) >= 0.35:
            return True

        x1, y1, x2, y2 = vehicle_box
        cx, cy = (x1 + x2) // 2, (y1 + y2) // 2
        return (
            emergency_box[0] <= cx <= emergency_box[2]
            and emergency_box[1] <= cy <= emergency_box[3]
        )

    def get_stop_line(self, frame):
        h, w = frame.shape[:2]
        x1r, y1r, x2r, y2r = STOP_LINE_CONFIG.get(
            self.camera_name,
            (0.0, 0.62, 1.0, 0.62),
        )
        p1 = (int(w * x1r), int(h * y1r))
        p2 = (int(w * x2r), int(h * y2r))
        return p1, p2

    def crossed_stop_line(self, track_id, line_p1, line_p2):
        pts = self.track_positions[track_id]
        if len(pts) < 2:
            return False

        prev_pt = pts[-2]
        curr_pt = pts[-1]
        return segments_intersect(prev_pt, curr_pt, line_p1, line_p2)

    def try_read_plate(self, frame, bbox, track_id, should_run_ocr: bool, ocr_reason: str = ""):
        x1, y1, x2, y2 = bbox
        plate_text = self.plate_results.get(track_id, "")
        plate_confidence = 0.0
        plate_validated = False

        meta = self.plate_meta.get(track_id, {})
        if track_id in self.plate_results and bool(meta.get("validated", False)):
            return (
                self.plate_results.get(track_id, ""),
                float(meta.get("confidence", 0.0)),
                True,
            )

        if not should_run_ocr:
            return (
                self.plate_results.get(track_id, ""),
                float(meta.get("confidence", 0.0)),
                bool(meta.get("validated", False)),
            )

        vehicle_crop = frame[y1:y2, x1:x2]
        if vehicle_crop is None or vehicle_crop.size == 0:
            return plate_text, plate_confidence, plate_validated

        plate_box = self.plate_detector.detect(vehicle_crop)
        if plate_box is None:
            return plate_text, plate_confidence, plate_validated

        px1, py1, px2, py2 = plate_box
        px1 = max(0, px1)
        py1 = max(0, py1)
        px2 = min(vehicle_crop.shape[1], px2)
        py2 = min(vehicle_crop.shape[0], py2)

        if px2 <= px1 or py2 <= py1:
            return plate_text, plate_confidence, plate_validated

        plate_crop = vehicle_crop[py1:py2, px1:px2]
        if plate_crop is None or plate_crop.size == 0:
            return plate_text, plate_confidence, plate_validated

        ocr_result = multi_pass_ocr(plate_crop, max_attempts=3)
        if not ocr_result or not ocr_result.plate_number:
            return plate_text, plate_confidence, plate_validated

        plate_text = ocr_result.plate_number
        plate_confidence = float(ocr_result.confidence)
        plate_validated = bool(ocr_result.validated)

        image_path = ""
        if plate_validated or plate_confidence >= OCR_MIN_CONFIDENCE_TO_CACHE:
            safe_text = "".join(ch for ch in plate_text if ch.isalnum() or ch in ("-", "_")) or "unknown"
            image_name = f"track_{track_id}_frame_{self.frame_no}_{safe_text}.jpg"
            image_path = os.path.join(self.plates_dir, image_name)
            cv2.imwrite(image_path, plate_crop)

            self.plate_meta[track_id] = {
                "confidence": plate_confidence,
                "validated": plate_validated,
                "image_path": image_path,
            }

            if plate_validated:
                self.plate_results[track_id] = plate_text

            self.save_plate_log(track_id, self.frame_no, plate_text, plate_confidence, plate_validated, image_path)
            self.log_event(
                f"Track {track_id}: OCR triggered بسبب {ocr_reason} | plate={plate_text}, validated={plate_validated}, conf={plate_confidence:.3f}"
            )

        return plate_text, plate_confidence, plate_validated

    @staticmethod
    def normalize_source(source: str):
        source = str(source).strip()

        if source.isdigit():
            return int(source), f"camera_{source}"

        lowered = source.lower()
        if lowered.startswith(("rtsp://", "rtmp://", "http://", "https://")):
            return source, source

        if os.path.exists(source):
            return source, source

        raise FileNotFoundError(f"Source not found or unsupported: {source}")

    @staticmethod
    def open_capture(source):
        if isinstance(source, int):
            cap = cv2.VideoCapture(source, cv2.CAP_V4L2)
            if not cap.isOpened():
                cap.release()
                cap = cv2.VideoCapture(source)
            return cap
        return cv2.VideoCapture(source)

    @staticmethod
    def warmup_camera(cap, count: int):
        for _ in range(max(count, 0)):
            ok, _ = cap.read()
            if not ok:
                break

    def run(self):
        normalized_source, source_name = self.normalize_source(self.source_input)

        self.reset()

        cap = self.open_capture(normalized_source)
        if not cap.isOpened():
            raise RuntimeError(f"[{self.camera_name}] Failed to open source: {self.source_input}")

        self.open_logs()

        if isinstance(normalized_source, int):
            self.warmup_camera(cap, CAMERA_WARMUP_FRAMES)

        write_text_file(self.run_status_path, "")
        self.log_event(
            f"Session started | source={source_name} | road={self.road_name} | "
            f"signal_reference_epoch={SIGNAL_REFERENCE_EPOCH}"
        )
        if SIGNAL_REFERENCE_EPOCH <= 0:
            self.log_event("WARNING: SIGNAL_REFERENCE_EPOCH is not set; signal timing is anchored to Unix epoch 0.")

        # Reset this camera request state at startup
        with REQUEST_STATE_LOCK:
            REQUEST_STATE[self.camera_name]["request_active"] = False
            REQUEST_STATE[self.camera_name]["hold_until"] = 0.0
            REQUEST_STATE[self.camera_name]["last_confirmed_at"] = 0.0
        recompute_and_write_central_request()

        t_prev = time.time()

        try:
            while True:
                ok, frame = cap.read()
                if not ok:
                    self.log_event("Source finished or camera frame read failed")
                    break

                self.frame_no += 1
                effective_skip = max(CONFIG_FRAME_SKIP, 1)
                if effective_skip > 1 and self.frame_no % effective_skip != 0:
                    continue

                frame = self.resize_for_processing(frame)

                fps_video = cap.get(cv2.CAP_PROP_FPS)
                if not fps_video or fps_video <= 1e-6 or fps_video != fps_video:
                    fps_video = 30.0

                now_time = time.time()
                self.fps_display = 1.0 / max(now_time - t_prev, 1e-6)
                t_prev = now_time
                self.elapsed_sec = self.frame_no / fps_video

                line_p1, line_p2 = self.get_stop_line(frame)

                signal_state = self.signal_controller.get_state(self.camera_name)
                self.red_light = (signal_state == "red")

                if self.last_signal_state != signal_state:
                    if self.last_signal_state is not None:
                        self.log_event(f"Signal changed: {self.last_signal_state} -> {signal_state}")
                    else:
                        self.log_event(f"Signal initial state: {signal_state}")
                    self.last_signal_state = signal_state

                try:
                    has_emergency_raw, emergency_conf, emergency_box, emergency_label = self.emergency_detector.detect(frame)
                except Exception as e:
                    self.log_event(f"Emergency detect error: {e}")
                    has_emergency_raw, emergency_conf, emergency_box, emergency_label = False, 0.0, None, None

                previous_emergency = self.emergency_active

                self.emergency_history.append(1 if has_emergency_raw else 0)

                if has_emergency_raw:
                    self.emergency_miss_streak = 0
                    self.current_emergency_box = emergency_box
                else:
                    self.emergency_miss_streak += 1

                history = list(self.emergency_history)
                if not self.emergency_active and len(history) == 3 and history == [1, 1, 1]:
                    self.emergency_active = True
                elif self.emergency_active and self.emergency_miss_streak >= 4:
                    self.emergency_active = False
                    self.current_emergency_box = None

                self.emergency_label = emergency_label

                should_request_open = self.emergency_active and self.red_light
                selected_road = update_camera_request_state(self.camera_name, should_request_open)
                effective_request_value = selected_road if selected_road else "NONE"

                if should_request_open:
                    self.write_flag(effective_request_value)
                    if not previous_emergency:
                        self.violation_events.append({
                            "time": f"{self.elapsed_sec:.1f}s",
                            "track_id": "-",
                            "speed_kmh": None,
                            "event_type": "Emergency detected",
                            "status": f"Request open {self.road_name}",
                        })
                        self.log_event(f"Emergency detected on RED - request open road: {self.road_name}")
                else:
                    self.write_flag(effective_request_value)
                    if previous_emergency and not self.emergency_active:
                        self.violation_events.append({
                            "time": f"{self.elapsed_sec:.1f}s",
                            "track_id": "-",
                            "speed_kmh": None,
                            "event_type": "Emergency cleared",
                            "status": "Request cleared or held by controller",
                        })
                        self.log_event("Emergency cleared")

                # Save snapshots only when an actual open-road request is active for this camera
                snapshot_active = should_request_open
                self.emergency_snapshots.update(frame, self.frame_no, emergency_conf, snapshot_active)

                try:
                    rects = self.detector.detect(frame)
                except Exception as e:
                    self.log_event(f"Vehicle detect error: {e}")
                    rects = []

                try:
                    tracked_objects = self.tracker.update(rects)
                except Exception as e:
                    self.log_event(f"Tracker error: {e}")
                    tracked_objects = {}

                active_ids = set()
                speeds_this_frame = []

                for track_id, bbox in tracked_objects.items():
                    if self.is_same_emergency_object(bbox, self.current_emergency_box):
                        continue

                    x1, y1, x2, y2 = bbox
                    cx, cy = (x1 + x2) // 2, (y1 + y2) // 2
                    active_ids.add(track_id)
                    self.track_positions[track_id].append((cx, cy))

                    if track_id not in self.track_frames:
                        self.track_frames[track_id] = {
                            "first_frame": self.frame_no,
                            "last_frame": self.frame_no,
                        }
                    else:
                        self.track_frames[track_id]["last_frame"] = self.frame_no

                    first_frame = self.track_frames[track_id]["first_frame"]
                    last_frame = self.track_frames[track_id]["last_frame"]
                    positions = self.track_positions[track_id]

                    speed_kmh = 0.0
                    if len(positions) >= 2 and last_frame > first_frame:
                        speed_kmh = calculate_speed(first_frame, last_frame, positions, fps_video)
                        self.track_speed_cache[track_id] = speed_kmh
                        if speed_kmh > 0:
                            speeds_this_frame.append(speed_kmh)
                    else:
                        speed_kmh = self.track_speed_cache.get(track_id, 0.0)

                    crossed_line = False
                    red_line_violation = False

                    if self.crossed_stop_line(track_id, line_p1, line_p2) and track_id not in self.line_crossed_ids:
                        self.line_crossed_ids.add(track_id)
                        crossed_line = True

                        if self.red_light:
                            red_line_violation = True
                            self.line_violation_ids.add(track_id)
                            self.violation_events.append({
                                "time": f"{self.elapsed_sec:.1f}s",
                                "track_id": track_id,
                                "speed_kmh": speed_kmh,
                                "event_type": "Stop line crossing",
                                "status": "Red light violation",
                            })
                            self.log_event(f"Track {track_id}: red light violation")

                    is_speed_violation = speed_kmh > SPEED_LIMIT
                    if is_speed_violation and track_id not in self.speed_violation_ids:
                        self.speed_violation_ids.add(track_id)
                        self.violation_events.append({
                            "time": f"{self.elapsed_sec:.1f}s",
                            "track_id": track_id,
                            "speed_kmh": speed_kmh,
                            "event_type": "Overspeed",
                            "status": "Overspeed violation",
                        })
                        self.log_event(f"Track {track_id}: overspeed violation")

                    should_run_ocr = is_speed_violation or red_line_violation
                    ocr_reason = ""
                    if is_speed_violation:
                        ocr_reason = "overspeed"
                    elif red_line_violation:
                        ocr_reason = "red_light_violation"

                    plate_text, plate_confidence, plate_validated = self.try_read_plate(
                        frame,
                        bbox,
                        track_id,
                        should_run_ocr=should_run_ocr,
                        ocr_reason=ocr_reason,
                    )

                    if self.csv_writer:
                        self.csv_writer.writerow([
                            now_iso(),
                            self.frame_no,
                            round(self.elapsed_sec, 2),
                            track_id,
                            plate_text,
                            round(plate_confidence, 3) if plate_confidence else "",
                            1 if plate_validated else 0,
                            x1, y1, x2, y2,
                            round(speed_kmh, 2) if speed_kmh else "",
                            1 if is_speed_violation else 0,
                            1 if crossed_line else 0,
                            1 if red_line_violation else 0,
                            1 if self.emergency_active else 0,
                            self.flag_value,
                            signal_state,
                            ocr_reason,
                        ])

                self.active_vehicles = len(active_ids)
                self.total_tracked = len(self.track_frames)
                self.speed_violations = len(self.speed_violation_ids)
                self.line_violations = len(self.line_violation_ids)
                self.avg_speed = (sum(speeds_this_frame) / len(speeds_this_frame)) if speeds_this_frame else 0.0

                if self.frame_no % 30 == 0:
                    print(
                        f"[{self.camera_name}] frame={self.frame_no} "
                        f"signal={signal_state} "
                        f"active={self.active_vehicles} "
                        f"speed_v={self.speed_violations} "
                        f"line_v={self.line_violations} "
                        f"plates={len(self.plate_results)} "
                        f"request={self.flag_value}"
                    )

                if FRAME_DELAY_MODE == "realtime":
                    time.sleep(1 / max(fps_video, 1))

        finally:
            # Clear this camera's request at shutdown, but preserve the other camera if active
            with REQUEST_STATE_LOCK:
                REQUEST_STATE[self.camera_name]["request_active"] = False
                REQUEST_STATE[self.camera_name]["hold_until"] = 0.0
            recompute_and_write_central_request()

            self.emergency_snapshots.force_save()
            self.log_event("Session ended")
            self.close_logs()
            cap.release()
            self.save_session_summary(source_name)


def parse_sources(raw_sources):
    parts = []
    for item in raw_sources:
        for part in str(item).split(","):
            cleaned = part.strip()
            if cleaned:
                parts.append(cleaned)
    return parts


def build_arg_parser():
    parser = argparse.ArgumentParser(description="Multi-camera traffic monitor with OCR for Raspberry Pi")
    parser.add_argument(
        "--sources",
        nargs="+",
        required=True,
        help='Exactly two sources. Example: --sources 0 1 OR --sources "0,1"',
    )
    return parser


def run_processor_safe(processor: CameraProcessor):
    try:
        processor.run()
    except Exception as e:
        tb = traceback.format_exc()
        try:
            processor.log_event(f"FATAL: {e}")
            processor.log_event(tb)
        except Exception:
            pass
        print(f"[{processor.camera_name}] FATAL: {e}")
        print(tb)


def main():
    args = build_arg_parser().parse_args()
    sources = parse_sources(args.sources)

    if len(sources) != 2:
        raise ValueError("This project expects exactly 2 sources")

    os.makedirs(EXPORT_DIR, exist_ok=True)

    # Clean startup state
    with REQUEST_STATE_LOCK:
        for cam_name in REQUEST_STATE:
            REQUEST_STATE[cam_name]["request_active"] = False
            REQUEST_STATE[cam_name]["hold_until"] = 0.0
            REQUEST_STATE[cam_name]["last_confirmed_at"] = 0.0
    write_central_request_payload(None)

    shared_emergency_detector = EmergencyDetector(EMERGENCY_MODEL_PATH)
    signal_controller = DualRoadSignalController(
        cycle_seconds=SIGNAL_CYCLE_SECONDS,
        half_seconds=SIGNAL_HALF_SECONDS,
        reference_epoch=SIGNAL_REFERENCE_EPOCH,
    )

    processors = []
    threads = []

    for idx, source in enumerate(sources):
        camera_name = f"cam{idx}"
        road_name = ROAD_NAMES.get(camera_name, camera_name)

        processor = CameraProcessor(
            camera_name=camera_name,
            source=source,
            emergency_detector=shared_emergency_detector,
            signal_controller=signal_controller,
            road_name=road_name,
            request_file_path=EMERGENCY_REQUEST_FILE,
        )
        processors.append(processor)

        thread = threading.Thread(
            target=run_processor_safe,
            args=(processor,),
            name=camera_name,
            daemon=False,
        )
        threads.append(thread)

    print(f"Starting {len(threads)} camera stream(s): {', '.join(p.camera_name for p in processors)}")
    print(f"[SYSTEM] SIGNAL_REFERENCE_EPOCH={SIGNAL_REFERENCE_EPOCH}")

    for thread in threads:
        thread.start()

    for thread in threads:
        thread.join()

    # Final clean state
    with REQUEST_STATE_LOCK:
        for cam_name in REQUEST_STATE:
            REQUEST_STATE[cam_name]["request_active"] = False
            REQUEST_STATE[cam_name]["hold_until"] = 0.0
            REQUEST_STATE[cam_name]["last_confirmed_at"] = 0.0
    write_central_request_payload(None)

    print("Done")
    print(f"[SYSTEM] Emergency request file: {EMERGENCY_REQUEST_FILE}")
    for processor in processors:
        print(f"[{processor.camera_name}] Road name: {processor.road_name}")
        print(f"[{processor.camera_name}] CSV saved to: {processor.csv_path}")
        print(f"[{processor.camera_name}] Summary saved to: {processor.summary_path}")
        print(f"[{processor.camera_name}] Run log saved to: {processor.run_status_path}")
        print(f"[{processor.camera_name}] Plates log saved to: {processor.plates_log_path}")
        print(f"[{processor.camera_name}] Snapshots dir: {processor.snapshot_dir}")
        print(f"[{processor.camera_name}] Plates dir: {processor.plates_dir}")


if __name__ == "__main__":
    main()
