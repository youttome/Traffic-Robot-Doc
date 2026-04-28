# Traffic Robot App Tasks And Roadmap

## Phase 1: Documentation Baseline

- [x] Create project overview bundle in `traffic_robot_app/`
- [x] Create project report
- [x] Create file reference
- [x] Create Yocto integration guide
- [x] Create first-pass task list

## Phase 2: Source Snapshot Preparation

- [x] Copy a clean source snapshot into `traffic_robot_app/source`
- [x] Exclude `build/`, `CMakeFiles/`, `.qt/`, `.rcc/`, `.qtcreator/`, `.vscode/`, and caches
- [x] Confirm the snapshot still contains all required QML, assets, and backend source files
- [x] Add or confirm a source-level `.gitignore`

## Phase 3: Runtime Configuration Cleanup

- [ ] Decide whether the permanent default database path should remain external or move to `/var/lib/traffic-robot-app`
- [ ] Standardize the Street B topic name between `/cma_B` and `/cam_B`
- [ ] Confirm which files are product files versus prototypes or archived samples

## Phase 4: QML Validation

- [ ] Validate home page navigation
- [ ] Validate monitor page navigation
- [ ] Validate overview target page navigation
- [ ] Confirm no missing QML imports on the target image
- [ ] Confirm map rendering works with the target Qt Location plugin

## Phase 5: JSON Data Validation

- [ ] Launch once and confirm all six JSON files are created
- [ ] Edit `system_health.json` and confirm HUD updates
- [ ] Edit `monitor_ui.json` and confirm labels update
- [ ] Edit `robot_telemetry.json` and confirm map/telemetry updates
- [ ] Edit `signal_control.json` and confirm traffic control updates

## Phase 6: ROS 2 Validation

- [ ] Build with ROS 2 dependencies available
- [ ] Confirm `/cam_robot` image stream appears
- [ ] Confirm `/cam_A` image stream appears
- [ ] Confirm street B stream appears on the chosen final topic name
- [ ] Confirm `/street_ai_monitor` updates the AI panel
- [ ] Confirm the UI behaves correctly when publishers disappear

## Phase 7: Yocto Layer Integration

- [x] Create `meta-tr` starter layer structure
- [x] Create first-pass `traffic-robot-app.bb` recipe
- [ ] Add `meta-tr` to `BBLAYERS`
- [ ] Confirm `meta-qt6` is already in the build
- [ ] Build `bitbake traffic-robot-app`
- [ ] Add `traffic-robot-app` to the target image

## Phase 8: Yocto Runtime Validation

- [ ] Start the app on the target compositor
- [ ] Confirm `appCircleBarsUI` launches
- [ ] Confirm `traffic-robot-app` launcher sets the database path correctly
- [ ] Confirm OpenCV and Qt plugins are present on the image
- [ ] Confirm the font and image resources are embedded correctly

## Phase 9: Release Hardening

- [ ] Add a project license decision
- [ ] Decide whether to keep `left/` in the release snapshot
- [ ] Decide whether `Main50CircleBars.qml` and `Map_Robot.qml` stay as demos or move to an archive folder
- [ ] Document final deployment command for the target board
- [ ] Replace `externalsrc` with a reproducible Git or tarball source flow for release builds

## Recommended Immediate Next Tasks

1. Keep the `traffic_robot_app/source` snapshot in sync with the active app workspace.
2. Add the layer to the Yocto build and try `bitbake traffic-robot-app`.
3. Fix any missing Qt/QML runtime package issues on the image.
4. Resolve the Street B topic naming mismatch before hardware validation.
