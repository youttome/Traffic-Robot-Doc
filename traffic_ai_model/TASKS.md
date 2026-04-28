# Traffic AI Model Tasks And Roadmap

## Phase 1: Documentation Baseline

- [x] Create project overview bundle in `traffic_ai_model/`
- [x] Create project report
- [x] Create node reference
- [x] Create file reference
- [x] Create Yocto integration guide
- [x] Create first-pass task list

## Phase 2: Source Snapshot Preparation

- [x] Create `traffic_ai_model/source`
- [x] Copy the current Python runtime source into the snapshot
- [x] Copy the required model weights into the snapshot
- [x] Exclude `.git`, `.vscode`, `__pycache__`, live `exports`, and live `uploads`
- [ ] Confirm whether any additional emergency-model metadata should be shipped or left out

## Phase 3: Runtime Packaging Cleanup

- [x] Add runtime directory override support to the staged `finish.py`
- [ ] Decide the final writable runtime path on target
- [ ] Add a sample `.env.example` for target deployment
- [ ] Decide whether camera sources should be passed by service file, launcher args, or environment variables

## Phase 4: Camera And Road Calibration

- [ ] Confirm final physical mapping for `cam0 -> ROAD_1`
- [ ] Confirm final physical mapping for `cam1 -> ROAD_2`
- [ ] Tune stop-line ratios for both cameras
- [ ] Validate `PIXEL_TO_METER` per camera
- [ ] Validate signal timing against the real controller reference epoch

## Phase 5: Detection And OCR Validation

- [ ] Confirm vehicle model performance on the real intersection scene
- [ ] Confirm plate model performance on the real camera angle
- [ ] Validate OCR behavior on the expected plate format
- [ ] Review `OCR_CORRECTIONS` and `PLATE_PATTERNS` for the target country
- [ ] Measure false positives on emergency detection

## Phase 6: Controller Integration

- [ ] Validate `exports/emergency_request.txt` with the traffic-light control script
- [ ] Confirm that request hold timing is acceptable for real emergency behavior
- [ ] Test both cameras requesting road opening in different orders
- [ ] Confirm the controller ignores `road=0` correctly
- [ ] Decide whether the file interface remains final or becomes a ROS 2/topic/service interface later

## Phase 7: Yocto Layer Integration

- [x] Create `meta-tr` starter layer structure
- [x] Create first-pass `traffic-ai-model.bb` recipe
- [ ] Add `traffic_ai_model/meta-tr` to `BBLAYERS`
- [ ] Build `bitbake traffic-ai-model`
- [ ] Validate model files are installed in the image
- [ ] Validate the launcher creates runtime folders correctly

## Phase 8: Runtime Validation On Target

- [ ] Run the service with two real camera sources
- [ ] Confirm all required Python dependencies exist on target
- [ ] Confirm OpenCV can open both cameras
- [ ] Confirm Ultralytics models load without missing runtime libraries
- [ ] Confirm PaddleOCR works within target memory limits
- [ ] Confirm CSV, logs, plate crops, and snapshots are written under `/var/lib/traffic-ai-model`

## Phase 9: Hardening

- [ ] Add structured health logging
- [ ] Add graceful shutdown handling for service managers
- [ ] Add a configurable max runtime or watchdog strategy if needed
- [ ] Add replay-mode tests with recorded traffic videos
- [ ] Add accuracy notes and operating limits to the final deployment manual

## Phase 10: Release Readiness

- [ ] Add final service startup instructions
- [ ] Add a systemd unit if the service should auto-start on boot
- [ ] Freeze final model versions
- [ ] Create a release snapshot with pinned dependencies
- [ ] Record a validation checklist for field deployment

## Recommended Immediate Next Tasks

1. Build the new `traffic-ai-model` recipe in Yocto.
2. Run the staged snapshot on the target with two camera sources.
3. Calibrate stop-line ratios and pixel-to-meter scaling for the real intersection.
4. Validate `emergency_request.txt` end to end with the traffic-light control logic.
