# College Report: IoT Directory

## 1. Introduction

This directory contains the IoT-focused documentation for the traffic robot project.

Its purpose is to explain how:

- Raspberry Pi 4
- Raspberry Pi 5
- the server or laptop
- ROS 2 networking
- the monitor database
- the QML application

all work together as one distributed system.

## 2. Directory Purpose

The `iot` directory documents the communication architecture of the whole project.

It helps answer questions such as:

- where does the data come from
- how do the devices communicate
- which machine is responsible for which task
- what is already implemented
- what still needs integration work

## 3. Main Files

This directory currently includes:

- `IOT_RPI4_RPI5_SERVER_ROS_REPORT.md`
- `IOT_TASKS_AND_BEGINNER_GUIDE.md`

## 4. Meaning Of Each File

`IOT_RPI4_RPI5_SERVER_ROS_REPORT.md`

- technical architecture document
- explains RPi4, RPi5, server, ROS, and monitor app relationships
- identifies implemented links and missing bridges

`IOT_TASKS_AND_BEGINNER_GUIDE.md`

- beginner-friendly explanation
- written for first-time readers
- includes network meaning, roles, and next tasks

## 5. Academic Importance

This directory is valuable in a college context because it shows:

- distributed systems thinking
- multi-device communication design
- ROS 2 middleware usage
- application-level state synchronization
- separation of control, monitoring, and AI functions

The project is not only an app.

It is a networked embedded system.

## 6. Main IoT Components Described Here

The documents in this folder describe three major communication pieces:

- ROS 2 database synchronization
- live camera and AI topic transport
- remote control and monitoring workflow

## 7. Main Strengths Of The IoT Design

- clear machine roles
- use of ROS 2 for network transport
- use of a synchronized JSON database for shared UI state
- monitor application designed as a remote supervision interface
- support for both AI-assisted control and manual control

## 8. Main Gaps Still Identified

- full bridge from traffic AI to monitor UI is not fully shown
- topic naming is not fully standardized
- `/street_ai_monitor` publisher is not clearly confirmed in the reviewed code
- traffic AI outputs are not yet fully written into the shared monitor database

## 9. Educational Value

Students reading this folder can learn:

- how ROS 2 is used across machines
- how UI state can be synchronized with message passing
- how to separate device roles in a robotics project
- how to document implemented versus planned architecture honestly

## 10. Relationship To Other Folders

This folder depends on:

- `ros2_autonoums` for robot-side ROS nodes
- `traffic_ai_model` for AI and smart-intersection logic
- `traffic_robot_app` for the operator UI
- `configuration` for Yocto deployment strategy

## 11. Suggested Reader Workflow

1. read the beginner guide
2. read the technical IoT report
3. inspect the monitor database path
4. inspect the ROS sync workspace
5. compare the topic names expected by the monitor app

## 12. Conclusion

The `iot` directory is the communication map of the project.

For a college submission, it shows that the project team understands:

- multi-device design
- network-based robotics
- operator supervision architecture
- real integration challenges between AI, UI, and embedded hardware

## 13. Code Example And How To Use It

Example from the server-side database sync startup script:

```bash
source /opt/ros/jazzy/setup.bash
source /media/abso/project/database/monitor_app/monitor_app_db_sync_ws/install/setup.bash
ros2 launch monitor_app_db_sync laptop_db_bidirectional.launch.py
```

How to use it:

- the first line loads ROS 2 Jazzy
- the second line loads the local workspace that contains the sync package
- the third line starts the bidirectional sync node on the monitor machine

Practical use:

- run this on the server or laptop
- run the matching Pi-side launch on Raspberry Pi
- verify that database files update in both directions

## 14. Detailed Walkthrough

The IoT side can be explained with one simple data path:

1. a device updates data
2. ROS 2 transports the update
3. the monitor machine receives it
4. the app displays it

Example payload-building code from the sync package logic:

```python
def make_payload(filename: str, content: str, source: str, timestamp: int) -> str:
    return json.dumps({
        "filename": filename,
        "content": content,
        "source": source,
        "timestamp": timestamp,
    }, ensure_ascii=False)
```

Meaning:

- every synced file update becomes one structured JSON message
- the receiver knows which file changed
- the receiver knows the source machine
- the receiver knows when the update was created

Why this is useful:

- it avoids raw ad-hoc text transport
- it keeps the sync logic general for many files
- it helps avoid confusion in a multi-machine setup

The practical operator-facing result is that:

- the server app can reflect remote robot and traffic changes
- the operator can make changes that go back to the Raspberry Pi side
