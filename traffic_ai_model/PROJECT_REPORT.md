# Project Report: Traffic AI Model Service

## 1. Introduction

This project is a Python-based traffic-monitoring and emergency-priority service designed for a two-road smart intersection workflow. It uses computer vision to watch two camera streams, detect traffic violations, recognize emergency vehicles, and publish a simple road-open request for an external traffic-light controller.

The active source workspace reviewed for this report is:

`/media/abso/project/workspace/ai-service`

The staged Yocto-side integration bundle is located at:

`/media/abso/yocto/traffic_robot/traffic_ai_model`

## 2. System Objectives

The current service addresses these objectives:

- ingest exactly two camera streams
- map `cam0` to `ROAD_1` and `cam1` to `ROAD_2`
- detect normal road vehicles
- track vehicles across frames
- estimate speed from tracked movement
- detect stop-line crossing events
- detect red-light violations using a shared signal timing model
- run OCR only on violation-triggered vehicles
- detect emergency vehicles
- request road opening when an emergency vehicle is present on a red signal
- write structured CSV and text outputs for downstream review

## 3. High-Level Architecture

The service is organized as one shared coordinator with two per-camera processing threads.

### 3.1 Bootstrap And Shared State

`finish.py` loads environment configuration, creates shared output directories, initializes the emergency detector, creates the signal controller, and starts exactly two `CameraProcessor` instances.

Shared global state includes:

- `REQUEST_STATE`
  per-camera request hold state for `cam0` and `cam1`

- `EMERGENCY_FILE_LOCK`
  protects the central request file from concurrent writes

- `EMERGENCY_INFERENCE_LOCK`
  serializes shared emergency-model inference across threads

### 3.2 Per-Camera Processing

Each `CameraProcessor` thread owns the runtime for one road:

- `cam0` corresponds to `ROAD_1`
- `cam1` corresponds to `ROAD_2`

Each processor creates its own:

- vehicle detector
- plate detector
- centroid tracker
- plate cache
- CSV report
- plate log
- session summary
- emergency snapshot manager

### 3.3 AI Pipeline

For each processed frame, the service applies this pipeline:

1. open and normalize the source
2. resize for processing/display efficiency
3. compute the current signal state from the shared time reference
4. run emergency-vehicle detection
5. update the central road-open request state
6. run general vehicle detection
7. update centroid tracking
8. estimate per-track speed
9. detect stop-line crossing and red-light violation
10. trigger plate OCR only when overspeed or red-light violation occurs
11. append CSV rows and local logs

### 3.4 Controller Interface

The main controller handoff is file-based:

`exports/emergency_request.txt`

Payload format:

```text
road=0
ts=2026-04-17T15:42:10
```

Meaning:

- `road=1` means open `ROAD_1`
- `road=2` means open `ROAD_2`
- `road=0` means no active emergency request

This keeps the control-side integration simple and decoupled from the AI runtime.

## 4. Core Runtime Components

### 4.1 Signal Timing Logic

`DualRoadSignalController` models a two-phase signal cycle. By default:

- full cycle is `60` seconds
- each half is `30` seconds
- `cam0` is green first
- `cam1` is green second

The key design choice is that both the AI service and the traffic-light controller can compute the same signal state as long as they share the same `SIGNAL_REFERENCE_EPOCH`. They do not need to start at the same wall-clock moment.

### 4.2 Emergency Detection

`EmergencyDetector` loads a YOLO model and checks detections against known emergency labels such as:

- emergency vehicle
- ambulance
- police
- fire truck

The service smooths emergency decisions over time:

- three consecutive positive frames activate emergency state
- four missed frames clear it

This avoids noisy one-frame toggles.

### 4.3 Central Request Arbitration

The project already solves an important multi-camera problem: one camera clearing its own request must not erase the valid request from the other camera.

That behavior is handled by:

- `update_camera_request_state(...)`
- `recompute_and_write_central_request()`

Policy:

- request clear is delayed by a hold timer
- the newest active confirmed request wins
- the output file always contains one road code, not two competing writes

### 4.4 Vehicle Tracking And Violations

`VehicleDetector` finds vehicles of interest.

`CentroidTracker` assigns track IDs based on nearest-centroid matching with disappearance tolerance.

For each track, the service:

- stores historical positions
- estimates speed from pixel distance and FPS
- checks stop-line crossing
- flags red-light violations when the signal is red at crossing time

### 4.5 OCR Strategy

OCR is intentionally selective.

The project does not try to read every plate in every frame. Instead, OCR is triggered only when:

- overspeed is detected
- red-light violation is detected

This is a good deployment decision because it reduces compute load and avoids filling logs with low-value OCR attempts.

`ocr/ocr_reader.py` uses:

- PaddleOCR
- basic text normalization
- OCR character correction rules
- simple Tunisian and generic pattern validation
- multi-pass preprocessing attempts

## 5. Source Snapshot Included In This Bundle

The staged `source/` folder currently includes:

- Python runtime source
- `requirements.txt`
- `requirements-rpi.txt`
- bundled vehicle model
- bundled plate model
- bundled emergency ONNX model

The staged snapshot excludes live runtime output and development noise such as:

- `.git`
- `.vscode`
- `__pycache__`
- `uploads/`
- `exports/`

## 6. Output Structure

At runtime, each camera produces its own folder under `exports/`.

Expected outputs include:

- traffic CSV report per run
- plate OCR log CSV per run
- session summary text file
- event/run log text file
- saved plate crops
- emergency snapshots

There is also one shared output file:

- `exports/emergency_request.txt`

## 7. Yocto Packaging Direction

This bundle includes a first-pass Yocto layer skeleton under:

`meta-tr/`

The packaging approach is intentionally development-friendly:

- use `externalsrc`
- point the recipe at the staged `source/` folder
- install the source bundle into `/usr/share/traffic-ai-model`
- run it through a small launcher
- write runtime outputs into `/var/lib/traffic-ai-model`

One source-level improvement was already applied in the staged snapshot:

- `finish.py` now allows runtime/output directories to be redirected by environment variables

That change makes the service much more suitable for packaging.

## 8. Strengths In The Current Codebase

- Clear single-file orchestration that is easy to trace.
- Sensible separation between detectors, OCR, tracking, and utilities.
- Good use of atomic writes for the central request file.
- Practical debounce/hold logic for emergency requests across two cameras.
- Sensible OCR-on-demand policy instead of OCR on every object.
- Per-camera output folders make offline review much easier.

## 9. Risks And Gaps To Address

### 9.1 Signal Model Assumes Exactly Two Roads

The current code is correct for a two-road intersection, but it is not yet generalized for more lanes, turn phases, or adaptive timing.

### 9.2 Tracking Is Lightweight

`CentroidTracker` is efficient and easy to reason about, but it may struggle under occlusion, dense traffic, or abrupt direction changes.

### 9.3 Speed Calibration Is Global

Speed estimation uses a single `PIXEL_TO_METER` value. Real deployments usually need per-camera calibration or homography-based scaling.

### 9.4 OCR Validation Rules Are Narrow

The OCR layer includes Tunisian-oriented formatting assumptions plus a generic fallback. If the deployment location changes, the format validation rules should be updated.

### 9.5 Recipe Dependency Work Is Still Needed

The included Yocto recipe is a starter recipe. Final target dependency names for OpenCV, PaddleOCR, PyTorch/Ultralytics, and model runtime support will need adjustment for the exact distro and BSP.

## 10. Recommended Next Steps

1. Validate the staged source snapshot on the target board.
2. Confirm final camera device naming and stop-line calibration for both roads.
3. Add a hardware-facing traffic-light control integration test using `emergency_request.txt`.
4. Decide whether the service should remain file-triggered or move to ROS 2 topics, sockets, or D-Bus later.
5. Add sample recordings and bag-like replay inputs for repeatable regression testing.
