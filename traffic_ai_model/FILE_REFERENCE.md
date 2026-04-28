# File Reference: Traffic AI Model

This reference covers the staged source files prepared for the traffic AI service bundle.

Staged snapshot:

`/media/abso/yocto/traffic_robot/traffic_ai_model/source`

Original reviewed source:

`/media/abso/project/workspace/ai-service`

## 1. Root Runtime Files

- `finish.py`
  Main runtime entry point. Owns two-camera orchestration, emergency arbitration, tracking flow, OCR triggers, and report writing.

- `README.txt`
  Existing Arabic runtime notes for installation, camera usage, signal timing, and controller integration.

- `README.md`
  Existing minimal project note from the source workspace.

- `requirements.txt`
  General Python dependency list.

- `requirements-rpi.txt`
  Raspberry Pi aarch64 / Python 3.12 oriented dependency list.

- `.gitignore`
  Local ignore file for editor, cache, upload, and export noise in the staged snapshot.

## 2. Detector Files

- `detectors/vehicle_detector.py`
  YOLO-based normal vehicle detector.

- `detectors/plate_detector.py`
  YOLO-based license-plate detector on cropped vehicle regions.

## 3. OCR Files

- `ocr/ocr_reader.py`
  PaddleOCR wrapper with cleaning, correction, validation, and multi-pass OCR logic.

## 4. Tracking Files

- `tracker/centroid_tracker.py`
  Lightweight centroid tracker used to keep object IDs stable across frames.

## 5. Utility Files

- `utils/config.py`
  Environment-driven configuration values for model paths, thresholds, tracking, and OCR settings.

- `utils/speed_estimator.py`
  Pixel-distance to km/h conversion helper.

- `utils/pre_process.py`
  Safe crop helper for bounded image cropping.

## 6. Model Assets

- `models/vehicle_yolo.pt`
  Vehicle detection model used by `VehicleDetector`.

- `models/plate_yolo.pt`
  Plate detection model used by `PlateDetector`.

- `runs/detect/runs/emergency_detector/weights/best.onnx`
  Emergency-vehicle detector used by `EmergencyDetector`.

## 7. Runtime-Generated Paths

These are generated when the service runs and are intentionally not copied into the source snapshot.

- `exports/`
  Shared runtime output root.

- `exports/emergency_request.txt`
  Shared request file for the traffic-light controller.

- `exports/cam0/`
  Per-camera reports, logs, plate images, and emergency snapshots for road 1.

- `exports/cam1/`
  Per-camera reports, logs, plate images, and emergency snapshots for road 2.

- `uploads/`
  Existing project upload area, if used by future workflows.

## 8. Files Not Carried Into The Snapshot

The staged snapshot intentionally excludes:

- `.git/`
- `.vscode/`
- `__pycache__/`
- live `exports/`
- live `uploads/`
- unrelated training artifacts
- Windows zone-identifier sidecar files

## 9. Packaging Recommendation

For Yocto packaging, the staged snapshot already contains the minimum structure needed for a first-pass local-source integration.

For a production release, consider:

- converting the runtime into a proper Python package
- pinning model asset versions explicitly
- separating runtime outputs from installed application files
- moving from local `externalsrc` to a fixed Git revision or release tarball
