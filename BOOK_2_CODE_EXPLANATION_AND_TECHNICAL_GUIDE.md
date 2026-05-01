# Book 2: Code Explanation And Technical Guide

## 1. Book Identity

- Title: Code Explanation And Technical Guide for the Traffic Robot Graduation Project.
- Repository root used in this guide: `/media/abso/yocto/traffic_robot`.
- Main technical focus: source-code reading, runtime flow, build flow, and deployment-oriented interpretation.
- Intended audience: a first-time student reader, a teammate joining the project, a supervisor reviewing implementation depth, and a maintainer preparing deployment.
- Document goal: explain what each important file does, how the files relate, how the code should be used, and how the code fits into the complete Raspberry Pi and server architecture.
- Style goal: remain academically clear while staying close to the real code.
- Scope note: the guide explains the code that is present in the inspected repository snapshot as of May 1, 2026.
- Honesty note: where a requested subsystem is not present as source code in the repository, this guide states that clearly instead of inventing nonexistent implementation.

## 2. How To Read This Book

- Read Chapter 1 if you want a quick orientation before opening source files.
- Read Chapter 2 if you want the complete folder structure and file roles.
- Read Chapter 3 if you want to understand the runtime architecture before reading code.
- Read Chapters 4 through 10 if you want the application-side C++ and QML explanation.
- Read Chapters 11 through 17 if you want the AI-side Python explanation.
- Read Chapters 18 through 20 if you want ROS, JSON, and synchronization interpretation.
- Read Chapters 21 through 23 if you want Yocto and deployment explanation.
- Read Chapters 24 through 28 if you want debugging, performance, and maintenance guidance.
- Read the appendices if you want a file-by-file quick reference.
- If this is your first time with the project, do not start with the longest file.
- Start with the project entry points.
- The main application entry point is [main.cpp](/media/abso/yocto/traffic_robot/traffic_robot_app/source/main.cpp:1).
- The main AI entry point is [finish.py](/media/abso/yocto/traffic_robot/traffic_ai_model/source/finish.py:1).
- The main application build file is [CMakeLists.txt](/media/abso/yocto/traffic_robot/traffic_robot_app/source/CMakeLists.txt:1).
- The main packaging files are [traffic-ai-model.bb](/media/abso/yocto/traffic_robot/traffic_ai_model/meta-tr/recipes-traffic/traffic-ai-model/traffic-ai-model.bb:1) and [traffic-robot-app.bb](/media/abso/yocto/traffic_robot/traffic_robot_app/meta-tr/recipes-traffic/traffic-robot-app/traffic-robot-app.bb:1).
- After those, read [datamanager.h](/media/abso/yocto/traffic_robot/traffic_robot_app/source/datamanager.h:1), [datamanager.cpp](/media/abso/yocto/traffic_robot/traffic_robot_app/source/datamanager.cpp:1), [rosstreammanager.h](/media/abso/yocto/traffic_robot/traffic_robot_app/source/rosstreammanager.h:1), and [rosstreammanager.cpp](/media/abso/yocto/traffic_robot/traffic_robot_app/source/rosstreammanager.cpp:1).
- Then read the primary QML entry file [Main.qml](/media/abso/yocto/traffic_robot/traffic_robot_app/source/qml/Main.qml:1).
- Finally read the AI helper modules under `detectors`, `ocr`, `tracker`, and `utils`.

## 3. Top-Level Repository Structure

- `configuration/`
- Purpose: Raspberry Pi 4 and Raspberry Pi 5 configuration reports and task notes.
- Typical reader: build engineer or student responsible for Yocto setup.
- Main value: explains kernel, U-Boot, layer, and local-configuration decisions.

- `iot/`
- Purpose: IoT architecture notes, network interpretation, and server-side connectivity guidance.
- Typical reader: student responsible for device-to-server data flow.
- Main value: explains how Raspberry Pi field nodes connect to a monitor-side system.

- `ros2_autonoums/`
- Purpose: ROS 2 robot-side design notes and related explanations.
- Typical reader: robotics student working on simulation or node mapping.
- Main value: documents the robotics side even when all runtime code is not included in the same source tree.

- `traffic_ai_model/`
- Purpose: Python computer-vision and AI service plus Yocto packaging metadata.
- Typical reader: AI or edge-computing developer.
- Main value: performs vehicle detection, plate detection, OCR, tracking, speed reasoning, and emergency-priority export.

- `traffic_robot_app/`
- Purpose: Qt 6 and QML monitoring dashboard plus Yocto packaging metadata.
- Typical reader: UI developer, integration engineer, operator-interface maintainer.
- Main value: shows camera streams, system health, robot telemetry, AI summary, traffic incidents, and control state.

- `yocto/`
- Purpose: project-level Yocto reference materials.
- Typical reader: embedded Linux maintainer.
- Main value: preserves build and deployment structure as part of the graduation project.

## 4. Subsystem Map

- Subsystem 1: Embedded deployment layer.
- Main technologies: Yocto, BitBake, machine configuration, local configuration, package recipes.
- Main outcome: reproducible Raspberry Pi images and installed project packages.

- Subsystem 2: Monitor application.
- Main technologies: C++, Qt 6, QML, OpenCV, optional ROS 2 integration.
- Main outcome: operator dashboard for live streams, database-backed state, and mission visibility.

- Subsystem 3: AI traffic service.
- Main technologies: Python, OpenCV, Ultralytics YOLO, PaddleOCR, environment-driven configuration.
- Main outcome: detect vehicles, detect plates, read text, estimate speed, classify conditions, and export control hints.

- Subsystem 4: Database synchronization and IoT transport.
- Main technologies: JSON files, ROS 2 launch on the monitor side, server sync workspace.
- Main outcome: make edge-generated data visible to the monitor app and optionally send back control state.

- Subsystem 5: Robotics communication layer.
- Main technologies: ROS 2 topics, optional images, optional AI text summary.
- Main outcome: connect robot or street publishers to the monitor app without tightly coupling the UI to one sensor implementation.

## 5. Real Runtime Story

- On the application side, the binary starts in `main.cpp`.
- It creates a `QGuiApplication`.
- It optionally initializes ROS 2 if ROS support is compiled in.
- It constructs `DataManager`, `SystemMonitor`, `TopBarController`, and `RosStreamManager`.
- It exposes those objects to QML through the root context.
- It creates image providers for local camera and ROS camera streams.
- It loads the QML module `CircleBarsUI`.
- From that moment, QML becomes the visible UI and the C++ classes become data providers.

- On the AI side, the Python runtime starts in `finish.py`.
- It loads environment variables.
- It defines runtime directories.
- It prepares emergency-model paths.
- It creates shared state and locks.
- It uses helper modules for vehicle detection, plate detection, OCR, tracking, and speed estimation.
- It writes exports into runtime-controlled directories.
- It can write a compact emergency request file consumed by another part of the system.

- Between them, synchronized JSON files and ROS topics provide the data exchange layer.
- The monitor app uses JSON to load persistent operational state.
- The monitor app uses ROS topics to display live streams and live AI summary status.
- The server-side sync workspace bridges field and monitor databases.

## 6. Source Tree Of The Monitor Application

- Root source folder: `/media/abso/yocto/traffic_robot/traffic_robot_app/source`.
- Key C++ files:
- `main.cpp`
- `datamanager.h`
- `datamanager.cpp`
- `rosstreammanager.h`
- `rosstreammanager.cpp`
- `systemmonitor.h`
- `systemmonitor.cpp`
- `camera.h`
- `camera.cpp`
- `include/topbarcontroller.h`
- `src/topbarcontroller.cpp`

- Key build file:
- `CMakeLists.txt`

- Key UI files:
- `qml/Main.qml`
- `qml/Main_window.qml`
- `qml/OverviewTargetPage.qml`
- `qml/MapView.qml`
- `qml/monitor/Monitor_window.qml`
- `qml/monitor/CameraNetwork.qml`
- `qml/monitor/StreetAIPanel.qml`
- `qml/monitor/TrafficPanel.qml`
- `qml/monitor/CameraCard.qml`
- `qml/monitor/MapIntelCard.qml`
- `qml/monitor/HUDStatusBar.qml`
- `qml/monitor/BottomBar.qml`
- `qml/monitor/BottomBarRight.qml`

- Supporting resources:
- `qml/background.jpg`
- `qml/Qt-Development-white.png`
- `qml/monofonto.otf`

## 7. Source Tree Of The AI Service

- Root source folder: `/media/abso/yocto/traffic_robot/traffic_ai_model/source`.
- Main runtime entry:
- `finish.py`

- Detector modules:
- `detectors/vehicle_detector.py`
- `detectors/plate_detector.py`

- OCR module:
- `ocr/ocr_reader.py`

- Tracking module:
- `tracker/centroid_tracker.py`

- Utility modules:
- `utils/config.py`
- `utils/pre_process.py`
- `utils/speed_estimator.py`

- Model assets:
- `models/vehicle_yolo.pt`
- `models/plate_yolo.pt`
- `runs/detect/runs/emergency_detector/weights/best.onnx`

- Dependency descriptors:
- `requirements.txt`
- `requirements-rpi.txt`

## 8. Monitor Application Entry Point: `main.cpp`

### 8.1 Code Snippet

```cpp
#include <QGuiApplication>
#include <QDateTime>
#include <QDebug>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "systemmonitor.h"
#include "include/topbarcontroller.h"
#include <camera.h>
#include <datamanager.h>
#include <rosstreammanager.h>

#if APP_HAS_ROS2
#include <rclcpp/rclcpp.hpp>
#endif

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

#if APP_HAS_ROS2
    if (!rclcpp::ok()) {
        rclcpp::init(argc, argv);
    }
#endif

    DataManager dataManager;
    QObject::connect(&dataManager, &DataManager::errorOccurred, &app, [](const QString &error) {
        qWarning() << error;
    });

    const QString databasePath = qEnvironmentVariable(
        "MONITOR_APP_DB_PATH",
        "/media/abso/project/database/monitor_app");
    dataManager.setDatabasePath(databasePath);
```

### 8.2 Line-By-Line Explanation

- `#include <QGuiApplication>` imports the Qt class that starts a graphical application.
- `#include <QDateTime>` imports time support used later for telemetry timestamps.
- `#include <QDebug>` imports logging helpers such as `qWarning()`.
- `#include <QQmlApplicationEngine>` imports the object that loads QML files and creates the UI tree.
- `#include <QQmlContext>` imports the type used to expose C++ objects to QML.
- `#include "systemmonitor.h"` pulls in the application class that measures system health.
- `#include "include/topbarcontroller.h"` pulls in the top bar data provider class.
- `#include <camera.h>` pulls in the local camera image provider.
- `#include <datamanager.h>` pulls in the JSON database mediator.
- `#include <rosstreammanager.h>` pulls in the ROS stream and AI-summary mediator.
- `#if APP_HAS_ROS2` makes the ROS include conditional.
- `#include <rclcpp/rclcpp.hpp>` is only compiled when ROS 2 support is available.
- `int main(int argc, char *argv[])` defines the application entry point.
- `QGuiApplication app(argc, argv);` creates the Qt application object and stores command-line arguments.
- `if (!rclcpp::ok())` checks whether ROS 2 is already initialized.
- `rclcpp::init(argc, argv);` initializes ROS 2 when needed.
- `DataManager dataManager;` creates the backend object that loads and saves JSON data.
- `QObject::connect(...)` attaches the `errorOccurred` signal to a warning logger.
- This means file or parsing issues become visible in the terminal rather than staying silent.
- `qEnvironmentVariable("MONITOR_APP_DB_PATH", "/media/abso/project/database/monitor_app")` reads the database path from the environment and falls back to a development default.
- `dataManager.setDatabasePath(databasePath);` activates file creation, loading, and watching for that directory.

### 8.3 Second Snippet

```cpp
    SystemMonitor systemMonitor;
    TopBarController controller;
    RosStreamManager rosStreams;

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.rootContext()->setContextProperty("dataManager", &dataManager);
    engine.rootContext()->setContextProperty("systemMonitor", &systemMonitor);
    engine.rootContext()->setContextProperty("rosStreams", &rosStreams);
```

### 8.4 Explanation

- `SystemMonitor systemMonitor;` creates the backend object that measures CPU and battery-like status.
- `TopBarController controller;` creates the backend object that drives top-bar mission time, latency, and signal strength.
- `RosStreamManager rosStreams;` creates the backend object that tracks ROS camera streams and AI summary text.
- `QQmlApplicationEngine engine;` constructs the QML loader.
- `objectCreationFailed` is a safety signal emitted if the root QML object cannot be created.
- The lambda exits the application with `-1` if the QML tree fails to load.
- This prevents the app from staying half-alive in a broken state.
- `engine.rootContext()->setContextProperty("dataManager", &dataManager);` exposes `dataManager` as a global QML-visible object.
- `engine.rootContext()->setContextProperty("systemMonitor", &systemMonitor);` exposes the system monitor object to QML.
- `engine.rootContext()->setContextProperty("rosStreams", &rosStreams);` exposes ROS status and frames to QML.
- These three calls are crucial because much of the QML layer expects these exact names.

### 8.5 Third Snippet

```cpp
    const auto pushTelemetry = [&dataManager, &systemMonitor]() {
        dataManager.patchSystemHealth({
            {"cpuUsage", qRound(systemMonitor.performanceValue() * 100.0)},
            {"battery", systemMonitor.batteryValue()},
            {"lastUpdated", QDateTime::currentSecsSinceEpoch()},
        });
    };

    QObject::connect(&systemMonitor, &SystemMonitor::performanceValueChanged, &dataManager, pushTelemetry);
    QObject::connect(&systemMonitor, &SystemMonitor::batteryValueChanged, &dataManager, pushTelemetry);
    pushTelemetry();
```

### 8.6 Explanation

- `const auto pushTelemetry = ...` creates a lambda that writes system health into the JSON-backed data model.
- `patchSystemHealth` updates only selected keys without replacing the whole JSON object manually.
- `cpuUsage` is derived from `performanceValue()` and converted from normalized ratio to percentage.
- `battery` is taken from the system monitor.
- `lastUpdated` records when the patch was produced.
- Two signal connections call the same lambda whenever CPU usage or battery changes.
- `pushTelemetry();` also runs once immediately so the dashboard starts with real values instead of waiting for timer changes.
- This pattern is a clean example of bridging runtime signals into persisted or shareable state.

### 8.7 Fourth Snippet

```cpp
    engine.rootContext()->setContextProperty("topBarData", &controller);

    CameraProvider *provider = new CameraProvider();
    engine.addImageProvider("camera", provider);
    engine.addImageProvider("roscam", new RosStreamImageProvider(&rosStreams));

    engine.loadFromModule("CircleBarsUI", "Main");

    const int exitCode = app.exec();
```

### 8.8 Explanation

- `topBarData` becomes another QML-visible object.
- `CameraProvider *provider = new CameraProvider();` constructs a local camera image provider.
- `engine.addImageProvider("camera", provider);` makes local frames available as `image://camera/...` URLs in QML.
- `engine.addImageProvider("roscam", new RosStreamImageProvider(&rosStreams));` makes ROS frames available as `image://roscam/...`.
- `engine.loadFromModule("CircleBarsUI", "Main");` loads the QML module registered in `CMakeLists.txt`.
- `app.exec();` starts the Qt event loop.
- After this call, the application lives through signals, timers, file notifications, and ROS callbacks.

### 8.9 Final Shutdown Snippet

```cpp
#if APP_HAS_ROS2
    if (rclcpp::ok()) {
        rclcpp::shutdown();
    }
#endif

    return exitCode;
}
```

### 8.10 Explanation

- The program shuts down ROS 2 cleanly if it was initialized.
- Clean shutdown matters because background executors or subscriptions may otherwise remain in an undefined state.
- `return exitCode;` sends the Qt application result back to the operating system.

### 8.11 Why This File Matters

- `main.cpp` is the application’s real composition root.
- It does not contain business logic.
- Instead, it wires major subsystems together.
- When a student wants to understand where the dashboard gets its data, `main.cpp` is the best first file.
- When a student wants to change the database path, image providers, or backend-to-QML exposure, `main.cpp` is also one of the first places to inspect.

## 9. `DataManager` Header: `datamanager.h`

### 9.1 Architectural Role

- `DataManager` is the central file-backed state container for the dashboard.
- It owns the JSON schema that the UI consumes.
- It watches files for changes.
- It exposes QML-friendly properties.
- It offers update and patch functions.
- It prevents the QML layer from opening or saving files directly.
- This is a strong architectural decision because UI code stays focused on presentation, not persistence.

### 9.2 Important Properties

- `trafficViolations`
- `priorityVehicles`
- `signalControl`
- `systemHealth`
- `monitorUi`
- `robotTelemetry`
- `databasePath`

### 9.3 Why These Properties Exist

- `trafficViolations` backs the traffic incident list and AI event queue.
- `priorityVehicles` backs emergency-vehicle queue display.
- `signalControl` backs manual and AI mode settings and current direction state.
- `systemHealth` backs CPU, battery, and health indicators.
- `monitorUi` backs labels, titles, and wording used across the dashboard.
- `robotTelemetry` backs map, mission, and robot status panels.
- `databasePath` defines where all JSON files are stored.

### 9.4 Q_PROPERTY Interpretation

- Every `Q_PROPERTY` line makes a piece of backend state visible to QML.
- The `READ` part tells Qt which getter to use.
- The `NOTIFY` part tells Qt which signal is emitted when data changes.
- This allows QML bindings to update automatically.
- Example: when `robotTelemetryChanged()` is emitted, any QML binding that reads `dataManager.robotTelemetry` can refresh.

### 9.5 Q_INVOKABLE Functions

- `loadAllData()`
- `updateTrafficViolations(...)`
- `updatePriorityVehicles(...)`
- `updateSignalControl(...)`
- `updateSystemHealth(...)`
- `updateMonitorUi(...)`
- `updateRobotTelemetry(...)`
- `patchSignalControl(...)`
- `patchSystemHealth(...)`
- `patchMonitorUi(...)`
- `patchRobotTelemetry(...)`
- `addTrafficViolation(...)`
- `removeTrafficViolation(int index)`

### 9.6 Why `Q_INVOKABLE` Matters

- `Q_INVOKABLE` exposes a C++ method to the Qt meta-object system.
- In practice, that means QML can call the method.
- For example, a QML button can call `dataManager.addTrafficViolation(...)`.
- This is how the app UI can trigger data changes without reimplementing the storage logic in JavaScript.

### 9.7 Private Slots And Internal Functions

- `onFileChanged(...)` reacts when a watched file changes.
- `onDirectoryChanged(...)` reacts when the database directory changes.
- `processPendingReloads()` batches file reload work after a short delay.
- `trackedFilenames()` defines the official set of database files.
- `filePathFor(...)` converts a filename into a full path under the database directory.
- `defaultDataFor(...)` defines first-boot or fallback content for every file.
- `ensureDatabaseReady()` creates the directory when needed.
- `ensureJsonFileExists(...)` creates a missing JSON file with default content.
- `syncWatchPaths()` updates `QFileSystemWatcher` registrations.
- `scheduleReload(...)` starts delayed reloading.
- `reloadAllFiles()` reloads every tracked file.
- `reloadFile(...)` reloads one file.
- `loadJsonFile(...)` parses one file.
- `saveJsonFile(...)` serializes one file.

### 9.8 Design Lesson

- If you are new to Qt, `DataManager` is a good example of backend architecture.
- It converts raw storage concerns into properties and callable methods.
- This reduces QML complexity.
- It also makes debugging easier because the JSON contract has one authoritative C++ owner.

## 10. `DataManager` Implementation: `datamanager.cpp`

### 10.1 Constructor Behavior

- The constructor connects file and directory watcher signals to handler functions.
- It configures a reload timer as single-shot.
- The timer interval is `100` milliseconds.
- That means repeated rapid file changes can be grouped instead of reloading immediately for every event.
- This reduces churn.
- This is important because external synchronization tools may rewrite files quickly.

### 10.2 Tracked Files

- `traffic_violations.json`
- `priority_vehicles.json`
- `signal_control.json`
- `system_health.json`
- `monitor_ui.json`
- `robot_telemetry.json`

### 10.3 Why These Files Are Good Choices

- They map naturally to different functional concerns.
- Each file can be edited or synchronized independently.
- They are human-readable.
- They are simple to back up.
- They are simple to transport.
- They are easy to inspect during demonstrations.

### 10.4 Default Data For `traffic_violations.json`

- The default object is a `QVariantList`.
- Each entry is a `QVariantMap`.
- Each event contains:
- `color`
- `plate`
- `violation`
- `time`
- `timestamp`

### 10.5 Why Demo Violations Matter

- They let the UI show a meaningful panel on first launch.
- They provide a visible data schema example.
- They give students a concrete starting point when learning how UI bindings work.

### 10.6 Default Data For `priority_vehicles.json`

- The default file contains queue-like entries.
- Each entry has:
- `type`
- `distance`
- `level`
- `status`
- `color`
- `checked`

### 10.7 Meaning Of These Keys

- `type` names the priority vehicle.
- `distance` is a readable operator value.
- `level` encodes severity or priority ordering.
- `status` describes current interpretation.
- `color` supports UI emphasis.
- `checked` supports operator acknowledgment or state toggling.

### 10.8 Default Data For `signal_control.json`

- Default keys:
- `activeDir`
- `aiMode`
- `manualMode`
- `yellowDuration`
- `streetADuration`
- `streetBDuration`
- `lastUpdated`

### 10.9 Operational Meaning

- `activeDir` represents which street currently has priority.
- `aiMode` indicates AI-controlled mode.
- `manualMode` indicates operator-controlled mode.
- `yellowDuration` expresses transition timing.
- Street duration values support future or current timing logic.
- `lastUpdated` improves traceability.

### 10.10 Default Data For `monitor_ui.json`

- This file contains titles, subtitles, labels, and wording for many UI regions.
- The design is especially useful because it decouples UI language from code.
- That means a team can refine wording without recompiling.
- It also opens the door for localization later.

### 10.11 Important `monitor_ui.json` Sections

- `hud`
- `cameraNetwork`
- `cameraCards`
- `map`
- `aiPanel`
- `trafficPanel`
- `bottomBar`
- `bottomStatus`

### 10.12 Why This Is Smart

- Hard-coded strings inside QML can make iteration slow.
- Moving them to one JSON structure centralizes wording changes.
- It also means the UI can be adapted for demonstrations, languages, or operator roles with fewer code edits.

### 10.13 Default Data For `robot_telemetry.json`

- Default keys include:
- `label`
- `status`
- `movementState`
- `lat`
- `lon`
- `zoom`
- `missionTime`
- `routeState`
- `autonomyMode`
- `targetZone`
- `speedKph`
- `headingDeg`
- `headingLabel`
- `etaSeconds`
- `distanceMeters`
- `progress`
- `confidence`
- `signalQuality`
- `alerts`
- `trail`
- `lastUpdated`

### 10.14 Why This Schema Matters

- It is rich enough to support map views, numeric indicators, and mission summaries.
- It clearly anticipates a mobile robot rather than a static traffic sensor.
- It is also understandable without opening code.

### 10.15 `ensureDatabaseReady()`

- This function confirms the database path is non-empty.
- It creates the directory if it does not exist.
- It emits an error signal if creation fails.
- This is one of the most important safety functions in the class because every other operation depends on a valid directory.

### 10.16 Common `DataManager` Usage Pattern

- Set the database path once at startup.
- Let `DataManager` create missing files.
- Bind QML to exposed properties.
- Use `patch...()` functions for small updates.
- Use `update...()` functions for full replacement.
- Let file watchers react to external synchronization changes.

### 10.17 Why `patch...()` Methods Are Useful

- Replacing an entire JSON object for one small change is wasteful.
- Patch methods let the code change only specific keys.
- This reduces accidental key loss.
- It also makes backend logic easier to read.

### 10.18 Why The Class Is Central

- If the UI looks wrong, `DataManager` is one of the first files to inspect.
- If JSON files are malformed, `DataManager` is one of the first files to inspect.
- If external synchronization changes do not appear in the UI, `DataManager` is one of the first files to inspect.
- If the database path is wrong, `DataManager` is one of the first files to inspect.

## 11. `RosStreamManager` Header: `rosstreammanager.h`

### 11.1 Role

- `RosStreamManager` abstracts all ROS-facing dashboard behavior.
- It owns topic names.
- It tracks online status.
- It tracks frame rate estimates.
- It stores the latest frame per stream.
- It stores the latest AI summary text.
- It offers a `QQuickImageProvider` companion for QML image URLs.

### 11.2 Exposed Properties

- `rosAvailable`
- `robotTopic`
- `streetATopic`
- `streetBTopic`
- `aiTopic`
- `robotOnline`
- `streetAOnline`
- `streetBOnline`
- `aiOnline`
- `robotFps`
- `streetAFps`
- `streetBFps`
- `robotSignal`
- `streetASignal`
- `streetBSignal`
- `aiSummary`

### 11.3 Why These Properties Matter

- Topic names let the UI show self-describing information.
- Online booleans let the UI show live versus waiting states.
- FPS values let the operator infer whether a stream is active and healthy.
- Signal strings simplify binding to badge-like UI elements.
- `aiSummary` provides a text bridge from AI-side logic into the monitor panel.

### 11.4 Internal `StreamState`

- `id`
- `topic`
- `title`
- `frame`
- `online`
- `fps`
- `pendingFrames`
- `lastFrameMs`

### 11.5 Why `StreamState` Is Useful

- It packages all per-stream fields together.
- This reduces parallel arrays or repetitive per-stream variables.
- It makes it easier to scale from one stream to multiple streams.
- It also makes generic helper functions possible.

### 11.6 ROS Conditional Compilation

- `#if APP_HAS_ROS2` appears in the header.
- This means the app can still compile when ROS headers are not installed.
- This is helpful for development environments that only want to test UI and JSON behavior.

### 11.7 Header-Level Design Lesson

- This header reveals a strong interface-first design.
- QML does not need to know how ROS messages are decoded.
- It only needs a clean list of properties and a frame request function.

## 12. `RosStreamManager` Implementation: `rosstreammanager.cpp`

### 12.1 Placeholder Rendering

- The file begins with helper functions in an anonymous namespace.
- `placeholderFrame(...)` builds a synthetic image.
- The image says which stream is expected and that the topic is still waiting.
- This is excellent operator experience because a black rectangle alone would not explain anything.

### 12.2 Image Conversion Helper

- `imageFromMat(const cv::Mat &mat)` converts OpenCV images into `QImage`.
- It handles `CV_8UC3`, `CV_8UC1`, and `CV_8UC4`.
- This matters because ROS image conversions or other image paths can yield different channel formats.
- Returning a copied `QImage` is safer than exposing raw buffer ownership outside the function.

### 12.3 Constructor Defaults

- `m_robotTopic` defaults to `/cam_robot`.
- `m_streetATopic` defaults to `/cam_A`.
- `m_streetBTopic` defaults to `/cma_B`.
- `m_aiTopic` defaults to `/street_ai_monitor`.
- `m_aiSummary` starts with a waiting message built from the AI topic.
- `initializePlaceholders()` creates initial frames.
- A `QTimer` refreshes stream states every second.
- ROS subscriptions are only set up if ROS support exists.

### 12.4 Important Observation

- The fallback topic for Street B appears as `/cma_B`.
- In other places the project conceptually refers to Street B as `/cam_B`.
- This inconsistency should be resolved project-wide.
- Until it is resolved, the report and deployment notes should mention it explicitly.

### 12.5 `signalFor(...)`

- Returns `"LIVE"` when a stream is online.
- Returns `"WAITING"` when it is offline.
- This is a small helper, but it keeps QML simpler and standardizes wording.

### 12.6 `frameFor(...)`

- Looks up the frame for a stream.
- Falls back to a placeholder if no frame exists.
- Scales the frame when a requested size is provided.
- This makes the image provider robust and reusable across different UI panels.

### 12.7 `updateStreamFrame(...)`

- Replaces the stored `QImage` for a stream.
- Updates internal stream state under a mutex.
- This is critical because frames may arrive from a ROS callback thread.

### 12.8 Why Mutexes Matter Here

- QML reads frames from the UI thread.
- ROS callbacks may update frames from another thread.
- Without a mutex, data races could corrupt images or crash the application.

### 12.9 `refreshStreamStates()`

- This slot runs on a timer.
- It can downgrade streams from live to waiting when no recent frames arrive.
- It can also update FPS based on pending frame counts and elapsed time.
- This keeps visual status close to actual runtime behavior.

### 12.10 Conceptual ROS Subscription Flow

- A ROS image message arrives.
- The callback converts it into `QImage`.
- The class stores the new frame.
- Timestamps and counters are updated.
- The UI image provider later serves that latest frame to QML.
- QML periodically refreshes image URLs, causing the provider to re-read the latest frame.

### 12.11 Why The Image Provider Pattern Is Good

- QML already understands image URLs.
- `QQuickImageProvider` gives a natural bridge from backend memory to UI image elements.
- This avoids inventing a custom pixel-transfer mechanism inside QML.

### 12.12 AI Summary Handling

- The class also tracks a text summary channel.
- This is useful because AI information is not always best represented as an image.
- Sometimes the monitor only needs a concise explanation or incident summary.
- A text topic is lighter and often easier to debug than image overlays.

## 13. `SystemMonitor` Header And Implementation

### 13.1 Purpose

- `SystemMonitor` gives the dashboard a local sense of system status.
- It is not a full hardware-monitoring framework.
- It is a lightweight source for CPU and battery-like indicators.
- That is appropriate for a dashboard prototype.

### 13.2 Exposed Properties

- `performanceValue`
- `batteryValue`

### 13.3 Timer Strategy

- CPU is updated every 1 second.
- Battery is updated every 5 seconds.
- These are reasonable intervals for a dashboard.
- They are frequent enough to feel live.
- They are not so frequent that they create unnecessary overhead.

### 13.4 CPU Reading Logic

- The class reads `/proc/stat`.
- It parses the line that starts with `cpu `.
- It extracts user, nice, system, idle, iowait, irq, and softirq counters.
- It computes total difference between current and previous samples.
- It computes idle difference.
- It calculates usage as active time divided by total elapsed time.
- It clamps the result between `0.0` and `100.0`.

### 13.5 Why This Is Reasonable

- `/proc/stat` is a standard lightweight Linux source.
- No extra libraries are required.
- The logic is transparent and teachable.

### 13.6 Battery Reading Logic

- The class tries:
- `/sys/class/power_supply/BAT0/capacity`
- `/sys/class/power_supply/BAT1/capacity`
- `/sys/class/power_supply/BAT2/capacity`

- If none are available, it logs a warning and keeps the previous value.
- This is a pragmatic fallback for systems without a standard battery interface.

### 13.7 Why This Matters In A Pi Project

- Raspberry Pi devices often do not present laptop-style battery entries.
- Therefore the class behaves more like a generic health provider than a guaranteed true battery sensor.
- For a graduation project, this is acceptable if documented clearly.

## 14. `Camera` And `CameraProvider`

### 14.1 Purpose

- `Camera` is a local-camera thread based on OpenCV.
- `CameraProvider` is a Qt image provider that exposes that local camera to QML.
- This is separate from ROS stream handling.
- That separation is useful because local device cameras and remote ROS cameras serve different roles.

### 14.2 Placeholder Strategy

- If `/dev/video0` does not exist, the camera thread returns early.
- `CameraProvider` still exposes a placeholder image.
- That placeholder clearly says `CAMERA OFFLINE`.
- It also explains that JSON synchronization remains active.
- This is a thoughtful usability detail.

### 14.3 Frame Capture Logic

- OpenCV opens camera index `0` with `cv::CAP_V4L2`.
- Frames are captured in a loop.
- Empty frames are skipped with a short sleep.
- Frames are converted from BGR to RGB.
- A `QImage` is created from the frame.
- A copied image is emitted through the `frameReady` signal.

### 14.4 Threading Note

- `Camera` inherits `QThread`.
- `frameReady` is emitted from that worker thread.
- `CameraProvider` stores the latest frame under a mutex.
- This is a common and acceptable Qt pattern for simple capture workers.

### 14.5 Why This File Exists Even With ROS

- Local camera support is still useful for testing.
- It may also support direct on-device UI use cases where ROS transport is unnecessary.
- Keeping it separate avoids forcing all image flow through ROS.

## 15. `TopBarController`

### 15.1 Purpose

- `TopBarController` feeds high-level top-bar indicators.
- It tracks mission time.
- It simulates latency.
- It simulates signal strength.

### 15.2 Why This Class Is Helpful

- It isolates top-bar state from the rest of the application.
- It gives the UI something dynamic to display even if real network telemetry is not yet wired.
- It can later be replaced or extended with real network metrics.

### 15.3 Implementation Notes

- Mission time increments every second.
- Latency is randomly simulated every 500 ms.
- Signal strength is randomly simulated every 2 seconds.
- Values are exposed as Qt properties.

### 15.4 Important Honesty Note

- This class currently simulates values rather than reading real network measurements.
- That is fine for a prototype or teaching UI behavior.
- It should be described honestly in academic documentation.

## 16. Build System: `CMakeLists.txt`

### 16.1 Why This File Matters

- It defines how the monitor application is built.
- It registers source files.
- It registers QML files and resources.
- It checks whether ROS support is available.
- It links Qt, OpenCV, and optional ROS libraries.

### 16.2 Key Design Choices

- `CMAKE_CXX_STANDARD 17` selects modern C++.
- `find_package(Qt6 6.5 REQUIRED COMPONENTS Quick Core Gui)` declares the Qt requirement.
- `find_package(OpenCV REQUIRED)` declares OpenCV as mandatory.
- `find_package(rclcpp QUIET)` and related calls make ROS optional rather than mandatory.
- `APP_HAS_ROS2` becomes `ON` only when all ROS packages are found.
- `qt_add_qml_module` registers the QML module `CircleBarsUI`.
- `target_compile_definitions(... APP_HAS_ROS2=...)` exposes the ROS availability result to C++ code.

### 16.3 Why Optional ROS Compilation Is Smart

- It lets developers work on the UI even without ROS installed.
- It supports simpler desktop testing.
- It lowers the barrier for new contributors.

### 16.4 QML Registration

- `qt_add_qml_module` is the reason `engine.loadFromModule("CircleBarsUI", "Main")` works.
- It packages QML files and resources together in a modern Qt build flow.

## 17. QML Entry Point: `Main.qml`

### 17.1 Code Snippet

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import "monitor"

Window {
    id: root
    visible: true
    width: Screen.width
    height: Screen.height
    title: "TRAFFIC ROBOT MONITORING"
    color: "#04070c"
    visibility: Qt.platform.os == "android" ? Window.FullScreen : Window.Windowed
```

### 17.2 Explanation

- `pragma ComponentBehavior: Bound` controls component behavior in modern QML.
- `import QtQuick` imports the core QML visual system.
- `import QtQuick.Controls` imports standard UI controls like `Button`.
- `import QtQuick.Controls.Material` imports Material styling helpers.
- `import "monitor"` makes the `monitor` subdirectory QML files directly available.
- `Window` is the application root.
- `visible: true` shows the window.
- `width: Screen.width` and `height: Screen.height` attempt full-screen sizing based on the display.
- `title` sets the operating-system window title.
- `color: "#04070c"` defines a dark background.
- The `visibility` line switches to fullscreen on Android.

### 17.3 Navigation Strategy

- `Main.qml` uses a `StackView`.
- `page1` is a main landing page.
- `page2` is a monitor page.
- `page3` is an overview-target page.
- Transitions are animated horizontally.
- This gives the UI a multi-page application feel.

### 17.4 Why `StackView` Is A Good Choice

- It is simpler than managing multiple windows.
- It supports forward and back navigation naturally.
- It is appropriate for dashboards that have an overview page and a detail page.

### 17.5 Backend Bindings Visible In `Main.qml`

- `systemMonitor.performanceValue`
- `systemMonitor.batteryValue`
- `openMonitorPageAction`
- `openOverviewTargetPageAction`

### 17.6 Design Lesson

- `Main.qml` is mostly orchestration.
- It decides navigation and top-level page composition.
- It does not implement deep business logic.
- That is good architecture.

## 18. `Monitor_window.qml`

### 18.1 Purpose

- This file arranges the monitor dashboard into three major regions:
- top bar
- middle section
- bottom bar

### 18.2 Layout Meaning

- The top bar hosts `HUDStatusBar`.
- The middle left region hosts `CameraNetwork`.
- The middle right region hosts `TrafficPanel`.
- The bottom left region hosts `BottomBar`.
- The bottom right region hosts `BottomBarRight`.

### 18.3 Why This Matters

- The file acts as a layout composer.
- It does not own the content logic of each panel.
- This makes panel components reusable and easier to maintain.

## 19. `CameraNetwork.qml`

### 19.1 Purpose

- This file presents the live camera and AI network section.
- It combines:
- section title
- section subtitle
- live-count badge
- robot camera card
- street A camera card
- street B camera card
- map intelligence card
- street AI side panel

### 19.2 Important Runtime Fields

- `networkUi`
- `cardUi`
- `robotUi`
- `streetAUi`
- `streetBUi`
- `liveCount`
- `frameSeed`

### 19.3 Why `frameSeed` Exists

- A timer updates `frameSeed` every 250 ms.
- QML image URLs append `?` plus that changing value.
- This forces the image provider path to refresh.
- It is a simple technique for polling the latest in-memory image.

### 19.4 Why This File Is Strong

- It fuses JSON-driven wording and ROS-driven live status in one clean component.
- It demonstrates a real mixed-data UI pattern.

## 20. `StreetAIPanel.qml`

### 20.1 Purpose

- This file is the textual and status-oriented AI panel.
- It shows:
- AI topic name
- AI live/waiting badge
- summary text
- stream status lines
- incident queue preview

### 20.2 Key Bound Data

- `rosStreams.aiOnline`
- `rosStreams.aiSummary`
- `rosStreams.robotSignal`
- `rosStreams.streetASignal`
- `rosStreams.streetBSignal`
- `dataManager.trafficViolations`
- `dataManager.monitorUi.aiPanel`

### 20.3 Good Design Choices

- It falls back to a waiting message when no AI summary exists.
- It limits the repeated incident cards to the first three events.
- It draws incident colors from the stored event data.
- It uses separate stream lines for robot and street cameras.

### 20.4 Why This File Is Important

- It is where the human-readable AI story becomes visible.
- Many projects stop at raw detections.
- This panel attempts to turn detections into operationally useful information.

## 21. `TrafficPanel.qml`

### 21.1 Purpose

- This file is one of the most operationally important QML components.
- It displays violations.
- It displays priority vehicles.
- It displays traffic-signal mode and control-related state.
- It also allows demo event insertion and event clearing.

### 21.2 Internal Functions

- `syncSignalFromDatabase()`
- `persistSignalControl()`
- `addDemoViolation()`
- `updateVehicleChecked(index, checked)`

### 21.3 `syncSignalFromDatabase()`

- Reads signal-control values from `dataManager.signalControl`.
- Updates local QML properties:
- `activeDir`
- `aiMode`
- `manualMode`
- `yellowDuration`
- Uses `syncingSignal` to avoid recursive persistence loops.

### 21.4 `persistSignalControl()`

- Writes selected signal-control values back through `dataManager.patchSignalControl(...)`.
- Avoids writing while a synchronization refresh is in progress.
- This is a solid example of two-way binding with explicit guard logic.

### 21.5 `addDemoViolation()`

- Picks a template event color and message.
- Generates a pseudo plate value.
- Uses current time.
- Inserts the event through `dataManager.addTrafficViolation(...)`.
- This is useful for UI demos and quick testing.

### 21.6 `updateVehicleChecked(...)`

- Clones the vehicle list.
- Modifies the targeted entry.
- Sends the full list back through `dataManager.updatePriorityVehicles(...)`.
- This pattern is common in QML when mutating list-based data structures.

### 21.7 Why This Component Is Good For Students

- It shows real QML interaction logic.
- It mixes display code with limited state-management logic.
- It demonstrates how to avoid infinite update loops.
- It shows how C++ backend methods are called from QML.

## 22. Other QML Files

- `CameraCard.qml`: shows one camera frame and related metadata.
- `MapIntelCard.qml`: likely combines map and mission intelligence visuals.
- `HUDStatusBar.qml`: likely presents compact top-bar status.
- `BottomBar.qml`: likely presents bottom navigation or summary data.
- `BottomBarRight.qml`: likely presents compact status metrics.
- `MapView.qml`: likely renders robot location and route context.
- `OverviewTargetPage.qml`: likely provides a separate overview-oriented screen.
- `Main_window.qml`: likely represents the landing page rather than the live monitor page.
- `CircleBar.qml`, `Arc_performance.qml`, `Top_Bar.qml`, `Left_Bar.qml`, `Bottom_Bar.qml`, and `Main50CircleBars.qml` suggest an earlier or alternate UI style still preserved in the source tree.

### 22.1 Why Preserving Older UI Files Can Still Be Useful

- They preserve experimentation history.
- They may provide reusable components.
- They can support alternate demonstrations.
- They also show the evolution of the project’s visual design.

## 23. Python AI Entry Point: `finish.py`

### 23.1 What This File Does

- It is the main orchestrator for AI runtime behavior.
- It loads environment variables.
- It defines directories.
- It configures model paths.
- It defines emergency-state locks and shared data.
- It imports detector, tracker, OCR, and speed-estimation helpers.
- It writes or appends export files.
- It coordinates multi-camera emergency request logic.

### 23.2 Why This File Is The AI Composition Root

- Like `main.cpp` in the application, `finish.py` is not just one algorithm.
- It is the place where many smaller AI and runtime concerns are assembled.
- That makes it the best first file on the AI side.

### 23.3 Top Snippet

```python
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
```

### 23.4 Explanation

- `os` supports filesystem and environment operations.
- `time` supports timestamps and hold logic.
- `csv` suggests export or logging support.
- `argparse` suggests command-line argument parsing.
- `threading` supports concurrency and locks.
- `tempfile` supports safe temporary file creation.
- `traceback` supports richer error reporting.
- `defaultdict` and `deque` support structured in-memory tracking.
- `datetime` supports readable timestamps.
- `load_dotenv()` allows `.env`-style environment loading in development.
- `cv2` is OpenCV.
- `YOLO` from `ultralytics` is the high-level detector interface.

### 23.5 Runtime Directory Snippet

```python
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
RUNTIME_DIR = os.path.abspath(os.getenv("TRAFFIC_AI_RUNTIME_DIR", BASE_DIR))
UPLOAD_DIR = os.path.abspath(os.getenv("TRAFFIC_AI_UPLOAD_DIR", os.path.join(RUNTIME_DIR, "uploads")))
EXPORT_DIR = os.path.abspath(os.getenv("TRAFFIC_AI_EXPORT_DIR", os.path.join(RUNTIME_DIR, "exports")))
```

### 23.6 Explanation

- `BASE_DIR` is the folder containing `finish.py`.
- `RUNTIME_DIR` defaults to `BASE_DIR` unless overridden.
- `UPLOAD_DIR` is a runtime child directory for incoming or staged inputs.
- `EXPORT_DIR` is a runtime child directory for outputs.
- These values are environment-driven, which is excellent for deployment flexibility.
- During Yocto packaging, the runtime wrapper can redirect these paths to writable target locations.

### 23.7 Emergency Model Path Snippet

```python
DEFAULT_EMERGENCY_MODEL_PATH = os.path.join(
    BASE_DIR, "runs", "detect", "emergency_detector", "weights", "best.onnx"
)
FALLBACK_EMERGENCY_MODEL_PATH = os.path.join(
    BASE_DIR, "runs", "detect", "runs", "emergency_detector", "weights", "best.onnx"
)
EMERGENCY_MODEL_PATH = os.getenv("EMERGENCY_MODEL_PATH", DEFAULT_EMERGENCY_MODEL_PATH)
```

### 23.8 Explanation

- The file anticipates that the emergency model may exist in more than one location.
- This is a practical sign that the project evolved over time.
- `EMERGENCY_MODEL_PATH` can be overridden from the environment.
- If the preferred path does not exist, the code searches fallback candidates.
- This increases robustness when directory layout shifts.

### 23.9 Shared State Snippet

```python
EMERGENCY_FILE_LOCK = threading.Lock()
EMERGENCY_INFERENCE_LOCK = threading.Lock()
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
```

### 23.10 Explanation

- `EMERGENCY_FILE_LOCK` protects file writing for the central request file.
- `EMERGENCY_INFERENCE_LOCK` protects model inference if shared threading makes it necessary.
- `REQUEST_STATE_LOCK` protects shared per-camera state.
- `REQUEST_STATE` keeps one state object per camera.
- `road_name` identifies the logical road linked to that camera.
- `request_active` tracks whether that camera currently wants an emergency opening.
- `hold_until` delays clearing.
- `last_confirmed_at` supports recency-based arbitration.

### 23.11 Why This Matters

- AI systems connected to operational outputs must avoid noisy rapid toggling.
- The hold and arbitration logic in `finish.py` shows awareness of that real-world problem.

### 23.12 Atomic Write Snippet

```python
def write_text_file_atomic(path: str, content: str):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    fd, tmp_path = tempfile.mkstemp(dir=os.path.dirname(path), prefix=".tmp_", text=True)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            f.write(content)
            f.flush()
            os.fsync(f.fileno())
        os.replace(tmp_path, path)
```

### 23.13 Explanation

- The function ensures the target directory exists.
- It creates a temporary file in the same directory.
- It writes content fully to that temporary file.
- It flushes and fsyncs the file to reduce incomplete-write risk.
- It atomically replaces the target path with the new temporary file.
- This is a strong pattern for synchronization-friendly file writing.

### 23.14 `write_central_request_payload(...)`

- Converts road names into compact codes.
- Writes:
- `road=...`
- `ts=...`
- This minimal format is easy to inspect and easy for a downstream control component to parse.

### 23.15 `recompute_and_write_central_request()`

- Reads all active camera requests.
- Selects the most recent confirmed one.
- Writes that selected road to the central request file.
- If no requests are active, writes none.

### 23.16 Why Recency Arbitration Is Reasonable

- If multiple cameras can demand priority, the system needs one deterministic rule.
- Recency is simple.
- Recency is explainable.
- Recency is easy to debug.

### 23.17 `update_camera_request_state(...)`

- Sets request state active when a condition is true.
- Extends `hold_until` to avoid immediate clearing.
- Clears only after the hold window expires.
- Recomputes the central result afterward.
- This is debouncing for operational AI output.

## 24. `vehicle_detector.py`

### 24.1 Complete Snippet

```python
from ultralytics import YOLO
from utils.config import VEHICLE_MODEL_PATH
import torch

# vehicle class IDs based on COCO dataset
VEHICLE_CLASSES = [2, 3, 5, 7] # car, motorcycle, bus, truck

class VehicleDetector:
    def __init__(self):
         # Allow Ultralytics model deserialization
        torch.serialization.add_safe_globals([
            torch.nn.Module
        ])

        self.model = YOLO(VEHICLE_MODEL_PATH) # load YOLO model
        self.model.to("cpu") # move model to CPU

    def detect(self, frame):
        results = self.model(
            frame , # source image
            classes=VEHICLE_CLASSES, # filter only vehicle classes
            conf=0.35, # confidence threshold
            verbose=False # disable verbose output
        ) # get detections

        result = results[0] # results for first (and only) image
        
        # extract bounding boxes
        rects = []
        for box in result.boxes:
                x1, y1, x2, y2 = box.xyxy[0].cpu().tolist() # get box coordinates
                rects.append((int(x1), int(y1), int(x2), int(y2))) # append as integer tuple

        return rects
```

### 24.2 Line-By-Line Explanation

- `from ultralytics import YOLO` imports the model wrapper used for inference.
- `from utils.config import VEHICLE_MODEL_PATH` imports a configurable model path.
- `import torch` imports PyTorch support.
- `VEHICLE_CLASSES = [2, 3, 5, 7]` filters detections to common road vehicles.
- `class VehicleDetector:` wraps model ownership and detection behavior in one object.
- `def __init__(self):` initializes the detector once.
- `torch.serialization.add_safe_globals([torch.nn.Module])` allows model deserialization in the current environment.
- `self.model = YOLO(VEHICLE_MODEL_PATH)` loads the actual trained model.
- `self.model.to("cpu")` explicitly moves it to CPU, which matches Raspberry Pi edge deployment.
- `def detect(self, frame):` defines one detection pass.
- `results = self.model(...)` runs inference.
- `frame` is the input image.
- `classes=VEHICLE_CLASSES` reduces unwanted detection classes.
- `conf=0.35` rejects low-confidence boxes.
- `verbose=False` keeps runtime output cleaner.
- `result = results[0]` selects the first image result because the code assumes one image at a time.
- `rects = []` prepares a plain Python list for output.
- `for box in result.boxes:` iterates through detected bounding boxes.
- `box.xyxy[0]` extracts bounding box coordinates.
- `.cpu().tolist()` ensures a normal Python list on CPU memory.
- The coordinates are cast to integers.
- A tuple `(x1, y1, x2, y2)` is appended.
- `return rects` gives the rest of the AI pipeline a simple box list rather than a framework-specific object.

### 24.3 Design Lesson

- This file is intentionally thin.
- That is good.
- Detector wrappers should be simple.
- They should translate from a heavy library API into a project-specific minimal output format.

## 25. `plate_detector.py`

### 25.1 Main Role

- Detect the license-plate region inside a cropped vehicle image.
- Unlike vehicle detection, this stage usually expects a smaller search area.
- The output is one best bounding box or `None`.

### 25.2 Important Logic

- Load the model from `PLATE_MODEL_PATH`.
- Run inference on the vehicle crop.
- If no boxes exist, return `None`.
- Choose the box with the highest confidence.
- Return integer coordinates.

### 25.3 Why Choose One Best Box

- OCR generally works on one plate crop at a time.
- The code assumes the best-confidence plate candidate is the correct one.
- This is a reasonable simplification for a controlled prototype.

### 25.4 Practical Interpretation

- First detector finds vehicles.
- Second detector zooms into one vehicle.
- OCR then reads the best available plate crop.
- This staged design is more efficient and cleaner than running OCR on the whole scene.

## 26. `ocr_reader.py`

### 26.1 Role

- This file handles OCR text extraction and validation.
- It uses PaddleOCR.
- It normalizes text.
- It applies correction rules.
- It validates plate formats.
- It returns structured OCR results rather than a raw string only.

### 26.2 Why This File Is Strong

- It acknowledges that OCR is noisy.
- It captures confidence.
- It preserves raw text.
- It preserves corrected text.
- It preserves validation status.
- It preserves error reasons.
- That is much better than returning a plain string.

### 26.3 `OCRResult`

- `plate_number`
- `raw_text`
- `confidence`
- `validated`
- `corrections`
- `errors`

### 26.4 Why `OCRResult` Is Good Design

- It makes downstream reasoning easier.
- It separates “what was read” from “how trustworthy it is.”
- It supports explainable AI behavior.

### 26.5 OCR Pipeline Summary

- Reject empty images.
- Convert BGR to RGB.
- Run OCR.
- Reject no-text results.
- Extract text and confidence.
- Clean the text.
- Reject too-short values.
- Reject low-confidence values as validated outputs.
- Apply correction rules.
- Validate against known patterns.
- Return structured metadata.

### 26.6 Why Students Should Study This File

- It is a good example of post-processing around a machine-learning model.
- Real projects rarely use model output directly.
- They validate, normalize, and structure the results.

## 27. `centroid_tracker.py`

### 27.1 Role

- Track detected objects across frames using centroids.
- This gives temporary identities without requiring a heavy tracker.
- It is useful for speed estimation and event continuity.

### 27.2 Core State

- `next_object_id`
- `objects`
- `disappeared`
- `max_disappeared`
- `max_distance`

### 27.3 Update Cases

- Case 1: no detections this frame.
- Case 2: no tracked objects yet.
- Case 3: both existing tracks and new detections exist.

### 27.4 Why This Tracker Is Appropriate

- It is simple.
- It is explainable.
- It is CPU-friendly for Raspberry Pi use.
- It is adequate when full appearance-based tracking is unnecessary.

### 27.5 Limitation

- It may struggle in crowded scenes with overlap or complex crossing behavior.
- For a graduation prototype, that tradeoff is acceptable if documented.

## 28. `utils/config.py`

### 28.1 Role

- Central environment-driven configuration for the AI service.
- It defines model paths, thresholds, tracking settings, and OCR behavior.

### 28.2 Key Values

- `VEHICLE_MODEL_PATH`
- `PLATE_MODEL_PATH`
- `PIXEL_TO_METER`
- `SPEED_LIMIT`
- `FRAME_SKIP`
- `MIN_TRACKED_FRAMES`
- `VEHICLE_CONFIDENCE`
- `PLATE_CONFIDENCE`
- `OCR_CONFIDENCE`
- `MAX_DISAPPEARED`
- `MAX_DISTANCE`
- `MAX_UPLOAD_MB`
- `ALLOWED_EXT`
- `OCR_MULTI_PASS`
- `OCR_MAX_ATTEMPTS`

### 28.3 Why This File Matters

- It keeps “magic numbers” out of the main runtime file.
- It makes tuning safer.
- It supports deployment-time customization.

### 28.4 Extra Functions

- `get_violation_severity(...)`
- `validate_configuration()`
- `get_config_dict()`
- `log_configuration(logger)`

### 28.5 Design Lesson

- Configuration files should not only store constants.
- They should also provide validation and reporting helpers.
- This file does that well.

## 29. `utils/speed_estimator.py`

### 29.1 Code Meaning

- The function computes Euclidean pixel distance between first and last stored positions.
- It converts pixel distance to meters using `PIXEL_TO_METER`.
- It divides distance by elapsed time based on frame numbers and FPS.
- It converts meters per second to kilometers per hour.
- It rounds to two decimal places.

### 29.2 Why This Is Simple And Useful

- It is easy to explain academically.
- It is easy to calibrate experimentally.
- It works as a first-approximation method for a prototype.

### 29.3 Limitation

- Accuracy depends heavily on camera perspective and calibration.
- This must be discussed honestly in the scientific report.

## 30. ROS Explanation In The Context Of This Project

### 30.1 Nodes

- The monitor app can act as a ROS subscriber node when compiled with ROS support.
- Street and robot camera publishers are expected to exist elsewhere in the full system.
- A database synchronization launch on the laptop side also exists outside the app source tree.

### 30.2 Topics Visible In Code

- `/cam_robot`
- `/cam_A`
- `/cma_B`
- `/street_ai_monitor`

### 30.3 Message Types Implied By Code

- `sensor_msgs/msg/Image`
- `sensor_msgs/msg/CompressedImage`
- `std_msgs/msg/String`

### 30.4 Why These Choices Make Sense

- Image topics are natural for robot and street cameras.
- A string topic is acceptable for summary-style AI text during early integration.

### 30.5 Services

- No ROS service implementation is directly visible in the inspected application source.
- That does not mean services are impossible in the larger system.
- It means they are not part of the current app-side code snapshot being documented here.

## 31. JSON Communication Layer

### 31.1 Files Used As Operational Contracts

- `traffic_violations.json`
- `priority_vehicles.json`
- `signal_control.json`
- `system_health.json`
- `monitor_ui.json`
- `robot_telemetry.json`

### 31.2 Why JSON Was A Practical Choice

- Easy to read.
- Easy to edit.
- Easy to debug.
- Easy to synchronize.
- Framework-independent.
- Good for education and demos.

### 31.3 Limitations Of JSON Files

- No built-in schema enforcement.
- Concurrent writers require careful strategy.
- Performance may become limited at larger scale.
- Latency is event-loop and file-system dependent.

### 31.4 Why The Choice Is Still Defensible

- For a graduation project and prototype edge-monitor stack, simplicity and inspectability matter a lot.
- The project uses `DataManager` and atomic writes to reduce common file-based problems.

## 32. Server-Side Database Sync Launch

### 32.1 Startup Script

```sh
source /opt/ros/jazzy/setup.bash
source /media/abso/project/database/monitor_app/monitor_app_db_sync_ws/install/setup.bash
ros2 launch monitor_app_db_sync laptop_db_bidirectional.launch.py
```

### 32.2 Explanation

- First line loads the base ROS 2 environment.
- Second line loads the installed sync workspace environment.
- Third line launches a bidirectional database synchronization graph.

### 32.3 Why This Matters

- It confirms that server-side synchronization is not just conceptual.
- There is a concrete ROS launch entry for it.
- This supports the project’s IoT story.

## 33. Yocto Recipe: `traffic-ai-model.bb`

### 33.1 Purpose

- Package the AI source tree and model assets into the target image.
- Install a wrapper executable called `traffic-ai-model`.
- Provide a writable runtime directory.

### 33.2 Important Features

- `inherit externalsrc`
- `EXTERNALSRC ?= "/media/abso/yocto/traffic_robot/traffic_ai_model/source"`
- `do_compile[noexec] = "1"`
- `do_install()` manually copies source and assets.
- Wrapper sets `TRAFFIC_AI_RUNTIME_DIR`.

### 33.3 Why `externalsrc` Is Useful Here

- The recipe builds directly from the live development folder.
- This speeds iteration during project work.
- It is especially helpful when the source is changing frequently.

### 33.4 Why The Wrapper Matters

- The package installs into `/usr/share/traffic-ai-model`.
- The wrapper runs `python3` on `finish.py`.
- The wrapper also points runtime writes to `/var/lib/traffic-ai-model` by default.
- This cleanly separates static package data from mutable runtime data.

## 34. Yocto Recipe: `traffic-robot-app.bb`

### 34.1 Purpose

- Package the Qt application.
- Build it through CMake and Qt 6 support classes.
- Provide a wrapper executable called `traffic-robot-app`.

### 34.2 Important Features

- `inherit qt6-cmake pkgconfig externalsrc`
- `DEPENDS += "qtbase qtdeclarative qtlocation qtpositioning qt5compat opencv"`
- `EXTERNALSRC` points to the live source folder.
- Wrapper sets `MONITOR_APP_DB_PATH`.

### 34.3 Why This Is Good

- The application gets standard Qt build handling.
- OpenCV support is made explicit.
- Runtime database location is controlled at launch time.
- This is exactly what an embedded operator app needs.

## 35. Embedded Systems Code Reality Check

### 35.1 What Is Present

- Raspberry Pi-targeted Linux application code.
- Raspberry Pi-targeted AI code.
- Yocto build metadata for packaging those applications.
- ROS-facing communication logic in the monitor app.

### 35.2 What Is Not Directly Present In This Repository Snapshot

- A full AVR microcontroller firmware source tree is not visible in the inspected project folders.
- Low-level motor-driver firmware code is not visible in the inspected project folders.
- Direct embedded C firmware for sensors and motor control is therefore not explained line by line here because it is not present to inspect honestly.

### 35.3 How To Document This Professionally

- State clearly that Linux-side robot and monitor code is present.
- State clearly that lower-level microcontroller firmware is not included in the inspected repository snapshot.
- If such code exists elsewhere, document it in a separate book or appendix after inspecting the actual source.

## 36. Best Practices Visible In The Code

- Separate orchestration from component implementation.
- Separate backend storage from UI.
- Use atomic writes for shared files.
- Expose QML data through explicit Qt properties.
- Use environment variables for deployment flexibility.
- Use placeholder states rather than blank failure states.
- Keep detector wrappers thin.
- Use a dedicated tracker rather than mixing tracking logic into detection wrappers.
- Keep build metadata near the application it packages.
- Make ROS support optional during compilation when possible.

## 37. Risks And Improvement Areas Visible In Code

- Topic naming inconsistency around Street B should be fixed.
- More automated tests would improve confidence.
- Some runtime behaviors are still simulated rather than sourced from real hardware.
- JSON scaling limits may appear in a larger deployment.
- Full AI-to-dashboard event-bridge completeness should be validated end to end.
- More comments would help in longer functions.
- Production service units are still a future improvement.

## 38. Debugging Guide For First-Time Readers

- If the app opens but shows no data, inspect `MONITOR_APP_DB_PATH`.
- If the app opens but shows placeholders, verify ROS topics are being published.
- If the app shows JSON data but no ROS streams, focus on `RosStreamManager` and ROS environment setup.
- If the app does not start, inspect QML module loading and packaged resources.
- If the AI service starts but produces no detections, verify model paths.
- If OCR results look wrong, inspect `ocr_reader.py` normalization and validation logic.
- If emergency outputs flicker, inspect hold-time settings in `finish.py`.
- If the database files never appear, inspect `DataManager::ensureDatabaseReady()`.
- If updates do not refresh live, inspect `QFileSystemWatcher` behavior and the reload timer.

## 39. Performance Tips

- Keep image resolution realistic for Raspberry Pi CPU-only inference.
- Tune `FRAME_SKIP` for throughput.
- Tune `CAMERA_WARMUP_FRAMES` if startup noise is high.
- Avoid writing large files too frequently in synchronized directories.
- Prefer concise AI summary messages on text topics.
- Watch thermal conditions on Raspberry Pi during long inference sessions.
- Use placeholder frames to reduce confusion during transient disconnects instead of attempting constant reconnect spam in the UI layer.

## 40. Final Technical Reading Strategy

- First, understand `main.cpp`.
- Second, understand `DataManager`.
- Third, understand `RosStreamManager`.
- Fourth, understand `Main.qml`, `Monitor_window.qml`, `CameraNetwork.qml`, `StreetAIPanel.qml`, and `TrafficPanel.qml`.
- Fifth, understand `finish.py`.
- Sixth, understand the detector, OCR, tracker, and config helpers.
- Seventh, understand the Yocto recipes.
- Eighth, understand the synchronization launch script.
- Ninth, map all files back to the system architecture in Book 1.
- Tenth, test one subsystem at a time before attempting the full integrated demo.

## Appendix A. Monitor App File Roles

- `main.cpp`: application composition root.
- `datamanager.h`: JSON-backed state interface.
- `datamanager.cpp`: JSON-backed state implementation.
- `rosstreammanager.h`: ROS stream interface.
- `rosstreammanager.cpp`: ROS stream implementation.
- `systemmonitor.h`: system metric interface.
- `systemmonitor.cpp`: system metric implementation.
- `camera.h`: local camera thread and provider interface.
- `camera.cpp`: local camera thread and provider implementation.
- `include/topbarcontroller.h`: top-bar state interface.
- `src/topbarcontroller.cpp`: top-bar state implementation.
- `CMakeLists.txt`: build graph and resource registration.
- `qml/Main.qml`: top-level QML navigation entry.
- `qml/Main_window.qml`: landing-page composition.
- `qml/OverviewTargetPage.qml`: overview page.
- `qml/MapView.qml`: map-related visual.
- `qml/monitor/Monitor_window.qml`: monitor-page composition.
- `qml/monitor/CameraNetwork.qml`: stream and AI network visual group.
- `qml/monitor/StreetAIPanel.qml`: AI summary and incident queue panel.
- `qml/monitor/TrafficPanel.qml`: traffic events and control-state panel.
- `qml/monitor/CameraCard.qml`: reusable camera-card visual.
- `qml/monitor/MapIntelCard.qml`: map intelligence panel.
- `qml/monitor/HUDStatusBar.qml`: top bar panel.
- `qml/monitor/BottomBar.qml`: bottom-left panel.
- `qml/monitor/BottomBarRight.qml`: bottom-right panel.
- `qml/CircleBar.qml`: reusable circular gauge component.
- `qml/Arc_performance.qml`: visual gauge component.
- `qml/Top_Bar.qml`: earlier or alternate top-bar component.
- `qml/Left_Bar.qml`: earlier or alternate left-side component.
- `qml/Bottom_Bar.qml`: earlier or alternate bottom bar component.
- `qml/Main50CircleBars.qml`: alternate demonstration entry page.
- `qml/background.jpg`: background asset.
- `qml/Qt-Development-white.png`: image asset.
- `qml/monofonto.otf`: custom font asset.

## Appendix B. AI File Roles

- `finish.py`: main AI runtime orchestrator.
- `detectors/vehicle_detector.py`: vehicle bounding-box inference.
- `detectors/plate_detector.py`: plate-region inference inside a vehicle crop.
- `ocr/ocr_reader.py`: OCR extraction, correction, and validation.
- `tracker/centroid_tracker.py`: lightweight object tracking.
- `utils/config.py`: environment-driven configuration and validation.
- `utils/pre_process.py`: preprocessing helper module.
- `utils/speed_estimator.py`: speed calculation helper.
- `models/vehicle_yolo.pt`: vehicle-detection model file.
- `models/plate_yolo.pt`: plate-detection model file.
- `runs/detect/runs/emergency_detector/weights/best.onnx`: emergency-priority model file.
- `requirements.txt`: development or generic Python dependencies.
- `requirements-rpi.txt`: Raspberry Pi-oriented dependency list.

## Appendix C. Practical “How To Use The Code” Notes

- To use the monitor app in development, set or confirm `MONITOR_APP_DB_PATH`.
- To use the monitor app with ROS, ensure the app is compiled with ROS dependencies available.
- To use the AI service, set camera sources and ensure model files exist where `config.py` expects them.
- To use the packaged versions on target hardware, run the wrapper executables instead of raw source files where possible.
- To use the JSON layer for manual testing, edit the tracked JSON files and watch the UI reload behavior.
- To use the server synchronization layer, source the ROS environments and launch `laptop_db_bidirectional.launch.py`.

## Appendix D. Key Takeaway

- This project’s code is best understood as a layered platform.
- The C++ and QML side provides presentation and operator interaction.
- The Python side provides perception and export logic.
- The JSON and ROS layers provide communication.
- The Yocto layers provide deployment structure.
- When these layers are read together, the project becomes much easier to understand and defend academically.

## 41. Extended `main.cpp` Walkthrough Notes

- Main Note 001: `main.cpp` is the file where all major backend objects are instantiated.
- Main Note 002: It is a composition file, not a business-logic file.
- Main Note 003: This separation is desirable because startup wiring and domain logic remain distinct.
- Main Note 004: The file starts by importing Qt GUI and QML support.
- Main Note 005: It then imports project-local headers for monitoring, camera, data, and ROS streams.
- Main Note 006: The conditional ROS include makes the application portable across environments.
- Main Note 007: `QGuiApplication` is chosen rather than `QApplication` because the app is QML-first and does not need classic QWidget infrastructure.
- Main Note 008: The file treats ROS as optional infrastructure.
- Main Note 009: This is a good decision because the UI can still be demonstrated without full ROS availability.
- Main Note 010: The `DataManager` object is created early because the UI depends on its properties almost immediately.
- Main Note 011: The connection from `errorOccurred` to `qWarning()` gives terminal visibility into storage and parse issues.
- Main Note 012: Silent failure in a distributed dashboard would be a bad developer experience.
- Main Note 013: The environment-driven database path is one of the most important runtime decisions in the file.
- Main Note 014: Using `MONITOR_APP_DB_PATH` means one binary can operate against different datasets in development and deployment.
- Main Note 015: `SystemMonitor` is created at startup so that health metrics begin immediately.
- Main Note 016: `TopBarController` is created so the top bar has live timing and signal-like state.
- Main Note 017: `RosStreamManager` is created so stream placeholders and topic names exist before the UI renders.
- Main Note 018: The QML engine is configured with a failure exit path.
- Main Note 019: This means QML startup errors are not hidden.
- Main Note 020: Exposing context properties is one of the most important steps for QML integration.
- Main Note 021: `dataManager` is the data and persistence bridge.
- Main Note 022: `systemMonitor` is the system-metrics bridge.
- Main Note 023: `rosStreams` is the live stream and AI summary bridge.
- Main Note 024: The telemetry lambda is a compact pattern for translating runtime state into stored JSON state.
- Main Note 025: `patchSystemHealth` prevents a full overwrite of the health object for every change.
- Main Note 026: `qRound(systemMonitor.performanceValue() * 100.0)` converts the normalized metric into a readable percentage.
- Main Note 027: The lambda also writes a timestamp for recency checking.
- Main Note 028: Connecting both health signals to the same lambda avoids duplicated code.
- Main Note 029: The immediate `pushTelemetry()` call ensures the UI starts with non-stale values.
- Main Note 030: `topBarData` exposes a specialized UI object rather than mixing its fields into another backend class.
- Main Note 031: The image providers are crucial because QML image elements naturally consume provider URLs.
- Main Note 032: `CameraProvider` handles local camera imagery.
- Main Note 033: `RosStreamImageProvider` handles ROS-delivered imagery.
- Main Note 034: The QML module load line depends directly on the CMake QML registration.
- Main Note 035: This is why build-system understanding matters when reading runtime code.
- Main Note 036: The file cleanly returns the `app.exec()` result.
- Main Note 037: ROS shutdown after `app.exec()` keeps lifecycle handling tidy.
- Main Note 038: This file is a good place to add future service-status objects if the dashboard grows.
- Main Note 039: It is also the correct place to add more context properties if new backend classes are introduced.
- Main Note 040: It would be a poor place to add detailed JSON parsing or detector logic because that would break separation of concerns.
- Main Note 041: Students should recognize this as a classic application bootstrap file.
- Main Note 042: Supervisors can use this file to evaluate how deliberately the student assembled the runtime graph.
- Main Note 043: Maintainers can use this file to trace the origin of QML-visible object names.
- Main Note 044: The file shows that the monitor app is not only visual but also integration-oriented.
- Main Note 045: It bridges filesystem state, live metrics, optional ROS, and image providers.
- Main Note 046: That breadth is why it deserves careful explanation.
- Main Note 047: The file is short, which is generally a good sign for a bootstrap unit.
- Main Note 048: If `main.cpp` becomes very large in the future, that would be a warning that composition and logic are becoming mixed.
- Main Note 049: The current file size suggests the design is still disciplined.
- Main Note 050: When debugging startup issues, this file is the first place to inspect after build configuration.
- Main Note 051: If the database path is wrong, the bug likely appears from here outward.
- Main Note 052: If a context property name changes, QML bindings may fail from here outward.
- Main Note 053: If the wrong QML module name is loaded, startup failure will be rooted here.
- Main Note 054: If ROS was compiled in but not initialized, the issue can also start here.
- Main Note 055: Because this file is so central, it is useful for onboarding presentations.
- Main Note 056: A student can explain the entire app at a high level just by walking through this file.
- Main Note 057: That makes it a strong teaching artifact.
- Main Note 058: It also gives a natural transition to CMake and QML module registration.
- Main Note 059: The pattern of exposing objects rather than reading files directly in QML is a mature design decision.
- Main Note 060: That decision is visible as early as this file.
- Main Note 061: The application is therefore best understood as “QML frontend, C++ integration backend.”
- Main Note 062: That phrase is a useful summary for oral defense.
- Main Note 063: The file is also a good example of edge UI software that anticipates partial subsystem failure.
- Main Note 064: It wires placeholders and defaults before live data is guaranteed.
- Main Note 065: That improves demonstrability and robustness.
- Main Note 066: The environment-variable default path still points to a development folder.
- Main Note 067: For deployment, the Yocto wrapper overrides that with a target-appropriate path.
- Main Note 068: This interaction between `main.cpp` and the recipe wrapper is an important deployment lesson.
- Main Note 069: It shows why source reading and packaging reading should happen together.
- Main Note 070: Good technical documentation must therefore explain both files in the same narrative.
- Main Note 071: `main.cpp` also shows that the project respects lifecycle ordering.
- Main Note 072: Data and stream providers are created before the QML engine is fully used.
- Main Note 073: This avoids some common null-binding problems in QML-heavy apps.
- Main Note 074: The image providers are added before `loadFromModule(...)`.
- Main Note 075: This ensures QML can request images as soon as components are created.
- Main Note 076: The file’s structure is therefore not accidental; it is order-sensitive.
- Main Note 077: Understanding that order helps when modifying startup behavior later.
- Main Note 078: This file is the ideal first source file for any new contributor.
- Main Note 079: It tells the contributor what the dashboard depends on.
- Main Note 080: It also tells the contributor where to go next in the source tree.

## 42. Extended `DataManager` Notes

- DataManager Note 001: `DataManager` is the most important non-visual backend class in the app.
- DataManager Note 002: It owns the mapping between named JSON files and QML-visible data structures.
- DataManager Note 003: It acts as both a loader and a saver.
- DataManager Note 004: It also acts as a file watcher.
- DataManager Note 005: This combination makes it the “state backbone” of the dashboard.
- DataManager Note 006: The header reveals strong use of `Q_PROPERTY`.
- DataManager Note 007: Those properties are what make QML bindings possible without repetitive getter calls.
- DataManager Note 008: The class uses `QVariantList` and `QVariantMap` because QML works naturally with those dynamic container types.
- DataManager Note 009: The design favors flexibility over rigid compile-time schemas.
- DataManager Note 010: For a graduation prototype, that tradeoff is reasonable.
- DataManager Note 011: The tracked filenames define a small operational database.
- DataManager Note 012: Each file corresponds to one domain concern.
- DataManager Note 013: This is cleaner than one giant JSON file for everything.
- DataManager Note 014: Smaller files are easier to inspect and synchronize.
- DataManager Note 015: Smaller files also lower the risk of unrelated changes colliding.
- DataManager Note 016: The default data function is unusually important.
- DataManager Note 017: It gives the app “instant meaning” even before live systems are online.
- DataManager Note 018: It also documents the expected file schema in executable form.
- DataManager Note 019: If a new developer asks what `priority_vehicles.json` should look like, `defaultDataFor(...)` gives the answer.
- DataManager Note 020: The violation defaults include Arabic strings, which reflects the intended domain and user context.
- DataManager Note 021: The default system health and telemetry values are also valuable for screenshot generation and demos.
- DataManager Note 022: `ensureDatabaseReady()` prevents a whole class of startup bugs.
- DataManager Note 023: Without it, downstream reads and writes would fail for trivial filesystem reasons.
- DataManager Note 024: The class emits `errorOccurred(...)` rather than swallowing problems silently.
- DataManager Note 025: This improves both debugging and operational visibility.
- DataManager Note 026: The watcher connections in the constructor show that the class expects external file modification.
- DataManager Note 027: That expectation matches the project’s synchronization story.
- DataManager Note 028: The reload timer smooths bursty update patterns.
- DataManager Note 029: Burst smoothing matters because sync tools may rewrite files atomically or in quick succession.
- DataManager Note 030: Immediate reload on every change could create redundant work.
- DataManager Note 031: The `databasePath` property is itself QML-visible, which can help diagnostics or future UI settings pages.
- DataManager Note 032: Setter-based path control is better than a hard-coded internal constant.
- DataManager Note 033: The patch methods are especially practical.
- DataManager Note 034: They update selective keys while preserving the rest of the object.
- DataManager Note 035: This lowers accidental data loss risk.
- DataManager Note 036: `addTrafficViolation(...)` and `removeTrafficViolation(...)` support UI-driven event list manipulation.
- DataManager Note 037: The project therefore uses the same backend for both sync-driven and UI-driven updates.
- DataManager Note 038: That unification reduces architectural fragmentation.
- DataManager Note 039: If the dashboard later adds acknowledgments or notes, `DataManager` is the natural insertion point.
- DataManager Note 040: Because it centralizes file knowledge, it also centralizes schema evolution.
- DataManager Note 041: Schema evolution in one place is easier to reason about than schema evolution scattered through QML.
- DataManager Note 042: The design also means tests can be written against one backend class instead of against many UI components.
- DataManager Note 043: That is important for future hardening.
- DataManager Note 044: The current class already suggests where such tests should focus.
- DataManager Note 045: One test should verify missing-directory creation.
- DataManager Note 046: Another should verify missing-file creation.
- DataManager Note 047: Another should verify reload on external file change.
- DataManager Note 048: Another should verify patch behavior preserves unrelated keys.
- DataManager Note 049: Another should verify malformed JSON is reported cleanly.
- DataManager Note 050: The class also reveals the chosen dashboard data model directly.
- DataManager Note 051: That makes it useful not only for implementation but also for documentation.
- DataManager Note 052: The app’s schema is visible in C++ and mirrored in the report.
- DataManager Note 053: The monitor UI wording model inside `monitor_ui.json` is a particularly strong idea.
- DataManager Note 054: It decouples frontend text from frontend layout.
- DataManager Note 055: It can support localization later.
- DataManager Note 056: It can also support easier A/B wording changes for operators.
- DataManager Note 057: The telemetry schema is rich enough to support convincing mission displays.
- DataManager Note 058: The use of list and map variants is a good fit for loosely structured mission and alert data.
- DataManager Note 059: A more rigid system could eventually use formal message schemas or generated classes.
- DataManager Note 060: At prototype stage, the current approach is simpler and faster.
- DataManager Note 061: The class defines an interface contract between the dashboard and the synchronization layer.
- DataManager Note 062: That makes it one of the most integration-sensitive files.
- DataManager Note 063: If the sync layer writes unexpected keys or shapes, the issue will surface here or in QML.
- DataManager Note 064: Therefore this class should be protected carefully during refactors.
- DataManager Note 065: Documentation should always mention the tracked files when presenting the app.
- DataManager Note 066: The class also helps explain why the dashboard can run without ROS.
- DataManager Note 067: JSON-backed state is sufficient for a substantial portion of the interface.
- DataManager Note 068: That dual capability is a strength of the app architecture.
- DataManager Note 069: It supports both offline demos and live distributed operation.
- DataManager Note 070: The class is conceptually similar to a miniature domain database layer.
- DataManager Note 071: It is not a relational database.
- DataManager Note 072: It is not an ORM.
- DataManager Note 073: But it serves the same organizational purpose for this project.
- DataManager Note 074: Students can learn from how modest infrastructure can still be designed clearly.
- DataManager Note 075: The file is also a reminder that user interfaces need trusted backend owners.
- DataManager Note 076: Without such a class, QML files would become much harder to maintain.
- DataManager Note 077: The design encourages single responsibility in the UI layer.
- DataManager Note 078: It also encourages explicit contracts across the system.
- DataManager Note 079: If a new file such as `service_status.json` is added later, `DataManager` is the right first backend extension point.
- DataManager Note 080: The class is therefore a cornerstone of future feature growth.
- DataManager Note 081: In oral defense, `DataManager` can be described as “the dashboard’s file-backed state manager.”
- DataManager Note 082: That phrase is accurate and concise.
- DataManager Note 083: In written documentation, the class deserves more detail because many app features depend on it.
- DataManager Note 084: The current guide gives it that detail.
- DataManager Note 085: Students should notice that the class hides Qt file APIs from QML.
- DataManager Note 086: That is one of its biggest architectural benefits.
- DataManager Note 087: Maintenance becomes easier when read/write code is not duplicated in multiple UI files.
- DataManager Note 088: Observability also improves because all file-related errors can funnel through one signal.
- DataManager Note 089: This is one reason the project feels structured rather than improvised.
- DataManager Note 090: The class could still be improved with more explicit schema validation.
- DataManager Note 091: However, even without that, it already provides strong practical value.
- DataManager Note 092: It bridges development convenience and operational realism.
- DataManager Note 093: It supports the project’s IoT narrative.
- DataManager Note 094: It supports the project’s UI narrative.
- DataManager Note 095: It even supports the project’s academic narrative by making system state visible and explainable.
- DataManager Note 096: That breadth is why it deserves a long explanation in this technical guide.
- DataManager Note 097: Any future developer working on the dashboard should learn this class early.
- DataManager Note 098: Any future tester should create cases around this class early.
- DataManager Note 099: Any future deployment engineer should understand its file expectations early.
- DataManager Note 100: `DataManager` is therefore one of the most educational files in the app source tree.

## 43. Extended `RosStreamManager` Notes

- Ros Note 001: `RosStreamManager` is the live-media and ROS-awareness core of the dashboard.
- Ros Note 002: Without it, the app would still show JSON data but would lose most of its live operational feeling.
- Ros Note 003: The class bridges asynchronous topic data into a form the UI can poll safely.
- Ros Note 004: Topic names are treated as runtime configuration rather than as fixed constants.
- Ros Note 005: That is good because deployments often rename or namespace topics.
- Ros Note 006: The current defaults expose the intended architecture directly.
- Ros Note 007: The class uses placeholders from the very beginning.
- Ros Note 008: Placeholder design is not cosmetic here; it is operational communication.
- Ros Note 009: A placeholder tells the operator which stream is missing and what topic is expected.
- Ros Note 010: This is better than a silent blank panel.
- Ros Note 011: `imageFromMat(...)` reveals that image conversion was treated as an explicit boundary concern.
- Ros Note 012: That is important when mixing OpenCV and Qt.
- Ros Note 013: The constructor starts a refresh timer regardless of ROS availability.
- Ros Note 014: This allows state aging and placeholder handling to remain consistent.
- Ros Note 015: The class stores stream state in a `QHash`.
- Ros Note 016: That suggests the author wanted generic stream operations rather than custom code per topic.
- Ros Note 017: Generic stream operations are easier to extend.
- Ros Note 018: The mutex around stream access is essential.
- Ros Note 019: UI and callback code would otherwise race.
- Ros Note 020: This is one of the most concurrency-sensitive places in the app.
- Ros Note 021: The class also exposes concise string properties like `robotSignal`.
- Ros Note 022: This reduces UI branching complexity.
- Ros Note 023: The same principle appears in the online booleans and FPS getters.
- Ros Note 024: The UI gets exactly the shape of data it needs.
- Ros Note 025: `requestFrame(...)` exists because `QQuickImageProvider` needs a size-aware fetch path.
- Ros Note 026: The provider does not need to know anything else about ROS.
- Ros Note 027: That separation is elegant.
- Ros Note 028: The provider pattern therefore turns a complex topic system into simple image URLs.
- Ros Note 029: That is a strong conceptual transformation for students to understand.
- Ros Note 030: The class also carries the AI topic and summary string.
- Ros Note 031: This shows the dashboard is not image-only.
- Ros Note 032: Textual AI summaries matter for operator interpretation.
- Ros Note 033: The project therefore treats ROS as a carrier for both imagery and concise event meaning.
- Ros Note 034: That is a mature human-centered design idea.
- Ros Note 035: If the class is extended later, richer AI messages may replace plain strings.
- Ros Note 036: Even then, this class would remain the natural translation layer.
- Ros Note 037: The fallback `/cma_B` topic should be audited.
- Ros Note 038: Documentation should never hide that inconsistency.
- Ros Note 039: Exposing it early is part of responsible engineering.
- Ros Note 040: The destructor’s executor cancellation and thread join show lifecycle discipline.
- Ros Note 041: Thread cleanup bugs are common in callback-driven systems.
- Ros Note 042: The presence of explicit cleanup logic is therefore reassuring.
- Ros Note 043: The class makes the app credible as a ROS-integrated dashboard.
- Ros Note 044: It also makes the app usable during partial integration stages.
- Ros Note 045: That balance between ambition and resilience is one of the better design qualities in the project.
- Ros Note 046: A student learning ROS UI integration can learn a lot from this file.
- Ros Note 047: It shows how to keep ROS-specific code out of QML.
- Ros Note 048: It shows how to hide message-type complexity behind properties.
- Ros Note 049: It shows how to retain application functionality when ROS support is not built in.
- Ros Note 050: This kind of conditional compilation is valuable in mixed teams.
- Ros Note 051: Not every developer or build machine needs full ROS just to work on the interface.
- Ros Note 052: That lowers friction for collaboration.
- Ros Note 053: `RosStreamManager` therefore improves both runtime function and team workflow.
- Ros Note 054: The class’s polling timer and QML refresh timer together create the visible liveliness of the stream panels.
- Ros Note 055: One updates stream state.
- Ros Note 056: The other forces image URL churn in the UI.
- Ros Note 057: Together they create a practical if somewhat polling-oriented display mechanism.
- Ros Note 058: For a Raspberry Pi and Qt dashboard, that tradeoff is understandable.
- Ros Note 059: A future optimization could move toward signal-driven frame invalidation.
- Ros Note 060: But the current approach is easier to explain and debug.
- Ros Note 061: The anonymous-namespace helper functions keep utility code local to the translation unit.
- Ros Note 062: That reduces namespace pollution.
- Ros Note 063: The placeholder styling also creates a coherent visual language of waiting and monitoring.
- Ros Note 064: Visual clarity in degraded states is a genuine technical benefit in operator systems.
- Ros Note 065: The class therefore supports both software and UX quality.
- Ros Note 066: Because it centralizes topics, it also centralizes one of the most common integration failure points.
- Ros Note 067: If a topic name changes, one class becomes the obvious adjustment point.
- Ros Note 068: That is another maintainability benefit.
- Ros Note 069: The stream state structure includes `pendingFrames` and timing fields, hinting at FPS or freshness accounting.
- Ros Note 070: These indicators are more useful than a binary online flag alone.
- Ros Note 071: Operators need to know not just if a topic exists, but if it is meaningfully alive.
- Ros Note 072: The code moves in that direction.
- Ros Note 073: The class also reinforces the project’s message that live data and persisted data can coexist.
- Ros Note 074: JSON handles durable state.
- Ros Note 075: ROS handles transient streams.
- Ros Note 076: `RosStreamManager` is the bridge for the second category.
- Ros Note 077: Because the project spans multiple devices, the existence of this class is almost mandatory.
- Ros Note 078: Without it, ROS concerns would spread through many QML files.
- Ros Note 079: That would be fragile and hard to maintain.
- Ros Note 080: The current design avoids that trap.
- Ros Note 081: The class could eventually expose latency and packet statistics if needed.
- Ros Note 082: It could also expose per-stream last-update timestamps.
- Ros Note 083: Those future additions would fit naturally into the current abstraction.
- Ros Note 084: This is another sign of a good interface shape.
- Ros Note 085: Good abstractions make future extension feel obvious.
- Ros Note 086: `RosStreamManager` largely achieves that.
- Ros Note 087: The class is also a good teaching example for thread-safe state ownership.
- Ros Note 088: It makes shared access explicit and guarded.
- Ros Note 089: That is healthier than relying on accidental single-thread assumptions.
- Ros Note 090: Because ROS callbacks may arrive fast, thread awareness matters.
- Ros Note 091: Because QML may request frames often, UI-side access matters.
- Ros Note 092: The mutex respects both facts.
- Ros Note 093: From an academic standpoint, this class is where middleware meets presentation.
- Ros Note 094: From an engineering standpoint, it is where transport becomes user-facing status.
- Ros Note 095: From a maintenance standpoint, it is one of the files that should be refactored cautiously.
- Ros Note 096: Changes here ripple visibly across the dashboard.
- Ros Note 097: This is why the technical guide gives it long treatment.
- Ros Note 098: A first-time maintainer should read this class before touching any stream-related QML.
- Ros Note 099: A tester should use this class to reason about stream failure modes.
- Ros Note 100: `RosStreamManager` is thus one of the project’s most important integration classes.

## 44. Extended QML Architecture Notes

- QML Note 001: The QML layer is responsible for layout, visual logic, and lightweight interaction glue.
- QML Note 002: It is not responsible for low-level file management or ROS message decoding.
- QML Note 003: That separation is what keeps the interface maintainable.
- QML Note 004: `Main.qml` is the navigation root.
- QML Note 005: `Monitor_window.qml` is the live monitor composition root.
- QML Note 006: `CameraNetwork.qml` is the top live-operations region.
- QML Note 007: `StreetAIPanel.qml` provides AI-centric status interpretation.
- QML Note 008: `TrafficPanel.qml` provides incident and control-state editing.
- QML Note 009: The use of `readonly property var` bindings to backend objects is widespread.
- QML Note 010: This keeps component code concise.
- QML Note 011: It also makes the data source of each visual region explicit.
- QML Note 012: The UI uses dark color themes with cyan-like accents.
- QML Note 013: That visual choice supports monitor readability and a technical dashboard feel.
- QML Note 014: The QML files often separate labels and values clearly.
- QML Note 015: This is important for operator scanning speed.
- QML Note 016: Many QML sections use `RowLayout`, `ColumnLayout`, and `GridLayout`.
- QML Note 017: That is a robust approach for responsive dashboard layouts.
- QML Note 018: The app uses reusable cards and panels rather than one monolithic page file.
- QML Note 019: Reusability is visible in components like `CameraCard.qml`.
- QML Note 020: Modularity in QML helps long-term maintenance just as modularity helps in C++.
- QML Note 021: `TrafficPanel.qml` demonstrates controlled two-way interaction between UI and backend.
- QML Note 022: It avoids infinite loops with the `syncingSignal` guard.
- QML Note 023: That guard is a subtle but important pattern.
- QML Note 024: Students should learn from it because file-backed and UI-driven updates often cause loops.
- QML Note 025: `CameraNetwork.qml` demonstrates how to blend live stream state and static descriptive text.
- QML Note 026: The `frameSeed` timer reveals a practical method for image refresh.
- QML Note 027: `StreetAIPanel.qml` demonstrates how to turn backend event lists into concise visual summaries.
- QML Note 028: It also shows how to display empty states cleanly.
- QML Note 029: Empty states are not minor UI details; they communicate system condition.
- QML Note 030: The dashboard’s ability to show waiting states, empty incident queues, and live counts is a form of runtime observability.
- QML Note 031: Observability is one of the strongest interface qualities in the project.
- QML Note 032: The QML files depend on backend names such as `dataManager`, `systemMonitor`, `rosStreams`, and `topBarData`.
- QML Note 033: That means renaming context properties in `main.cpp` would affect many bindings.
- QML Note 034: This is why startup composition and QML architecture must be documented together.
- QML Note 035: The `monitor_ui.json` model gives QML a semi-data-driven language layer.
- QML Note 036: That is a design strength because it avoids recompilation for simple wording updates.
- QML Note 037: It also supports future translation or customer-specific phrasing.
- QML Note 038: The QML layer is therefore not hard-coded in every detail.
- QML Note 039: Some parts are structural.
- QML Note 040: Some parts are configurable through backend-provided data.
- QML Note 041: The presence of older or alternate visual components suggests the UI evolved iteratively.
- QML Note 042: Preserving those files can be useful for learning and fallback designs.
- QML Note 043: However, maintainers should eventually decide which path is canonical to reduce confusion.
- QML Note 044: For now, the technical guide should identify the current main path clearly.
- QML Note 045: That current path is through `Main.qml` and the `monitor` subfolder components.
- QML Note 046: The custom font asset contributes to a more deliberate visual identity.
- QML Note 047: Assets matter in operator systems because legibility and visual hierarchy affect usability.
- QML Note 048: The dashboard is therefore not only technically functional but also presentation-aware.
- QML Note 049: In academic evaluation, interface polish can help communicate system maturity.
- QML Note 050: In operational evaluation, clarity is even more important than polish.
- QML Note 051: The current QML files aim at both.
- QML Note 052: The use of cards, badges, and layouts supports scan-based reading.
- QML Note 053: Scan-based reading is crucial for a monitor dashboard.
- QML Note 054: The UI uses both text and color cues to communicate status.
- QML Note 055: That multimodal communication is appropriate in traffic and robotics monitoring.
- QML Note 056: It reduces dependence on one indicator type alone.
- QML Note 057: If future work adds accessibility features, this visual structure provides a good starting point.
- QML Note 058: The UI also separates overview from detail by using multiple pages.
- QML Note 059: Multi-page separation prevents the monitor screen from becoming too cluttered.
- QML Note 060: The `StackView` transitions make navigation feel intentional.
- QML Note 061: Even small motion choices contribute to user understanding of page changes.
- QML Note 062: The interface is therefore a good example of “structured dashboard QML.”
- QML Note 063: It is not only a collection of widgets.
- QML Note 064: It is an organized screen system.
- QML Note 065: A student maintaining QML should first identify whether a change belongs to a reusable component or to the page-level composer.
- QML Note 066: This prevents duplication.
- QML Note 067: It also preserves consistent styling.
- QML Note 068: The component naming is descriptive enough to support that reasoning.
- QML Note 069: The map-related components likely rely heavily on telemetry JSON.
- QML Note 070: That makes the telemetry schema especially important for visual correctness.
- QML Note 071: If telemetry fields change, map and mission views may need corresponding updates.
- QML Note 072: This shows how backend schema and frontend components are tightly related even when decoupled technically.
- QML Note 073: The best way to study the QML layer is from top-level files downward.
- QML Note 074: Start with `Main.qml`.
- QML Note 075: Then read `Monitor_window.qml`.
- QML Note 076: Then read `CameraNetwork.qml`, `StreetAIPanel.qml`, and `TrafficPanel.qml`.
- QML Note 077: Then inspect supporting card components.
- QML Note 078: This reading order mirrors runtime composition.
- QML Note 079: It also prevents first-time readers from getting lost in small subcomponents too early.
- QML Note 080: The same staged reading strategy should be taught to future team members.
- QML Note 081: QML files are often easier to understand when you know which backend properties feed them.
- QML Note 082: Therefore cross-reading with the C++ headers is useful.
- QML Note 083: This guide intentionally explains those relationships.
- QML Note 084: The QML layer would benefit from line comments only in especially tricky sections.
- QML Note 085: For now, structure and naming carry much of the meaning.
- QML Note 086: The project’s UI therefore demonstrates readable organization more than excessive inline commentary.
- QML Note 087: That is acceptable when paired with external documentation like this book.
- QML Note 088: For technical defense, the student should be ready to explain which QML files correspond to which screen regions.
- QML Note 089: The current architecture supports that explanation clearly.
- QML Note 090: For future developers, the QML layer is approachable precisely because it is componentized.
- QML Note 091: For operators, the result should feel coherent and data-rich.
- QML Note 092: For examiners, the result shows real UI engineering effort.
- QML Note 093: All three perspectives matter in a graduation project.
- QML Note 094: That is why the QML layer deserves substantial space in the technical guide.
- QML Note 095: It is not secondary decoration.
- QML Note 096: It is a core subsystem that translates project data into human understanding.
- QML Note 097: In many ways, it is the visible face of the whole project.
- QML Note 098: The rest of the stack exists partly to feed it meaningful state.
- QML Note 099: A strong explanation of the QML layer is therefore necessary.
- QML Note 100: This section provides that explanation in a structured way.

## 45. Extended AI Orchestration Notes

- AI Note 001: `finish.py` is where AI runtime policy becomes concrete.
- AI Note 002: It does more than call a model.
- AI Note 003: It manages directories, timing, state, and outputs.
- AI Note 004: This is typical of real AI services, which need orchestration around models.
- AI Note 005: The environment-loading step supports flexible deployment.
- AI Note 006: The runtime directory definitions support separation of code and writable data.
- AI Note 007: The emergency model path fallback logic suggests practical adaptation to evolving file layouts.
- AI Note 008: That kind of adaptation is common during student development.
- AI Note 009: The key is to document it clearly.
- AI Note 010: The request-state dictionaries show that the AI is thinking in per-camera operational terms.
- AI Note 011: It is not only tracking pixels.
- AI Note 012: It is also tracking which road each camera corresponds to.
- AI Note 013: This is how low-level visual detections become higher-level control hints.
- AI Note 014: The code uses locks for file writing and shared request state.
- AI Note 015: That is important because concurrent logic can otherwise cause intermittent faults.
- AI Note 016: The atomic file-writing helper is one of the strongest engineering details in the AI service.
- AI Note 017: It protects downstream consumers from partially written state files.
- AI Note 018: The compact `road=` and `ts=` export format is intentionally simple.
- AI Note 019: Simplicity helps when the downstream consumer is another embedded control component.
- AI Note 020: `recompute_and_write_central_request()` is where local camera states become one global decision.
- AI Note 021: Global decision logic is often the turning point in multi-sensor systems.
- AI Note 022: Here the chosen rule is recency.
- AI Note 023: Recency is easy to defend because it is deterministic and explainable.
- AI Note 024: `update_camera_request_state(...)` introduces hold-time debouncing.
- AI Note 025: Debouncing is essential whenever detections can flicker between frames.
- AI Note 026: Without it, the output could oscillate and confuse downstream control.
- AI Note 027: The file also defines stop-line ratios and road-name mappings.
- AI Note 028: That shows awareness of per-camera geometric context.
- AI Note 029: AI systems are rarely useful without scene-specific assumptions.
- AI Note 030: Embedding those assumptions explicitly is better than hiding them in magic numbers later.
- AI Note 031: The file imports `VehicleDetector`, `PlateDetector`, `CentroidTracker`, `multi_pass_ocr`, and `calculate_speed`.
- AI Note 032: This reveals the intended processing stages at a glance.
- AI Note 033: First detect vehicles.
- AI Note 034: Then localize plates.
- AI Note 035: Then read the text.
- AI Note 036: Then track across frames.
- AI Note 037: Then estimate motion-related metrics.
- AI Note 038: Then export usable outputs.
- AI Note 039: That staged architecture is exactly how many applied AI systems are built.
- AI Note 040: It is modular and explainable.
- AI Note 041: It also allows focused debugging.
- AI Note 042: If plates are wrong but vehicles are correct, the plate or OCR stage is a likely target.
- AI Note 043: If speeds are wrong but tracks look stable, the calibration or estimator stage is a likely target.
- AI Note 044: If emergency outputs flicker, the state or debouncing logic is a likely target.
- AI Note 045: This debugging clarity is an advantage of modular AI design.
- AI Note 046: The code also includes camera warmup settings.
- AI Note 047: That is important because initial frames often contain unstable exposure or device noise.
- AI Note 048: The file shows practical awareness of edge-device camera behavior.
- AI Note 049: It also defines display width and frame delay modes through environment variables.
- AI Note 050: This suggests the AI pipeline can operate in more than one runtime mode.
- AI Note 051: The configuration is not fully buried.
- AI Note 052: It is made explicit at the top of the file.
- AI Note 053: That supports both maintainability and experimentation.
- AI Note 054: The project therefore treats AI as a service, not only as a notebook-style experiment.
- AI Note 055: Service-oriented AI design is more valuable in embedded systems.
- AI Note 056: It aligns with deployment, monitoring, and control use cases.
- AI Note 057: The imports from `dotenv` suggest a comfortable development workflow.
- AI Note 058: The environment variable support suggests an embedded deployment workflow.
- AI Note 059: Having both is good because student projects need easy iteration and real deployment paths.
- AI Note 060: The file therefore bridges experimentation and productization.
- AI Note 061: Students should notice that this is one of the core themes across the entire repository.
- AI Note 062: The app does the same thing through wrappers and path abstraction.
- AI Note 063: The recipes do the same thing through `externalsrc` and install paths.
- AI Note 064: Together these patterns form a coherent engineering style.
- AI Note 065: The AI service’s emergency output is one of the most interesting bridges to the wider cyber-physical system.
- AI Note 066: A text file may look simple, but it can represent a control recommendation with real-world implications.
- AI Note 067: That is why safe write behavior and deterministic arbitration matter so much.
- AI Note 068: The file could eventually export richer structured event objects too.
- AI Note 069: Even if that happens, the current simple contract is a sensible prototype starting point.
- AI Note 070: Simplicity is a design asset when multiple teams or devices must interoperate.
- AI Note 071: The file also makes clear that AI is not isolated from operational context.
- AI Note 072: It knows about roads.
- AI Note 073: It knows about timing.
- AI Note 074: It knows about runtime persistence.
- AI Note 075: It knows about control-oriented signaling.
- AI Note 076: This is exactly what makes it more than a model demo.
- AI Note 077: It is an edge-AI operational service.
- AI Note 078: That phrase is appropriate for documentation and defense.
- AI Note 079: The file would benefit from additional inline comments around deeper event logic if extended significantly.
- AI Note 080: Still, the top-level architecture is already readable.
- AI Note 081: The helper functions at the top keep repeated low-level tasks encapsulated.
- AI Note 082: This is important for code cleanliness.
- AI Note 083: The presence of timestamp utilities reinforces the theme of traceability.
- AI Note 084: Traceability matters in asynchronous distributed systems.
- AI Note 085: If a student explains only the models and not the runtime behavior, the project would be undersold.
- AI Note 086: `finish.py` proves that the runtime behavior is substantial.
- AI Note 087: For oral defense, the student should explain this file as “the AI service supervisor.”
- AI Note 088: That metaphor is accurate because it coordinates many helpers.
- AI Note 089: A new teammate should read this file early after reading the helper modules list.
- AI Note 090: A tester should use this file to identify runtime inputs, outputs, and timing controls.
- AI Note 091: A deployment engineer should use this file to identify runtime directory needs.
- AI Note 092: A systems engineer should use this file to identify the operational contract of AI outputs.
- AI Note 093: Because the file sits at the intersection of so many concerns, it is one of the most important Python files in the repository.
- AI Note 094: That is why this guide spends so much space explaining it.
- AI Note 095: The file is a strong example of service-oriented AI implementation.
- AI Note 096: It rewards careful study.
- AI Note 097: It also supports multiple future directions without discarding its current structure.
- AI Note 098: That future extensibility is a positive design sign.
- AI Note 099: In summary, `finish.py` is the operational heart of the AI subsystem.
- AI Note 100: Understanding it is essential for understanding the whole project.

## 46. Extended Detector, OCR, And Tracker Notes

- Vision Note 001: The project uses a staged perception pipeline rather than one giant end-to-end black box.
- Vision Note 002: Staged pipelines are easier to debug and explain.
- Vision Note 003: `VehicleDetector` is the first structural stage.
- Vision Note 004: It limits detections to relevant COCO classes.
- Vision Note 005: That lowers noise and wasted downstream work.
- Vision Note 006: The explicit class list documents system intent.
- Vision Note 007: The detector wrapper returns plain tuples, not complex model objects.
- Vision Note 008: Plain tuples simplify downstream code.
- Vision Note 009: `PlateDetector` then focuses on a much smaller problem.
- Vision Note 010: This is computationally and conceptually efficient.
- Vision Note 011: It looks for the most likely plate inside one vehicle crop.
- Vision Note 012: Choosing the highest-confidence plate is a pragmatic simplification.
- Vision Note 013: The OCR layer recognizes that detection alone is not enough.
- Vision Note 014: Text extraction must be validated.
- Vision Note 015: Raw OCR can be noisy.
- Vision Note 016: The `OCRResult` class is therefore a very good design choice.
- Vision Note 017: It retains raw text for diagnosis.
- Vision Note 018: It retains corrected text for usability.
- Vision Note 019: It retains confidence for trust assessment.
- Vision Note 020: It retains validation state for downstream logic.
- Vision Note 021: This is better than flattening everything into one uncertain string.
- Vision Note 022: The correction rules in `ocr_reader.py` acknowledge common character confusion.
- Vision Note 023: This is realistic applied OCR engineering.
- Vision Note 024: Validation patterns further filter implausible results.
- Vision Note 025: This is another sign that the project is not using model output blindly.
- Vision Note 026: The tracker is intentionally lightweight.
- Vision Note 027: Centroid tracking is explainable to examiners and accessible to students.
- Vision Note 028: It may not solve all multi-object edge cases.
- Vision Note 029: But it is a sensible choice for a CPU-limited prototype.
- Vision Note 030: The `update(...)` function in the tracker clearly separates no-detection, first-detection, and matching cases.
- Vision Note 031: That makes the logic teachable.
- Vision Note 032: The tracker also allows speed estimation to rely on trajectory history.
- Vision Note 033: Without continuity, speed estimation would be much less meaningful.
- Vision Note 034: The speed estimator itself is mathematically simple.
- Vision Note 035: Simplicity here is a strength because calibration assumptions are already a challenge.
- Vision Note 036: `PIXEL_TO_METER` is one of the most important accuracy-related settings.
- Vision Note 037: If it is wrong, all speeds will be wrong proportionally.
- Vision Note 038: Therefore calibration deserves serious documentation in a live deployment.
- Vision Note 039: `MIN_TRACKED_FRAMES` and related settings in `config.py` help stabilize decisions.
- Vision Note 040: Stable decisions are more important than maximum sensitivity in operator-facing systems.
- Vision Note 041: The current AI subsystem is therefore best described as pragmatic and interpretable.
- Vision Note 042: It is not chasing every state-of-the-art technique.
- Vision Note 043: It is choosing methods that can run and be explained on target hardware.
- Vision Note 044: That is often the right choice in embedded edge AI.
- Vision Note 045: The separation into files also helps students assign responsibility.
- Vision Note 046: One developer can tune OCR while another tunes tracking.
- Vision Note 047: One developer can adjust configuration without editing detector wrappers.
- Vision Note 048: This modularity supports teamwork.
- Vision Note 049: It also supports focused experiments.
- Vision Note 050: A benchmark session can isolate vehicle detection without touching the dashboard.
- Vision Note 051: A debugging session can inspect OCR results independently.
- Vision Note 052: A profiling session can inspect tracker cost independently.
- Vision Note 053: This is another reason the pipeline structure is academically valuable.
- Vision Note 054: The model wrappers explicitly force CPU execution.
- Vision Note 055: That makes deployment expectations honest for Raspberry Pi hardware.
- Vision Note 056: The OCR layer explicitly avoids assuming every result is valid.
- Vision Note 057: That makes the output more trustworthy.
- Vision Note 058: The tracker explicitly accounts for disappeared objects.
- Vision Note 059: That makes object lifetime handling more realistic.
- Vision Note 060: The combined effect is a pipeline that is more than simple “detect once” logic.
- Vision Note 061: It includes temporal reasoning, confidence reasoning, and validation reasoning.
- Vision Note 062: These are exactly the kinds of details that strengthen a graduation project.
- Vision Note 063: They show the student understands applied AI, not just library usage.
- Vision Note 064: The project could still improve with explicit quantitative evaluation.
- Vision Note 065: But the code architecture already supports such evaluation.
- Vision Note 066: For example, OCR validation rates could be logged.
- Vision Note 067: Tracker lifetime lengths could be logged.
- Vision Note 068: Speed estimate distributions could be logged.
- Vision Note 069: Emergency false-trigger and hold-time behavior could be measured.
- Vision Note 070: These future experiments are made easier by the current modular design.
- Vision Note 071: That is an important point for future work chapters.
- Vision Note 072: The AI code is therefore not only functional but also experiment-friendly.
- Vision Note 073: A student can defend each module separately and then explain how they work together.
- Vision Note 074: That layered explanation is easier for examiners to follow.
- Vision Note 075: It also mirrors how real engineering reviews happen.
- Vision Note 076: Separate modules are reviewed for purpose, input, output, and risk.
- Vision Note 077: This guide adopts that same review style.
- Vision Note 078: The combination of detectors, OCR, tracker, and config files forms the “analytical core” of the AI subsystem.
- Vision Note 079: `finish.py` then wraps that core in runtime logic.
- Vision Note 080: Both levels matter equally.
- Vision Note 081: If only the analytical core exists, deployment remains weak.
- Vision Note 082: If only runtime logic exists, AI capability remains shallow.
- Vision Note 083: The current project attempts to cover both.
- Vision Note 084: That makes the subsystem much more complete than a classroom-only script.
- Vision Note 085: The best way to maintain this subsystem is to preserve its file boundaries.
- Vision Note 086: Avoid merging OCR, detection, and tracking into one giant file.
- Vision Note 087: Doing so would hurt readability and experimentation.
- Vision Note 088: The current boundaries are already reasonable and should remain visible.
- Vision Note 089: Documentation should therefore keep naming these helper files explicitly.
- Vision Note 090: The technical guide does that on purpose.
- Vision Note 091: In a final defense, the student should emphasize that each helper file solves one type of subproblem.
- Vision Note 092: That clarity helps justify the architecture.
- Vision Note 093: It also helps justify why Python remains useful in this subsystem.
- Vision Note 094: Python supports fast experimentation around models and image processing.
- Vision Note 095: Meanwhile, the dashboard remains in C++/QML where UI integration is strongest.
- Vision Note 096: The multi-language design therefore reflects subsystem needs.
- Vision Note 097: The detector and OCR helpers are one of the clearest examples of that principle.
- Vision Note 098: They are best maintained as small, purposeful modules.
- Vision Note 099: That is already how the project is structured.
- Vision Note 100: This structure is one of the subsystem’s major strengths.

## 47. Extended Communication And Deployment Notes

- Comm Note 001: The project uses both ROS topics and JSON files because they serve different communication purposes.
- Comm Note 002: ROS topics are ideal for transient streaming data.
- Comm Note 003: JSON files are ideal for persistent and inspectable shared state.
- Comm Note 004: The monitor application benefits from both.
- Comm Note 005: Live image feeds belong naturally on ROS topics.
- Comm Note 006: Operator text, mission state, and control persistence fit naturally into JSON files.
- Comm Note 007: The server-side sync workspace suggests a deliberate effort to bridge field and monitor storage.
- Comm Note 008: This gives the project an authentic distributed-systems character.
- Comm Note 009: Distributed systems must define ownership of data.
- Comm Note 010: In this project, ownership is encoded partly by file names and partly by topic names.
- Comm Note 011: `traffic_violations.json` likely originates from AI or incident logic.
- Comm Note 012: `robot_telemetry.json` likely originates from robot-side state estimation or sync.
- Comm Note 013: `signal_control.json` can be written by the operator side and possibly consumed elsewhere.
- Comm Note 014: `monitor_ui.json` is more static and configuration-like.
- Comm Note 015: This distinction between dynamic and semi-static files is useful operationally.
- Comm Note 016: The recipes also participate in communication design by defining wrapper-based runtime paths.
- Comm Note 017: Path control is a deployment communication contract between package and filesystem.
- Comm Note 018: The app wrapper tells the binary where its JSON database lives.
- Comm Note 019: The AI wrapper tells the Python service where its runtime data lives.
- Comm Note 020: These wrappers are small but architecturally meaningful.
- Comm Note 021: They convert build-time installation into usable runtime behavior.
- Comm Note 022: The use of `externalsrc` means the build system is closely tied to the live source tree during development.
- Comm Note 023: This is efficient, but documentation must clearly state it.
- Comm Note 024: A future production flow may choose fixed source archives instead.
- Comm Note 025: For graduation work, `externalsrc` keeps iteration fast.
- Comm Note 026: Fast iteration is helpful when UI, AI, and deployment are evolving together.
- Comm Note 027: The communication architecture is therefore optimized for prototyping with real deployment intent.
- Comm Note 028: That is an academically defensible position.
- Comm Note 029: The compact emergency request file is also a communication channel.
- Comm Note 030: It is perhaps the simplest one in the project.
- Comm Note 031: Yet it is also one of the most operationally significant.
- Comm Note 032: Its simplicity is an advantage when interfacing with lower-level control logic.
- Comm Note 033: The dashboard’s context properties are another communication mechanism, this time inside the app process.
- Comm Note 034: They communicate backend state to declarative UI code.
- Comm Note 035: Good technical documentation should treat in-process and cross-device communication with equal seriousness.
- Comm Note 036: This guide therefore includes both.
- Comm Note 037: The project’s deployment communication also includes dependencies.
- Comm Note 038: The app recipe explicitly depends on Qt modules and OpenCV.
- Comm Note 039: The AI recipe explicitly depends on Python runtime pieces.
- Comm Note 040: Those dependency lists are build-time communication about runtime expectations.
- Comm Note 041: They deserve explanation because they reveal subsystem assumptions.
- Comm Note 042: For instance, the app depends on `qtlocation` and `qtpositioning`, which hints at map-related features.
- Comm Note 043: It also depends on `opencv`, which hints that image handling is not purely ROS-side.
- Comm Note 044: The AI recipe packages source, model assets, and a wrapper, revealing that the service is intended to run as a coherent target-side package.
- Comm Note 045: That is an important embedded systems lesson.
- Comm Note 046: Packaging is part of the communication story because subsystems must be discoverable and runnable after installation.
- Comm Note 047: The server launch script also communicates that ROS 2 Jazzy is part of the operational environment.
- Comm Note 048: Environment sourcing steps are therefore part of the “how the system talks” documentation.
- Comm Note 049: A first-time reader must know more than source code structure.
- Comm Note 050: They must know startup order and environment assumptions.
- Comm Note 051: The project documentation should keep those together.
- Comm Note 052: Communication problems are often integration problems in disguise.
- Comm Note 053: The project’s architecture tries to make integration points visible.
- Comm Note 054: That is a design strength.
- Comm Note 055: Visible integration points can be tested explicitly.
- Comm Note 056: They can also be documented explicitly.
- Comm Note 057: The monitor app’s file watchers are another reminder that communication is asynchronous.
- Comm Note 058: State may change outside the app.
- Comm Note 059: The app must therefore react gracefully to external updates.
- Comm Note 060: Reactivity is a communication capability.
- Comm Note 061: So is placeholder visibility when updates are absent.
- Comm Note 062: The communication layer is therefore not only transport; it is also condition reporting.
- Comm Note 063: This is especially clear in the UI’s `LIVE`, `WAITING`, and incident-queue states.
- Comm Note 064: Those states communicate communication health.
- Comm Note 065: A novice often misses this point, but operators care deeply about whether data is current.
- Comm Note 066: The project’s interface acknowledges that.
- Comm Note 067: The same idea appears in timestamps written to files.
- Comm Note 068: Timestamps help receivers judge freshness.
- Comm Note 069: Freshness is one of the most important hidden dimensions of distributed systems.
- Comm Note 070: The code demonstrates at least partial awareness of this.
- Comm Note 071: Future work could improve explicit stale-data indicators.
- Comm Note 072: But the existing architecture already has the hooks for that work.
- Comm Note 073: Because paths, files, and topics are clearly named, documentation can trace data end to end.
- Comm Note 074: This traceability is valuable in a graduation defense.
- Comm Note 075: It lets the student explain “where the data comes from” and “where it goes next.”
- Comm Note 076: Few things make a system feel more engineered than traceable data flow.
- Comm Note 077: This project has that quality.
- Comm Note 078: That is why the communication and deployment layer deserves long-form explanation.
- Comm Note 079: It is not background detail.
- Comm Note 080: It is one of the reasons the overall project works as a coherent system.
- Comm Note 081: When maintaining the project, keep file names, topic names, and wrapper environment variables stable whenever possible.
- Comm Note 082: If any of them must change, update the docs and all dependent components together.
- Comm Note 083: This discipline prevents many integration bugs.
- Comm Note 084: It also makes the project friendlier to future contributors.
- Comm Note 085: Communication architecture is often invisible until it breaks.
- Comm Note 086: The goal of this guide is to make it visible before it breaks.
- Comm Note 087: That visibility is one of the most useful forms of technical documentation.
- Comm Note 088: The current project already supports it because the contracts are explicit.
- Comm Note 089: The reports merely surface what the code already suggests.
- Comm Note 090: That is a sign of underlying design strength.
- Comm Note 091: The deployment wrappers, recipes, source paths, JSON files, and topics all form one communication web.
- Comm Note 092: Understanding that web is essential for successful integration.
- Comm Note 093: It is also essential for realistic testing.
- Comm Note 094: Testing communication one hop at a time is easier than testing everything at once.
- Comm Note 095: The project structure supports that staged approach.
- Comm Note 096: This is another reason the architecture is teachable.
- Comm Note 097: Teachability is a major positive in a graduation project.
- Comm Note 098: The communication and deployment layers contribute directly to that teachability.
- Comm Note 099: They deserve explicit study rather than being treated as secondary details.
- Comm Note 100: This section therefore frames them as central technical concerns.

## 48. Extended Debugging And Maintenance Notes

- Debug Note 001: Start debugging from the highest-level symptom, then move downward through the relevant layer.
- Debug Note 002: If the whole app fails to launch, inspect build and QML startup first.
- Debug Note 003: If the app launches but shows blank data, inspect `DataManager` and the database path.
- Debug Note 004: If the app launches and shows JSON but not video, inspect `RosStreamManager` and topic availability.
- Debug Note 005: If the app shows placeholders only, verify whether that is due to expected waiting or actual transport failure.
- Debug Note 006: Placeholder states are diagnostics, not necessarily bugs.
- Debug Note 007: If a JSON edit does not show up, check file watcher behavior and path correctness.
- Debug Note 008: If an AI file export is malformed, inspect atomic-write logic and the content generator.
- Debug Note 009: If OCR results look implausible, inspect raw text, confidence, correction rules, and validation patterns separately.
- Debug Note 010: If speed values look implausible, inspect calibration before rewriting the estimator.
- Debug Note 011: If the Street B panel never goes live, inspect the `/cma_B` versus `/cam_B` naming issue.
- Debug Note 012: If top-bar values never change, verify `TopBarController` timer setup.
- Debug Note 013: If system health never changes, verify `SystemMonitor` timers and `/proc/stat` parsing.
- Debug Note 014: If battery remains constant, remember that some Pi deployments may not expose battery sysfs files.
- Debug Note 015: Maintenance begins with respecting file ownership boundaries.
- Debug Note 016: Do not place file I/O directly in QML when `DataManager` should own it.
- Debug Note 017: Do not place ROS transport code directly in QML when `RosStreamManager` should own it.
- Debug Note 018: Do not place model-specific logic directly in `finish.py` when helper modules should own it.
- Debug Note 019: Do not bury new configuration values deep in runtime code when `config.py` is the right home.
- Debug Note 020: Stable maintenance depends on preserving these boundaries.
- Debug Note 021: If a new JSON file is needed, update the tracked-filenames list and default data coherently.
- Debug Note 022: If a new QML panel needs backend data, expose it through context properties or existing backend objects rather than ad hoc hacks.
- Debug Note 023: If a new ROS topic is needed, centralize it in `RosStreamManager`.
- Debug Note 024: If a new runtime path is needed, consider both source defaults and packaged wrappers.
- Debug Note 025: A common maintenance mistake is fixing only the development path and forgetting the deployment wrapper.
- Debug Note 026: This project’s dual development/deployment structure means both must be considered together.
- Debug Note 027: Another common maintenance mistake is changing a topic name in one place only.
- Debug Note 028: Topic names should be treated like public APIs inside the project.
- Debug Note 029: JSON keys should be treated similarly.
- Debug Note 030: Any schema change should be reflected in reports and examples.
- Debug Note 031: Because the project is used for documentation and defense, maintenance includes preserving explanatory clarity.
- Debug Note 032: If a change makes the code harder to explain, reconsider whether the change is worth it.
- Debug Note 033: Clarity is not separate from quality in a graduation project.
- Debug Note 034: It is part of quality.
- Debug Note 035: Good maintenance also means guarding against feature drift.
- Debug Note 036: The monitor app should remain a monitor app rather than absorbing every backend behavior directly.
- Debug Note 037: The AI service should remain an AI service rather than becoming a tangled mix of UI and deployment concerns.
- Debug Note 038: The recipes should remain packaging descriptors rather than shells for hidden business logic.
- Debug Note 039: Respecting these identities keeps the project understandable.
- Debug Note 040: A maintainer should also document temporary workarounds explicitly.
- Debug Note 041: Hidden workarounds become future bugs.
- Debug Note 042: The emergency model fallback path logic is an example that should be documented clearly.
- Debug Note 043: The Street B topic mismatch is another example that should be documented clearly.
- Debug Note 044: It is better to surface such issues than to pretend they do not exist.
- Debug Note 045: Debugging often improves when systems are reduced to simpler subsystems.
- Debug Note 046: The project supports this by allowing JSON-only and ROS-only reasoning separately.
- Debug Note 047: That is a major maintainability strength.
- Debug Note 048: A maintainer can test the UI with static JSON before touching live streams.
- Debug Note 049: A maintainer can test the AI service before integrating it into the dashboard.
- Debug Note 050: A maintainer can test packaging independently of runtime behavior.
- Debug Note 051: This staged testing approach should be part of team culture around the project.
- Debug Note 052: Another maintenance concern is log location.
- Debug Note 053: Runtime directories should collect useful artifacts without mixing them with source files.
- Debug Note 054: The wrappers already encourage that discipline.
- Debug Note 055: Keep using them consistently.
- Debug Note 056: If the system moves toward services, preserve the same runtime-directory assumptions.
- Debug Note 057: Consistency across manual and service launches reduces surprises.
- Debug Note 058: When debugging AI, preserve example inputs and outputs where possible.
- Debug Note 059: Reproducibility makes bug-fixing much easier.
- Debug Note 060: When debugging the app, preserve sample JSON snapshots that trigger the issue.
- Debug Note 061: Again, reproducibility matters.
- Debug Note 062: The technical guide itself can support maintenance by identifying the right file quickly.
- Debug Note 063: That is one reason the per-file discussions are so extensive.
- Debug Note 064: Maintenance is faster when file purpose is unambiguous.
- Debug Note 065: New contributors should be trained to read entry points before leaf files.
- Debug Note 066: This reduces confusion and wasted time.
- Debug Note 067: The book repeatedly models that reading order.
- Debug Note 068: If the project later adds automated tests, align them with the current subsystem boundaries.
- Debug Note 069: Test `DataManager` for storage.
- Debug Note 070: Test `RosStreamManager` for transport translation.
- Debug Note 071: Test detector wrappers for shape and failure handling.
- Debug Note 072: Test OCR validation for representative edge cases.
- Debug Note 073: Test wrapper scripts and recipes for deployment assumptions.
- Debug Note 074: This test organization mirrors the current design well.
- Debug Note 075: Maintenance should also include periodic documentation refreshes.
- Debug Note 076: A stale large report is almost as harmful as no report.
- Debug Note 077: Fortunately, the project’s explicit interfaces make refreshes manageable.
- Debug Note 078: The current guide is designed to be a living technical reference.
- Debug Note 079: Keeping it current will help future students significantly.
- Debug Note 080: The more ambitious the system becomes, the more valuable such a guide will be.
- Debug Note 081: The project should therefore treat documentation maintenance as a real engineering task.
- Debug Note 082: This is especially true because the project spans many technology stacks.
- Debug Note 083: Cross-stack systems are harder to hold in memory without written support.
- Debug Note 084: The source code is necessary but not sufficient.
- Debug Note 085: A guide like this one lowers the onboarding cost.
- Debug Note 086: Lower onboarding cost is a maintenance asset.
- Debug Note 087: Lower onboarding cost also improves project continuity after graduation.
- Debug Note 088: Continuity is often overlooked in student projects.
- Debug Note 089: The current repository is in a good position to preserve it.
- Debug Note 090: Maintenance should focus on strengthening, not disrupting, the existing architecture.
- Debug Note 091: Preserve clear interfaces.
- Debug Note 092: Preserve explicit runtime paths.
- Debug Note 093: Preserve simple, inspectable outputs.
- Debug Note 094: Preserve modular helper files.
- Debug Note 095: Preserve the relationship between code and deployment metadata.
- Debug Note 096: If those principles remain stable, the project can evolve safely.
- Debug Note 097: If those principles are ignored, complexity will become much harder to manage.
- Debug Note 098: This section therefore serves as a maintenance philosophy as much as a debugging list.
- Debug Note 099: That philosophy is grounded in the actual codebase structure.
- Debug Note 100: It should guide future changes across the repository.

## 49. Beginner Technical Exercises

- Exercise 001: Open `main.cpp` and trace every object that becomes visible to QML.
- Exercise 002: Explain in one paragraph why `DataManager` is created before `QQmlApplicationEngine::loadFromModule(...)`.
- Exercise 003: Change the development database path environment variable and observe whether the app reads from the new directory.
- Exercise 004: Create a new `traffic_violations.json` entry manually and verify whether the dashboard reflects it.
- Exercise 005: Inspect `monitor_ui.json` and rename one visible label to confirm wording is data-driven.
- Exercise 006: Trace how `systemMonitor.performanceValue` becomes a value stored in `system_health.json`.
- Exercise 007: Identify every topic name exposed by `RosStreamManager`.
- Exercise 008: Explain why placeholders are useful even when they are not visually exciting.
- Exercise 009: Follow the image-provider registration path from `main.cpp` into QML image URLs.
- Exercise 010: Identify which QML file owns the camera live-count badge.
- Exercise 011: Identify which QML file owns the traffic violation add-demo button.
- Exercise 012: Explain the purpose of `syncingSignal` in `TrafficPanel.qml`.
- Exercise 013: Modify `yellowDuration` through the UI and inspect the JSON file that changes.
- Exercise 014: Explain why `patchSignalControl(...)` is better than rewriting unrelated keys manually.
- Exercise 015: Open `vehicle_detector.py` and identify where the confidence threshold is applied.
- Exercise 016: Open `plate_detector.py` and explain how the best plate is selected.
- Exercise 017: Open `ocr_reader.py` and identify where raw OCR text is normalized.
- Exercise 018: Open `ocr_reader.py` and identify where invalid low-confidence results are marked.
- Exercise 019: Open `centroid_tracker.py` and describe what happens when no detections arrive in one frame.
- Exercise 020: Open `speed_estimator.py` and explain the role of `PIXEL_TO_METER`.
- Exercise 021: Open `config.py` and list all settings that would matter for deployment tuning.
- Exercise 022: Find the function that writes the central emergency request payload.
- Exercise 023: Explain why that payload is a text file instead of a heavy serialized object.
- Exercise 024: Find the hold-time logic in `finish.py` and describe why it exists.
- Exercise 025: Draw a mini data-flow diagram from camera image to emergency request file.
- Exercise 026: Draw a mini data-flow diagram from `SystemMonitor` to the dashboard.
- Exercise 027: Draw a mini data-flow diagram from ROS image topic to `CameraCard`.
- Exercise 028: Compare the roles of `CameraProvider` and `RosStreamImageProvider`.
- Exercise 029: Compare the roles of `monitor_ui.json` and `robot_telemetry.json`.
- Exercise 030: Explain why `QVariantMap` is convenient for JSON-backed QML data.
- Exercise 031: Inspect the Yocto app recipe and identify which dependencies are Qt-related.
- Exercise 032: Inspect the AI recipe and identify where the wrapper executable is created.
- Exercise 033: Explain why wrappers are helpful for runtime-directory control.
- Exercise 034: Explain what `externalsrc` means in the context of the current project.
- Exercise 035: List the advantages and disadvantages of `externalsrc`.
- Exercise 036: Identify where the monitor app’s default target-side database path is set.
- Exercise 037: Identify where the AI service’s default target-side runtime path is set.
- Exercise 038: Explain why static program files should not be written into the source install directory at runtime.
- Exercise 039: Explain why the project still works as a meaningful codebase even if some lower-level firmware is not present here.
- Exercise 040: List three ways the app can still be demonstrated without full live ROS data.
- Exercise 041: List three ways the app can still be demonstrated without full AI live output.
- Exercise 042: Explain why the dashboard can be useful to operators even when some streams are missing.
- Exercise 043: Identify one place where the code is optimized for first-time readability.
- Exercise 044: Identify one place where the code could use more comments.
- Exercise 045: Explain why the project is a systems project and not just an app project.
- Exercise 046: Explain why the project is a deployment project and not just a source-code project.
- Exercise 047: Explain why `DataManager` is a good place to add future `service_status.json` support.
- Exercise 048: Explain why `RosStreamManager` is a good place to add future message-latency stats.
- Exercise 049: Explain why `config.py` is a good place to add future AI thresholds.
- Exercise 050: Explain why `TrafficPanel.qml` is a good place to add new manual signal toggles.
- Exercise 051: Add a hypothetical new telemetry key and list which files would need coordinated updates.
- Exercise 052: Add a hypothetical new camera stream and list which files would need coordinated updates.
- Exercise 053: Add a hypothetical new AI summary field and decide whether it belongs in JSON or ROS.
- Exercise 054: Identify which classes are most important for thread safety.
- Exercise 055: Identify which classes are most important for file safety.
- Exercise 056: Identify which files are most important for deployment safety.
- Exercise 057: Explain why the QML layer should not be the first place you implement new persistence logic.
- Exercise 058: Explain why the Python AI side should not be the first place you implement new monitor-app wording.
- Exercise 059: Explain why the recipes should not hide large undocumented shell workflows.
- Exercise 060: Identify a design choice in the project that improves observability.
- Exercise 061: Identify a design choice in the project that improves modularity.
- Exercise 062: Identify a design choice in the project that improves deployment flexibility.
- Exercise 063: Identify a design choice in the project that improves demo readiness.
- Exercise 064: Identify a design choice in the project that improves educational value.
- Exercise 065: Explain the difference between live data and persisted data in the app.
- Exercise 066: Explain the difference between source-tree paths and target install paths.
- Exercise 067: Explain the difference between model inference code and orchestration code.
- Exercise 068: Explain the difference between a QML component and a backend data provider.
- Exercise 069: Explain the difference between a placeholder state and an error state.
- Exercise 070: Propose one automated test for `DataManager`.
- Exercise 071: Propose one automated test for `RosStreamManager`.
- Exercise 072: Propose one automated test for OCR validation.
- Exercise 073: Propose one automated test for the emergency hold-time logic.
- Exercise 074: Propose one manual test for wrapper-script deployment behavior.
- Exercise 075: Propose one manual test for JSON synchronization freshness.
- Exercise 076: Explain how this project could be used in a classroom lab.
- Exercise 077: Explain how this project could be used in an operator training session.
- Exercise 078: Explain how this project could be used in a systems-integration exam.
- Exercise 079: Explain how this project could be extended for a second graduation phase.
- Exercise 080: Explain how the project balances practical constraints and technical ambition.
- Exercise 081: Summarize the whole app startup in five sentences.
- Exercise 082: Summarize the whole AI startup in five sentences.
- Exercise 083: Summarize the whole dashboard data model in five sentences.
- Exercise 084: Summarize the whole synchronization model in five sentences.
- Exercise 085: Summarize the whole deployment model in five sentences.
- Exercise 086: Identify which file you would show first to a UI-only developer.
- Exercise 087: Identify which file you would show first to an AI-only developer.
- Exercise 088: Identify which file you would show first to a build/deployment engineer.
- Exercise 089: Identify which file you would show first to a supervisor focused on architecture.
- Exercise 090: Explain the educational reason for producing both Book 1 and Book 2.
- Exercise 091: Create a one-minute oral explanation of `main.cpp`.
- Exercise 092: Create a one-minute oral explanation of `DataManager`.
- Exercise 093: Create a one-minute oral explanation of `RosStreamManager`.
- Exercise 094: Create a one-minute oral explanation of `finish.py`.
- Exercise 095: Create a one-minute oral explanation of the AI detector/OCR/tracker split.
- Exercise 096: Create a one-minute oral explanation of the Yocto wrappers.
- Exercise 097: Create a one-minute oral explanation of the JSON synchronization model.
- Exercise 098: Create a one-minute oral explanation of the dashboard screen structure.
- Exercise 099: Create a one-minute oral explanation of the emergency request export flow.
- Exercise 100: Use this guide to prepare a complete technical onboarding session for a new teammate.

## 50. Technical Glossary For This Project

- Glossary 001: `QGuiApplication` is the Qt application type used for graphical QML-first applications.
- Glossary 002: `QQmlApplicationEngine` loads and instantiates the QML object tree.
- Glossary 003: `Q_PROPERTY` exposes C++ state to the Qt meta-object system and therefore to QML.
- Glossary 004: `Q_INVOKABLE` exposes a C++ method so QML or other Qt reflection users can call it.
- Glossary 005: `QFileSystemWatcher` watches files or directories for changes.
- Glossary 006: `QTimer` schedules repeated or delayed operations in the Qt event loop.
- Glossary 007: `QVariantMap` is a flexible key-value container useful for JSON-like data in Qt.
- Glossary 008: `QVariantList` is a flexible list container useful for JSON-like arrays in Qt.
- Glossary 009: `QQuickImageProvider` supplies images to QML through `image://` URLs.
- Glossary 010: `externalsrc` is a Yocto mechanism that builds directly from a local source tree.
- Glossary 011: `qt_add_qml_module` registers QML files and resources as a named Qt module.
- Glossary 012: `APP_HAS_ROS2` is the compile-time switch that indicates ROS dependencies were found.
- Glossary 013: `rclcpp` is the core ROS 2 C++ client library.
- Glossary 014: `sensor_msgs/msg/Image` is a common ROS message type for raw image frames.
- Glossary 015: `sensor_msgs/msg/CompressedImage` is a common ROS message type for compressed image frames.
- Glossary 016: `std_msgs/msg/String` is a simple ROS message type for text content.
- Glossary 017: `DataManager` is the dashboard backend class that owns JSON-backed state.
- Glossary 018: `RosStreamManager` is the dashboard backend class that owns ROS-backed stream state.
- Glossary 019: `SystemMonitor` is the dashboard backend class that reads local performance metrics.
- Glossary 020: `TopBarController` is the dashboard backend class that drives mission-time and simulated signal stats.
- Glossary 021: `CameraProvider` is the local-camera image provider for QML.
- Glossary 022: `RosStreamImageProvider` is the ROS-backed image provider for QML.
- Glossary 023: `monitor_ui.json` is the file that stores many UI labels and wording choices.
- Glossary 024: `robot_telemetry.json` is the file that stores robot mission and map-related state.
- Glossary 025: `signal_control.json` is the file that stores traffic-control mode and timing state.
- Glossary 026: `traffic_violations.json` is the file that stores visible traffic incident records.
- Glossary 027: `priority_vehicles.json` is the file that stores emergency or priority vehicle queue entries.
- Glossary 028: `system_health.json` is the file that stores CPU, battery, and general health indicators.
- Glossary 029: `finish.py` is the AI runtime orchestration file.
- Glossary 030: `VehicleDetector` is the Python wrapper around YOLO vehicle inference.
- Glossary 031: `PlateDetector` is the Python wrapper around YOLO plate inference.
- Glossary 032: `OCRResult` is the structured OCR return object used in `ocr_reader.py`.
- Glossary 033: `CentroidTracker` is the lightweight tracker used for object continuity across frames.
- Glossary 034: `PIXEL_TO_METER` is the calibration factor used for speed estimation.
- Glossary 035: `SPEED_LIMIT` is the configured speed threshold used by AI reasoning.
- Glossary 036: `FRAME_SKIP` is the processing-step configuration that can trade accuracy for throughput.
- Glossary 037: `MAX_DISAPPEARED` is the tracker setting that determines how long a track may vanish before removal.
- Glossary 038: `MAX_DISTANCE` is the tracker setting that limits matching between old and new detections.
- Glossary 039: `OCR_CONFIDENCE` is the confidence threshold used to judge OCR trustworthiness.
- Glossary 040: `MONITOR_APP_DB_PATH` is the runtime environment variable that tells the app where its JSON database lives.
- Glossary 041: `TRAFFIC_AI_RUNTIME_DIR` is the runtime environment variable that tells the AI service where to store mutable data.
- Glossary 042: `UPLOAD_DIR` is the AI runtime directory for staged input data.
- Glossary 043: `EXPORT_DIR` is the AI runtime directory for generated outputs.
- Glossary 044: `EMERGENCY_REQUEST_FILE` is the compact exported file that communicates road-open priority.
- Glossary 045: `hold_until` is the timestamp used to debounce clearing of an active emergency request.
- Glossary 046: `last_confirmed_at` is the timestamp used for recency-based arbitration.
- Glossary 047: `placeholder frame` is a synthetic UI image used when a live stream is not available.
- Glossary 048: `atomic write` is a file-writing approach that reduces the risk of partially visible outputs.
- Glossary 049: `runtime wrapper` is a small executable script that sets environment variables and launches the real program.
- Glossary 050: `target runtime state` means files or directories that the program must modify after installation.
- Glossary 051: `install path` means where packaged program assets live on the target filesystem.
- Glossary 052: `source path` means where development files live in the working repository.
- Glossary 053: `composition root` means the file where major dependencies are assembled together.
- Glossary 054: `orchestration file` means a file that coordinates many helper modules and runtime concerns.
- Glossary 055: `edge AI` means running AI near the data source rather than only on a remote server.
- Glossary 056: `operator dashboard` means a human-facing interface for monitoring and limited control.
- Glossary 057: `distributed system` means a system whose components run on multiple communicating devices.
- Glossary 058: `IoT layer` means the part of the project that connects devices, servers, and synchronized data.
- Glossary 059: `ROS topic` means a named publish-subscribe channel in ROS 2.
- Glossary 060: `context property` means a C++ object exposed to QML by name.
- Glossary 061: `QML module` means a registered group of QML files loaded as one named package.
- Glossary 062: `image provider URL` means a QML image source like `image://roscam/robot`.
- Glossary 063: `live count` means the number of streams currently considered online.
- Glossary 064: `AI summary` means a concise text statement that represents interpreted AI state for operators.
- Glossary 065: `schema` means the expected structure and keys of a file or message.
- Glossary 066: `transport` means the mechanism by which data moves from one component to another.
- Glossary 067: `persistent state` means data intended to survive across program restarts or asynchronous updates.
- Glossary 068: `transient state` means data that is useful only in the moment, such as live frames.
- Glossary 069: `prototype hardening` means the work of making a prototype more reliable, secure, and automated.
- Glossary 070: `service orchestration` means managing how long-running components start, stop, and recover.
- Glossary 071: `debug artifact` means a file, log, or sample that helps reproduce or understand a problem.
- Glossary 072: `observability` means how easily operators and developers can infer current system state.
- Glossary 073: `degraded mode` means a partially working state where the system still communicates what is missing.
- Glossary 074: `first-run defaults` means initial example data created when expected files do not exist yet.
- Glossary 075: `recency arbitration` means selecting the newest valid event when multiple candidates exist.
- Glossary 076: `plate crop` means the image region extracted as a probable license plate.
- Glossary 077: `vehicle crop` means the image region extracted around a detected vehicle.
- Glossary 078: `confidence threshold` means the minimum model confidence required for acceptance.
- Glossary 079: `multi-pass OCR` means repeated OCR attempts or validation logic designed to improve text reading results.
- Glossary 080: `deployment reproducibility` means being able to build and run the same software stack again reliably.
- Glossary 081: `BitBake recipe` means the metadata file that describes how a package is built and installed in Yocto.
- Glossary 082: `Yocto layer` means a collection of metadata used to define builds and packages.
- Glossary 083: `Qt resource` means a non-code asset such as an image or font shipped with the application.
- Glossary 084: `mission telemetry` means state describing robot progress, route, and navigation context.
- Glossary 085: `priority vehicle` means an emergency or privileged vehicle that may influence traffic control decisions.
- Glossary 086: `UI wording layer` means the set of labels and titles that define how the dashboard speaks to the operator.
- Glossary 087: `stream freshness` means how recently a live stream produced a new frame.
- Glossary 088: `frame polling` means repeatedly refreshing an image source to fetch the latest frame.
- Glossary 089: `CPU-bound inference` means model execution limited primarily by processor speed rather than a GPU.
- Glossary 090: `maintainability` means how easily future developers can change and understand the code.
- Glossary 091: `readability` means how easily a human can understand the code or document structure.
- Glossary 092: `demo readiness` means how easily a project can be shown successfully in a controlled presentation.
- Glossary 093: `manual override` means human control that supersedes automated behavior.
- Glossary 094: `control hint` means an AI or monitoring output that suggests an operational decision.
- Glossary 095: `field node` means a device deployed near sensors or actuators rather than at the operator desk.
- Glossary 096: `monitor host` means the laptop or server that presents the dashboard and central view.
- Glossary 097: `source-of-truth file` means the file authoritative for a certain class of persisted dashboard state.
- Glossary 098: `interface contract` means the expected inputs, outputs, names, and structures another component depends on.
- Glossary 099: `technical guide` means a code-oriented document explaining implementation and usage.
- Glossary 100: `scientific report` means a formal academic document explaining motivation, architecture, implementation, results, and future work.

## 51. Final Technical Review Checklist

- Review 001: Confirm that `main.cpp` still exposes the backend objects with the names expected by QML.
- Review 002: Confirm that `MONITOR_APP_DB_PATH` is documented in both source comments and deployment notes.
- Review 003: Confirm that `DataManager` still tracks the complete intended set of JSON files.
- Review 004: Confirm that every tracked JSON file has a sensible default structure.
- Review 005: Confirm that `monitor_ui.json` remains aligned with visible QML label usage.
- Review 006: Confirm that `robot_telemetry.json` still supplies the fields expected by map and mission panels.
- Review 007: Confirm that `signal_control.json` still supplies the fields expected by `TrafficPanel.qml`.
- Review 008: Confirm that `traffic_violations.json` still supplies the fields expected by incident and AI panels.
- Review 009: Confirm that `priority_vehicles.json` still supplies the fields expected by the queue display.
- Review 010: Confirm that file writes still use safe patterns where cross-process visibility matters.
- Review 011: Confirm that file watchers still reload correctly after external synchronization events.
- Review 012: Confirm that malformed JSON produces visible errors rather than silent failure.
- Review 013: Confirm that `SystemMonitor` still updates CPU and battery-related properties on a reasonable cadence.
- Review 014: Confirm that `TopBarController` is clearly identified as simulated if real metrics are not yet wired.
- Review 015: Confirm that `CameraProvider` still degrades gracefully when `/dev/video0` is absent.
- Review 016: Confirm that `RosStreamManager` still compiles when ROS is absent.
- Review 017: Confirm that `RosStreamManager` still activates ROS support when dependencies are present.
- Review 018: Confirm that topic defaults are documented and consistent across code and reports.
- Review 019: Confirm that the Street B topic naming decision is finalized or clearly documented if still mixed.
- Review 020: Confirm that placeholder frames remain informative and readable.
- Review 021: Confirm that `Main.qml` still loads the intended monitor module and pages.
- Review 022: Confirm that navigation actions still connect correctly from the root window to the stack view.
- Review 023: Confirm that `Monitor_window.qml` remains the main live monitor composition file.
- Review 024: Confirm that `CameraNetwork.qml` still reflects live-count status correctly.
- Review 025: Confirm that `StreetAIPanel.qml` still handles empty AI and empty incident states cleanly.
- Review 026: Confirm that `TrafficPanel.qml` still guards against recursive write loops.
- Review 027: Confirm that demo-add and clear-latest actions still operate against the expected backend methods.
- Review 028: Confirm that reusable QML components remain factored instead of copied into large monolithic files.
- Review 029: Confirm that font and image assets are still installed with the app package.
- Review 030: Confirm that the CMake QML registration still includes all intended monitor components.
- Review 031: Confirm that `APP_HAS_ROS2` compile definitions still match the actual dependency detection logic.
- Review 032: Confirm that `find_package(OpenCV REQUIRED)` remains appropriate for all image-handling features in use.
- Review 033: Confirm that the app recipe dependency list still matches actual runtime features.
- Review 034: Confirm that the AI recipe dependency list still matches actual Python runtime needs.
- Review 035: Confirm that the app wrapper still exports the correct target database path variable.
- Review 036: Confirm that the AI wrapper still exports the correct runtime directory variable.
- Review 037: Confirm that source paths used by `externalsrc` still match the real development folders.
- Review 038: Confirm that target-side writable directories are still separated from installed source assets.
- Review 039: Confirm that `finish.py` remains the single orchestration root for AI runtime control.
- Review 040: Confirm that detector helper modules remain thin wrappers rather than absorbing unrelated logic.
- Review 041: Confirm that OCR validation still returns structured metadata and not only raw text.
- Review 042: Confirm that tracker logic still handles disappeared objects and new objects clearly.
- Review 043: Confirm that speed estimation still documents its calibration dependence.
- Review 044: Confirm that configuration values remain centralized in `config.py`.
- Review 045: Confirm that model paths can still be overridden through the environment when needed.
- Review 046: Confirm that runtime directories can still be relocated through the environment when needed.
- Review 047: Confirm that emergency-request output still uses a stable and documented format.
- Review 048: Confirm that emergency hold-time logic still prevents oscillation under transient detection loss.
- Review 049: Confirm that arbitration behavior for multiple active requests remains deterministic.
- Review 050: Confirm that timestamps remain present where freshness is operationally important.
- Review 051: Confirm that `ocr_reader.py` still records raw text, confidence, and validation state together.
- Review 052: Confirm that correction rules and validation patterns still match the intended plate formats.
- Review 053: Confirm that CPU-only inference assumptions remain realistic for the target hardware.
- Review 054: Confirm that the project documentation still distinguishes implemented code from planned extensions.
- Review 055: Confirm that lower-level firmware is not described as present when it is not actually in the repository snapshot.
- Review 056: Confirm that the code guide still references the real primary files and not outdated experiments only.
- Review 057: Confirm that `Main.qml`, `Monitor_window.qml`, `CameraNetwork.qml`, `StreetAIPanel.qml`, and `TrafficPanel.qml` are still the best reading order for QML onboarding.
- Review 058: Confirm that `main.cpp`, `DataManager`, `RosStreamManager`, and `finish.py` are still the best reading order for backend onboarding.
- Review 059: Confirm that the server-side synchronization launch command still matches the real ROS workspace path.
- Review 060: Confirm that startup instructions still include both base ROS sourcing and workspace sourcing.
- Review 061: Confirm that JSON-only app demonstrations still work for partial system testing.
- Review 062: Confirm that ROS-only stream demonstrations still work independently of AI event generation.
- Review 063: Confirm that AI-only export testing still works independently of the dashboard.
- Review 064: Confirm that integrated demos still have a documented startup order.
- Review 065: Confirm that runtime logs and artifacts are saved where maintainers expect them.
- Review 066: Confirm that the project remains understandable to a first-time student reader.
- Review 067: Confirm that the technical guide remains aligned with the latest source structure.
- Review 068: Confirm that the scientific report remains aligned with the latest architecture and deployment story.
- Review 069: Confirm that the QML layer still avoids direct file I/O and transport logic where backend classes should own them.
- Review 070: Confirm that code ownership boundaries remain visible between UI, persistence, transport, and AI logic.
- Review 071: Confirm that any new JSON files or topics are added to the documentation at the same time as the code.
- Review 072: Confirm that any changed environment variable names are updated in wrapper scripts and reports together.
- Review 073: Confirm that any changed file names are updated in `DataManager`, sync tools, and reports together.
- Review 074: Confirm that any changed topic names are updated in `RosStreamManager`, publishers, and reports together.
- Review 075: Confirm that any changed model names or paths are updated in `config.py`, packages, and deployment notes together.
- Review 076: Confirm that example screenshots or demo datasets still match the current UI wording and schema.
- Review 077: Confirm that the project’s strongest quality, observability, has not been weakened by later changes.
- Review 078: Confirm that placeholder and degraded modes still communicate clearly to operators.
- Review 079: Confirm that the interface still makes the difference between live and waiting states obvious.
- Review 080: Confirm that the code still supports staged debugging one subsystem at a time.
- Review 081: Confirm that no future refactor has hidden critical logic inside undocumented scripts.
- Review 082: Confirm that no future refactor has moved operational constants into scattered hard-coded locations.
- Review 083: Confirm that no future refactor has made the bootstrap files overly large or unclear.
- Review 084: Confirm that no future refactor has merged independent helper modules into unreadable monoliths.
- Review 085: Confirm that no future refactor has broken deployment by assuming development-only paths on the target.
- Review 086: Confirm that no future refactor has removed useful default demo data without replacement.
- Review 087: Confirm that no future refactor has weakened error visibility for sync or parse failures.
- Review 088: Confirm that no future refactor has removed the clean separation between installed assets and writable runtime directories.
- Review 089: Confirm that all major layers still have one obvious entry point for first-time readers.
- Review 090: Confirm that all major layers still have one obvious place to extend configuration safely.
- Review 091: Confirm that all major layers still have one obvious place to inspect during first-pass debugging.
- Review 092: Confirm that the project still supports a convincing graduation demonstration narrative.
- Review 093: Confirm that the project still supports a convincing systems-engineering explanation.
- Review 094: Confirm that the project still supports a convincing embedded-deployment explanation.
- Review 095: Confirm that the project still supports a convincing AI-and-computer-vision explanation.
- Review 096: Confirm that the project still supports a convincing ROS-and-IoT explanation.
- Review 097: Confirm that the project still supports a convincing UI-and-operator-visibility explanation.
- Review 098: Confirm that the code and documentation together still feel intentional and coherent.
- Review 099: Confirm that both books remain large, detailed, and useful as handover material.
- Review 100: Confirm that the documentation continues to help the next reader move from source code to real understanding.
