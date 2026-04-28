# Node Reference: Traffic AI Model

This reference lists the important logical nodes and runtime modules in the traffic AI service.

Source workspace reviewed:

`/media/abso/project/workspace/ai-service`

## 1. Entry And System Nodes

### `main` in `finish.py`

Role:

- parses `--sources`
- requires exactly two sources
- initializes shared emergency detection and signal timing
- creates `cam0` and `cam1` processing threads
- resets the shared request file at startup and shutdown

Important inputs:

- `--sources 0 1`
- environment variables in `.env` or shell

Important outputs:

- console summary
- shared `exports/emergency_request.txt`

### `run_processor_safe`

Role:

- wraps each camera processor
- catches fatal exceptions
- records fatal errors into camera logs when possible

## 2. Shared Coordination Nodes

### `DualRoadSignalController`

Role:

- computes whether each road is red or green
- uses cycle duration, half-cycle duration, and reference epoch
- keeps AI timing aligned with the traffic-light controller

Important configuration:

- `SIGNAL_CYCLE_SECONDS`
- `SIGNAL_HALF_SECONDS`
- `SIGNAL_REFERENCE_EPOCH`

Output:

- signal state per camera: `red` or `green`

### Central Request Writer

Functions:

- `write_central_request_payload`
- `recompute_and_write_central_request`
- `update_camera_request_state`

Role:

- arbitrates emergency open-road requests across both camera threads
- prevents one camera from clearing the other camera's active request
- writes a compact file for the external control script

Important behavior:

- hold timer delays request clearing
- most recent active request wins

Main file interface:

- `exports/emergency_request.txt`

## 3. Camera Processing Nodes

### `cam0` processor thread

Implementation:

- `CameraProcessor(camera_name="cam0", road_name="ROAD_1", ...)`

Role:

- monitors the first source
- represents `ROAD_1`
- writes per-camera logs, reports, snapshots, and plate crops

Primary outputs:

- `exports/cam0/traffic_report_*.csv`
- `exports/cam0/logs/run_status.txt`
- `exports/cam0/logs/session_summary.txt`
- `exports/cam0/logs/plates_log_*.csv`
- `exports/cam0/plates/`
- `exports/cam0/snapshots/`

### `cam1` processor thread

Implementation:

- `CameraProcessor(camera_name="cam1", road_name="ROAD_2", ...)`

Role:

- monitors the second source
- represents `ROAD_2`
- uses the same pipeline as `cam0`

Primary outputs:

- `exports/cam1/traffic_report_*.csv`
- `exports/cam1/logs/run_status.txt`
- `exports/cam1/logs/session_summary.txt`
- `exports/cam1/logs/plates_log_*.csv`
- `exports/cam1/plates/`
- `exports/cam1/snapshots/`

## 4. Detection Nodes

### `EmergencyDetector`

Role:

- loads the emergency-vehicle YOLO model
- classifies emergency vehicles from full-frame input
- returns emergency presence, confidence, box, and label

Input:

- full camera frame

Output:

- `has_emergency`
- `best_conf`
- `best_box`
- `best_label`

Important configuration:

- `EMERGENCY_MODEL_PATH`
- `EMERGENCY_CONFIDENCE`

### `VehicleDetector`

Source:

- `detectors/vehicle_detector.py`

Role:

- runs YOLO vehicle detection on each processed frame
- keeps only COCO vehicle classes

Detected classes:

- car
- motorcycle
- bus
- truck

Output:

- list of vehicle bounding boxes

### `PlateDetector`

Source:

- `detectors/plate_detector.py`

Role:

- detects the best plate box inside a vehicle crop
- returns only the highest-confidence plate candidate

Output:

- one plate bounding box or `None`

## 5. Tracking And Measurement Nodes

### `CentroidTracker`

Source:

- `tracker/centroid_tracker.py`

Role:

- assigns object IDs
- matches new detections to previous tracked centroids
- removes stale tracks after a disappearance threshold

Important configuration:

- `MAX_DISAPPEARED`
- `MAX_DISTANCE`

Output:

- `track_id -> bbox` mapping for the current frame

### Speed Estimator

Source:

- `utils/speed_estimator.py`

Role:

- converts tracked pixel movement into kilometers per hour

Important configuration:

- `PIXEL_TO_METER`

Output:

- `speed_kmh`

### Stop-Line Geometry Helpers

Functions:

- `orientation`
- `on_segment`
- `segments_intersect`
- `crossed_stop_line`

Role:

- detect whether a tracked object path crosses the configured stop line

Important configuration:

- `CAM0_STOP_X1_RATIO`
- `CAM0_STOP_Y1_RATIO`
- `CAM0_STOP_X2_RATIO`
- `CAM0_STOP_Y2_RATIO`
- `CAM1_STOP_X1_RATIO`
- `CAM1_STOP_Y1_RATIO`
- `CAM1_STOP_X2_RATIO`
- `CAM1_STOP_Y2_RATIO`

## 6. OCR Nodes

### `multi_pass_ocr`

Source:

- `ocr/ocr_reader.py`

Role:

- performs several OCR attempts with different preprocessing variants
- returns the best `OCRResult`

Output fields:

- `plate_number`
- `raw_text`
- `confidence`
- `validated`
- `corrections`
- `errors`

### OCR Validation Helpers

Functions:

- `basic_clean`
- `apply_corrections`
- `validate_plate_format`
- `read_plate_enhanced`

Role:

- normalize OCR text
- repair common OCR confusion
- validate whether the recognized plate matches expected patterns

## 7. Snapshot And Evidence Nodes

### `EmergencySnapshotManager`

Role:

- collects the best emergency frame while a request is active
- saves only the best snapshot when the event closes
- limits the number of saved emergency frames per session

Important configuration:

- `MAX_EMERGENCY_SNAPSHOTS`

### Plate Evidence Saver

Implemented inside:

- `CameraProcessor.try_read_plate`

Role:

- stores plate crops when OCR is validated or confidence is high enough
- writes a plate log CSV with the saved image path

Important configuration:

- `OCR_MIN_CONFIDENCE_TO_CACHE`

## 8. Runtime Interfaces

### Input Interfaces

- local camera index such as `0` or `1`
- RTSP/HTTP video streams
- video file path
- environment configuration

### Output Interfaces

- per-camera CSV reports
- per-camera text logs
- saved plate images
- saved emergency snapshots
- shared emergency request file for the traffic-light controller

## 9. Most Important Operational Rule

The AI service and the control-side script do not need to start at the same moment.

They only need to use the same:

- `SIGNAL_REFERENCE_EPOCH`

That shared reference keeps the calculated signal phase synchronized.
