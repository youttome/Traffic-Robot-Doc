# File Reference: Traffic Robot App

This reference covers the maintained source files in the reviewed workspace and also notes the important generated/local files that should not normally be packaged as primary source.

Source workspace reviewed:

`/home/abso/left/circlebarsui`

## 1. Root Build And Entry Files

- `CMakeLists.txt`
  Main build definition. Configures Qt 6, OpenCV, optional ROS 2, the executable target, and the QML module.

- `main.cpp`
  Application entry point. Creates backend objects, sets the database path, registers image providers, and loads `Main.qml`.

- `README.md`
  Main project overview for the current workspace.

- `QUICKSTART.md`
  Fast local build and run instructions.

- `DATABASE_SETUP.md`
  JSON database schema and live reload behavior.

- `PROJECT_TASKS.md`
  Existing source-tree task checklist.

- `GITHUB_PUSH.md`
  Existing source-tree GitHub publishing guide.

## 2. C++ Backend Files

- `datamanager.h`
  Public interface for the JSON persistence layer exposed to QML.

- `datamanager.cpp`
  JSON file creation, load/save logic, patch/update methods, watcher synchronization, and default sample data.

- `rosstreammanager.h`
  Public interface for ROS camera and AI stream state exposed to QML.

- `rosstreammanager.cpp`
  ROS subscription setup, image conversion, placeholder frames, online/FPS state tracking, and QML image provider support.

- `systemmonitor.h`
  Public interface for Linux CPU and battery sampling.

- `systemmonitor.cpp`
  Reads `/proc/stat` and battery sysfs capacity files, then emits value changes.

- `camera.h`
  Defines the local OpenCV camera thread and image provider.

- `camera.cpp`
  Captures `/dev/video0` frames or returns an offline placeholder.

- `include/topbarcontroller.h`
  Declares the timer-based mission time, latency, and signal-strength controller used by the top bar.

- `src/topbarcontroller.cpp`
  Implements simulated mission timer, latency, and signal strength updates.

## 3. Main QML Files

- `qml/Main.qml`
  Root window and page navigation stack.

- `qml/Main_window.qml`
  Main landing dashboard page layout.

- `qml/Top_Bar.qml`
  Top mission/status bar used on the home page.

- `qml/Left_Bar.qml`
  Left-side mission, thermal, CPU, and telemetry HUD.

- `qml/Bottom_Bar.qml`
  Bottom action bar for overview navigation and emergency control.

- `qml/MapView.qml`
  Main map-centric home page panel with telemetry and situational visuals.

- `qml/OverviewTargetPage.qml`
  Separate overview/status page for mission context and target notes.

- `qml/Map_Robot.qml`
  Alternate map and camera prototype screen.

- `qml/Main50CircleBars.qml`
  Alternate sample/demo entry screen using multiple circle bars.

- `qml/CircleBar.qml`
  Reusable circular bar effect component.

- `qml/Arc_performance.qml`
  CPU/performance arc built on top of `CircleBar.qml`.

## 4. Monitor QML Files

- `qml/monitor/Monitor_window.qml`
  Main operator monitor page layout.

- `qml/monitor/CameraNetwork.qml`
  Top-left monitor area with three camera cards, the map intelligence card, and the AI panel.

- `qml/monitor/CameraCard.qml`
  Reusable camera display card with signal state and status text.

- `qml/monitor/MapIntelCard.qml`
  Map + telemetry panel driven by `robot_telemetry.json`.

- `qml/monitor/StreetAIPanel.qml`
  AI summary and queue panel driven by `rosStreams.aiSummary` and JSON-backed violations.

- `qml/monitor/TrafficPanel.qml`
  Largest operator control panel. Handles violations, priority vehicles, and signal mode/timing controls.

- `qml/monitor/HUDStatusBar.qml`
  Top HUD bar for system health, network, battery, date, time, and mission timer.

- `qml/monitor/BottomBar.qml`
  Bottom-left navigation strip for the monitor screen.

- `qml/monitor/BottomBarRight.qml`
  Bottom-right live ROS / robot / AI status summary strip.

## 5. QML Assets

- `qml/background.jpg`
  Background image asset.

- `qml/Qt-Development-white.png`
  Qt image asset inherited from the original sample.

- `qml/monofonto.otf`
  Custom font used by parts of the interface.

## 6. Experimental `left/` Module

These files appear to be a separate or earlier QML module path and are not the main app route loaded by `main.cpp`.

- `left/Main.qml`
  Standalone compact action/status bar prototype.

- `left/Left_Bar.qml`
  Earlier left-side panel design prototype.

- `left/qmldir`
  QML module descriptor for the `left` module.

- `left/appleft_qml_module_dir_map.qrc`
  Resource map file for the `left` QML module.

## 7. Generated And Local Files Seen In The Workspace

These files exist in the reviewed workspace but should be treated as generated, local, or packaging-noise unless you intentionally need them.

- `appleft_qmltyperegistrations.cpp`
  Generated QML type registration source.

- `build/`
  Build output directory.

- `CMakeFiles/`
  CMake-generated build metadata.

- `CMakeCache.txt`
  Local CMake cache.

- `Makefile`
  Local generated build file.

- `meta_types/`
  Generated metatype output.

- `qmltypes/`
  Generated QML type metadata.

- `.qt/`
  Qt-generated helper files and deployment data.

- `.rcc/`
  Generated resource cache output.

- `.qtcreator/`
  IDE-local settings.

- `.vscode/`
  Editor-local settings.

- `.git/`
  Version-control metadata.

## 8. Packaging Recommendation

For a clean Yocto source snapshot, keep:

- source `.cpp` and `.h`
- maintained `.qml`
- required assets
- `CMakeLists.txt`
- user-facing documentation you want to ship

Exclude:

- build output
- IDE settings
- generated caches
- machine-specific local files
