# Project Report: Traffic Robot Qt/QML Monitoring App

## 1. Introduction

This project is a Qt 6 + QML monitoring dashboard for a traffic robot and smart intersection workflow. It is designed as an operator-facing application with three main responsibilities:

- display robot status and map telemetry
- display live or placeholder camera feeds
- provide a UI layer over live JSON data and optional ROS 2 traffic topics

The active source workspace reviewed for this report is:

`/home/abso/left/circlebarsui`

## 2. Technical Stack

- C++17
- CMake
- Qt 6 Quick / QML
- Qt Location and Qt Positioning in QML
- OpenCV
- Optional ROS 2 with `rclcpp`, `sensor_msgs`, and `std_msgs`
- Linux runtime data from `/proc/stat` and `/sys/class/power_supply`

## 3. High-Level Architecture

The application is split into four layers.

### 3.1 Bootstrap Layer

`main.cpp` creates and wires the runtime:

- `DataManager`
- `SystemMonitor`
- `TopBarController`
- `RosStreamManager`
- `CameraProvider`
- `RosStreamImageProvider`
- `QQmlApplicationEngine`

It also exposes the backend objects to QML through context properties:

- `dataManager`
- `systemMonitor`
- `rosStreams`
- `topBarData`

### 3.2 Local Data Layer

`DataManager` is the most important backend object for UI state persistence.

It:

- defines QML properties for traffic violations, priority vehicles, signal control, system health, monitor UI text, and robot telemetry
- creates default JSON files when missing
- watches the database directory with `QFileSystemWatcher`
- reloads changed files automatically
- writes updates back using `QSaveFile`

Tracked JSON files:

- `traffic_violations.json`
- `priority_vehicles.json`
- `signal_control.json`
- `system_health.json`
- `monitor_ui.json`
- `robot_telemetry.json`

### 3.3 Live Runtime Layer

Two classes provide non-JSON live data:

- `SystemMonitor`
  Reads CPU usage and battery level from Linux and feeds those values back into `DataManager`.

- `RosStreamManager`
  Subscribes to ROS 2 image and AI text topics when ROS 2 is available at build time.

`RosStreamManager` also supplies:

- online/offline state per stream
- FPS counters
- placeholder frames when no ROS topics are active
- QML image provider access through `image://roscam/...`

### 3.4 QML Presentation Layer

The QML side is organized as:

- a root stack-based window in `qml/Main.qml`
- a home dashboard in `qml/Main_window.qml`
- a monitor screen in `qml/monitor/Monitor_window.qml`
- an overview page in `qml/OverviewTargetPage.qml`
- reusable panels and widgets in `qml/` and `qml/monitor/`

## 4. Screen Structure

### 4.1 Main Navigation

`qml/Main.qml` owns a `StackView` with three page flows:

- home page
- monitor page
- overview target page

The home page uses:

- `Top_Bar.qml`
- `Left_Bar.qml`
- `MapView.qml`
- `Bottom_Bar.qml`

### 4.2 Monitor Page

`qml/monitor/Monitor_window.qml` is the operator-heavy screen. It combines:

- `HUDStatusBar.qml`
- `CameraNetwork.qml`
- `TrafficPanel.qml`
- `BottomBar.qml`
- `BottomBarRight.qml`

Inside `CameraNetwork.qml`, the UI shows:

- robot camera card
- street A camera card
- street B camera card
- map intelligence card
- AI side panel

### 4.3 Overview Page

`qml/OverviewTargetPage.qml` is a separate page focused on robot status, explanation text, target details, and operator notes.

### 4.4 Experimental / Alternate Files

The source tree also contains files that look like prototype or alternate UI paths:

- `qml/Main50CircleBars.qml`
- `qml/Map_Robot.qml`
- `left/` module files

These are worth keeping documented, but they should be clearly marked as:

- example assets
- prototypes
- not part of the main production route unless intentionally enabled

## 5. Runtime Data Flow

The current application uses four data paths.

### 5.1 File-Based UI Data

`DataManager` loads JSON from the database folder and exposes it to QML. QML panels bind directly to `dataManager` properties and update live when files change.

### 5.2 Live Machine Telemetry

`SystemMonitor` samples CPU and battery state, then `main.cpp` pushes those values into `DataManager::patchSystemHealth(...)`.

### 5.3 ROS 2 Camera And AI Topics

When built with ROS 2 support, `RosStreamManager` subscribes to:

- `/cam_robot`
- `/cam_A`
- `/cma_B`
- `/street_ai_monitor`

The topic names can be overridden with environment variables.

### 5.4 Local Camera Fallback

`CameraProvider` reads `/dev/video0` through OpenCV and provides `image://camera/...` frames. If no device exists, it returns a placeholder frame.

## 6. Strengths In The Current Codebase

- Clear separation between persisted JSON state and optional ROS 2 live streams.
- Good use of `QFileSystemWatcher` for live reload behavior.
- Helpful placeholder UI states when publishers or camera hardware are offline.
- UI wording is partly externalized into `monitor_ui.json`, which makes customization easier without rebuilding.
- The project already uses a modern Qt 6 CMake + `qt_add_qml_module(...)` structure.

## 7. Risks And Gaps To Address

These are the main risks discovered while preparing this report.

### 7.1 Hardcoded Default Database Path

`main.cpp` defaults to:

`/media/abso/project/database/monitor_app`

That path is convenient in local development but not ideal for a packaged Yocto image. A target-friendly default such as `/var/lib/traffic-robot-app` is safer.

### 7.2 Source Tree Contains Local Build Artifacts

The active workspace currently includes generated or local-only files such as:

- `build/`
- `CMakeFiles/`
- `.qt/`
- `.rcc/`
- `CMakeCache.txt`
- `Makefile`
- `.qtcreator/`
- `.vscode/`

These should not be treated as authoritative source when packaging for Yocto.

### 7.3 Main Build File Needs Yocto Validation

The project uses QML imports for:

- `QtQuick.Controls`
- `QtQuick.Layouts`
- `QtQuick.Effects`
- `QtQuick.Shapes`
- `QtLocation`
- `QtPositioning`
- `Qt5Compat.GraphicalEffects`

The target image must include the required runtime modules. If a specific BSP image is minimal, the app may launch and fail with missing QML import errors unless those modules are installed.

### 7.4 Experimental Files Need A Product Decision

The codebase contains two UI directions:

- the current traffic robot monitor flow in `qml/` and `qml/monitor/`
- the alternate `left/` module and some sample/demo files

Before release, the team should decide which files are product code and which are archive/demo code.

### 7.5 Topic Naming Is Slightly Inconsistent

The backend fallback for street B currently uses `/cma_B`, while some UI wording still refers to `/cam_B`. This should be unified before deployment.

## 8. Yocto Integration Strategy

The best first-pass Yocto strategy for this project is:

1. Keep the app source in:
   `/media/abso/yocto/traffic_robot/traffic_robot_app/source`
2. Add a custom layer:
   `/media/abso/yocto/traffic_robot/traffic_robot_app/meta-tr`
3. Build the app recipe with `meta-qt6` and `inherit qt6-cmake`
4. Use `externalsrc` during development so the recipe builds directly from the local source snapshot
5. Move to a Git or tarball source recipe later for release reproducibility

This approach fits the current request because it keeps:

- the app sources in the requested external directory
- the Yocto metadata near the project
- the Qt/QML build path aligned with official `meta-qt6` guidance

## 9. Recommended Immediate Work

1. Sync a clean source snapshot into `source/`.
2. Remove or ignore generated development artifacts from the packaged source.
3. Validate the app under Yocto with `meta-qt6`.
4. Decide whether the database path should move permanently to `/var/lib/traffic-robot-app`.
5. Verify every required QML module is present in the image.
6. Test the home and monitor navigation flows on the target compositor.

## 10. Conclusion

This is a solid operator dashboard foundation for a traffic robot product. The code already has good separation between UI, persisted state, and live ROS streams. The main work left is not fundamental architecture redesign. It is productization:

- clean packaging
- target runtime validation
- QML module verification
- consistent path/topic configuration

That makes it a strong candidate for integration into a custom Yocto layer.
