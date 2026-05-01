# College Report: Traffic Robot App Source Directory

## 1. Introduction

This directory contains the active Qt 6 + QML source code of the traffic robot monitor application.

It is the implementation-level source of the UI.

## 2. Purpose

The folder contains:

- C++ backend code
- QML screens
- image providers
- file-based data management
- optional ROS 2 stream handling

## 3. Main Important Files

- `main.cpp`
- `datamanager.cpp`
- `rosstreammanager.cpp`
- `systemmonitor.cpp`
- `camera.cpp`
- `qml/`

## 4. Main Engineering Ideas

- JSON files are used as persistent live state
- QML is used as the operator UI layer
- ROS topics are used for live streams when available
- placeholder behavior is included for offline topics

## 5. Academic Value

This directory is important for a college reader because it shows:

- UI-to-backend interaction
- data-driven interface design
- practical use of Qt 6 in robotics monitoring
- integration of ROS and desktop UI concepts

## 6. What A Student Can Study Here

- Qt application bootstrap
- QML component organization
- file watching with C++
- JSON parsing and saving
- ROS subscription patterns in a UI app

## 7. Conclusion

This directory contains the real implementation of the monitor application and is one of the strongest evidence folders for the software-engineering side of the project.

## 8. Code Example And How To Use It

Example from [datamanager.cpp](/media/abso/yocto/traffic_robot/traffic_robot_app/source/datamanager.cpp):

```cpp
QStringList DataManager::trackedFilenames() const
{
    return {
        QStringLiteral("traffic_violations.json"),
        QStringLiteral("priority_vehicles.json"),
        QStringLiteral("signal_control.json"),
        QStringLiteral("system_health.json"),
        QStringLiteral("monitor_ui.json"),
        QStringLiteral("robot_telemetry.json"),
    };
}
```

How to use it:

- this function defines the database files watched by the app
- if you add a new JSON-backed feature, you must extend this list

Practical extension steps:

1. add the new filename here
2. add default content in `defaultDataFor()`
3. add matching UI properties and QML bindings

## 9. Detailed Walkthrough

The source code of the app can be divided into three main backend responsibilities.

### Backend responsibility 1: application startup

Handled mainly in `main.cpp`.

This file:

- creates the Qt application
- initializes ROS if available
- creates backend objects
- exposes them to QML

### Backend responsibility 2: persistent UI state

Handled mainly in `datamanager.cpp`.

This file:

- knows which JSON files matter
- creates defaults
- loads and saves data
- reacts to file changes

### Backend responsibility 3: live ROS visualization

Handled mainly in `rosstreammanager.cpp`.

This file:

- knows the topic names
- subscribes to images and AI text
- keeps stream online/offline state
- provides frames to QML

Example topic setup:

```cpp
, m_robotTopic(topicFromEnvironment("MONITOR_CAM_ROBOT_TOPIC", "/cam_robot"))
, m_streetATopic(topicFromEnvironment("MONITOR_CAM_A_TOPIC", "/cam_A"))
, m_streetBTopic(topicFromEnvironment("MONITOR_CAM_B_TOPIC", "/cma_B"))
, m_aiTopic(topicFromEnvironment("MONITOR_STREET_AI_TOPIC", "/street_ai_monitor"))
```

Meaning:

- the app can work with default topic names
- but it can also be adapted at runtime without recompiling
