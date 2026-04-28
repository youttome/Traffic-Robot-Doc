# Traffic AI Model Documentation Bundle

This folder is a documentation and integration bundle for the Python traffic AI service currently developed in:

`/media/abso/project/workspace/ai-service`

It was prepared on `2026-04-27` and placed in the requested Yocto workspace at:

`/media/abso/yocto/traffic_robot/traffic_ai_model`

## What Is In This Folder

- `PROJECT_REPORT.md`
  Full technical report for the AI traffic-monitoring service, including architecture, runtime flow, and deployment concerns.

- `NODE_REFERENCE.md`
  Node-by-node and module-by-module reference for the logical runtime components in the service.

- `FILE_REFERENCE.md`
  File-level reference for the staged source snapshot and the key runtime assets.

- `TASKS.md`
  Development roadmap and packaging checklist for this AI model project.

- `YOCTO_META_TR_GUIDE.md`
  Guide for integrating the service into a `meta-tr` Yocto layer.

- `meta-tr/`
  A starter Yocto layer skeleton with a first-pass recipe for the AI service.

- `source/`
  A clean source snapshot staged for packaging and further integration work.

## Project Summary

The AI service is a two-camera traffic-monitoring pipeline that combines:

- vehicle detection
- centroid-based multi-object tracking
- speed estimation
- stop-line and red-light violation detection
- license-plate detection and OCR
- emergency-vehicle detection
- central road-open request writing for intersection control

## Main Runtime Pieces

- `finish.py`
  Main entry point. Starts exactly two camera-processing threads and coordinates emergency request output.

- `detectors/vehicle_detector.py`
  YOLO vehicle detector for cars, motorcycles, buses, and trucks.

- `detectors/plate_detector.py`
  YOLO plate detector used only when a violation triggers OCR.

- `ocr/ocr_reader.py`
  Multi-pass PaddleOCR reader with basic normalization and validation rules.

- `tracker/centroid_tracker.py`
  Lightweight tracker used to keep stable track IDs across frames.

- `utils/`
  Configuration, speed estimation, and image-safe crop helpers.

- `models/`
  Bundled vehicle and plate detection weights.

- `runs/detect/runs/emergency_detector/weights/best.onnx`
  Bundled emergency-vehicle detector used by the traffic service.

## Important Notes Before Yocto Packaging

- The staged snapshot includes runtime source plus the minimum model assets needed by the current code path.

- The snapshot does not include development-only folders such as `.git`, `.vscode`, `__pycache__`, live `exports`, or live `uploads`.

- The staged `finish.py` was adjusted so runtime outputs can be redirected with:
  `TRAFFIC_AI_RUNTIME_DIR`, `TRAFFIC_AI_EXPORT_DIR`, and `TRAFFIC_AI_UPLOAD_DIR`.

- The sample Yocto launcher uses `/var/lib/traffic-ai-model` as the writable runtime location.

- The service currently expects exactly two sources when launched:
  `python3 finish.py --sources 0 1`

## Suggested Next Step

1. Review the staged source under `source/`.
2. Add the new `meta-tr` layer to your Yocto build.
3. Build `traffic-ai-model` with BitBake.
4. Validate camera access, model loading, and writable export directories on the target.
5. Connect the generated `emergency_request.txt` file to the traffic-light control side.
