# IoT ROS Integration Report

## Project Scope

This report describes the IoT and ROS connection architecture between:

- Raspberry Pi 5
- Raspberry Pi 4
- server / monitor host
- ROS 2 network
- QML monitor application
- AI traffic model
- robot control stack

It is based on the current files reviewed on `2026-05-01`.

## Important Path Note

The requested save path `/media/abso/yoctotraffic_robot/iot` does not exist in the current filesystem.

The report is saved in the existing project root here:

- `/media/abso/yocto/traffic_robot/iot/IOT_RPI4_RPI5_SERVER_ROS_REPORT.md`

## 1. Executive Summary

The current system is best understood as three connected ROS/IoT subprojects:

1. `monitor_app_db_sync`
   A ROS 2 database synchronization service that transfers the monitor JSON database between Raspberry Pi and the server/monitor machine.

2. `traffic_robot_app`
   A Qt 6 + QML operator dashboard that reads the synchronized JSON database and also subscribes to live ROS camera and AI topics.

3. `ros2_autonoums` plus `traffic_ai_model`
   The robot-side ROS stack handles camera perception, manual driving, and autonomous follow behavior, while the traffic AI model handles two-camera traffic monitoring and emergency-priority logic.

In the current implementation:

- the server/monitor host acts as the main UI and database machine
- Raspberry Pi 5 is the main robot-control side
- Raspberry Pi 4 is the likely traffic AI / street-monitor side
- ROS 2 DDS is the transport layer between nodes across machines
- the monitor database is a shared system state channel between the app and remote devices

## 2. Main Machines And Their Roles

## 2.1 Raspberry Pi 5

The reviewed codebase supports Raspberry Pi 5 as the robot-side control platform.

Its role is:

- run robot motor control
- run follow-me and manual teleoperation logic
- publish or receive robot camera data over ROS 2
- maintain or sync robot-related monitor database content
- feed telemetry and motion state to the monitoring side

Evidence from the reviewed ROS project:

- `camjam_movement` uses `gpiod` and Pi 5 safe GPIO handling
- `manual_control` accepts teleop commands on `/manual_control/cmd_vel`
- `pwm_driver` drives motion outputs
- `abso_follower` publishes robot movement commands on `/cmd_vel`

## 2.2 Raspberry Pi 4

The reviewed Yocto and AI packaging work makes Raspberry Pi 4 the most likely traffic-monitoring and AI-analysis side.

Its role is:

- run the traffic AI model
- process exactly two camera streams
- detect vehicles, violations, and emergency vehicles
- compute signal timing state internally
- generate emergency road-open requests for the controller side

Evidence from the reviewed AI project:

- the AI service expects exactly two sources
- `cam0` and `cam1` are mapped to two roads
- the service writes `exports/emergency_request.txt`
- the service writes CSV reports and text summaries per camera

## 2.3 Server / Monitor Host

In the current code, the machine called "laptop" in the ROS package is effectively the server / monitor host.

Its role is:

- store the monitor JSON database at:
  - `/media/abso/project/database/monitor_app`
- run the bidirectional ROS database sync package
- run the QML monitor application
- subscribe to ROS image and AI topics for live visualization
- allow the operator to update control and telemetry state through the JSON-backed app

## 3. Project 1: Database Transfer Between RPi5 And Server

This is the most concrete implemented IoT piece in the current project.

### 3.1 Workspace

The database sync package lives at:

- `/media/abso/project/database/monitor_app/monitor_app_db_sync_ws`

Package name:

- `monitor_app_db_sync`

### 3.2 Purpose

This package synchronizes the monitor app JSON database between:

- Raspberry Pi path:
  - `/root/database/monitor_app`
- server path:
  - `/media/abso/project/database/monitor_app`

### 3.3 Tracked Files

The sync package transfers these files:

- `traffic_violations.json`
- `priority_vehicles.json`
- `signal_control.json`
- `system_health.json`
- `monitor_ui.json`
- `robot_telemetry.json`

These files are the shared operational state for the monitor app.

### 3.4 ROS Transport Design

The package uses ROS 2 `std_msgs/String` messages with JSON payloads.

Each payload contains:

- filename
- full file content
- source ID
- timestamp

This makes the sync logic independent from file mounting or SSH copy.

### 3.5 Topics

Current default topics are:

- RPi to server:
  - `/monitor_app_db_sync/update`
  - or in bidirectional mode:
  - `/monitor_app_db_sync/rpi_to_laptop`

- server to RPi:
  - `/monitor_app_db_sync/laptop_to_rpi`

### 3.6 Reliability Settings

The sync package uses:

- `ReliabilityPolicy.RELIABLE`
- `DurabilityPolicy.TRANSIENT_LOCAL`
- queue depth `32`

This is a good fit for configuration/state distribution because:

- updates should not be dropped
- late subscribers can still get recent data

### 3.7 Loop Prevention

The package includes local echo suppression through:

- `.monitor_app_db_sync_state.json`

This prevents a remotely applied file from being immediately republished back as a false local edit.

### 3.8 Launch Files

Raspberry Pi side:

- `rpi_db_publisher.launch.py`
- `rpi_db_bidirectional.launch.py`

Server side:

- `laptop_db_subscriber.launch.py`
- `laptop_db_bidirectional.launch.py`

### 3.9 ROS Network Setup

The launch files set:

- `ROS_DOMAIN_ID=42`
- `ROS_LOCALHOST_ONLY=0`
- `ROS_AUTOMATIC_DISCOVERY_RANGE=SUBNET`

This means:

- all machines must be in the same ROS domain
- communication is intended across the local subnet
- the system is designed for LAN-based ROS discovery

### 3.10 Meaning For The Project

This part already supports the user requirement that:

- the database is transferred from a Raspberry Pi to the monitor application
- the monitor side can also write data back to the Raspberry Pi in bidirectional mode

## 4. Project 2: Camera Signal Transfer To Server And App Monitor

This is the second IoT piece: live ROS camera streaming into the monitor UI.

### 4.1 Monitor App Expectations

The QML monitor app subscribes to live ROS streams through `RosStreamManager`.

Expected camera topics are:

- `/cam_robot`
- `/cam_A`
- `/cma_B`

Expected AI text topic:

- `/street_ai_monitor`

The app also listens for compressed versions:

- `/cam_robot/compressed`
- `/cam_A/compressed`
- `/cma_B/compressed`

### 4.2 App Behavior

When ROS topics are live, the app:

- decodes raw `sensor_msgs/Image`
- decodes `sensor_msgs/CompressedImage`
- marks streams online/offline
- computes simple FPS values
- displays images inside QML

When topics are missing, the app:

- keeps placeholder frames
- shows waiting state text

### 4.3 Server-Side Role

This makes the server/monitor host the live visualization point for:

- robot front camera
- street A camera
- street B camera
- AI summary stream

This matches the requested idea of:

- transferring camera signal to the server
- using the app for monitor and control

### 4.4 Current Integration Finding

The monitor app side is implemented clearly.

However, in the reviewed source:

- the consumer for `/street_ai_monitor` exists
- the publisher for `/street_ai_monitor` was not found in the reviewed AI model code

So the UI is ready to consume AI summary text, but a dedicated ROS publisher or bridge node still appears to be needed.

## 5. Project 3: Robot Camera Publisher, Server Subscriber, Manual Control, AI Control

This is the combined ROS robot-control side.

### 5.1 Real Robot Control Flow

From the reviewed ROS documentation, the current control path is:

1. `camera_publisher_cv` publishes `/camera/image_raw`
2. `abso_face_camera_recorder` reads camera frames and publishes perception topics
3. `abso_follower` converts perception into `/cmd_vel`
4. `camjam_movement` receives `/cmd_vel` and drives motors through `gpiod`

### 5.2 Manual Remote Control

Manual teleoperation exists in two forms:

- direct CamJam movement path:
  - keyboard teleop -> `/cmd_vel` -> `camjam_movement`

- Pi 5 manual PWM path:
  - keyboard teleop -> `/manual_control/cmd_vel` -> `manual_control` -> `/motor_commands` -> `pwm_driver`

This satisfies the requirement that the robot can be moved manually over ROS.

### 5.3 AI-Based Robot Control

The robot-follow project already supports AI-guided motion:

- detect target from camera
- classify left / center / right
- convert that to turn-left / move-forward / turn-right
- stop if target missing or emergency active

This means the ROS project already uses computer vision data for motion decisions.

### 5.4 Network Camera Sharing

The ROS documentation also describes a networked mode where:

- a laptop publishes `/camera/image_raw`
- the Raspberry Pi receives it over DDS
- the Pi performs the follow logic locally

This proves the architecture already supports remote camera publishing with a remote subscriber.

### 5.5 Current Topic Naming Gap

There is an important integration mismatch between the robot ROS project and the QML monitor app:

- the robot/follow project documents `/camera/image_raw`
- the QML app expects `/cam_robot`, `/cam_A`, `/cma_B`

This means one of these is still required:

- topic remapping
- republishing bridge
- standardized naming across all projects

Without this, the monitor app may stay in waiting mode even if the robot camera publisher is running.

## 6. Monitor Database As The Shared IoT State

The database at:

- `/media/abso/project/database/monitor_app`

is the main shared application state for the operator side.

### 6.1 File Roles

- `traffic_violations.json`
  - event log for violations

- `priority_vehicles.json`
  - queue of ambulance / fire truck / priority logic

- `signal_control.json`
  - traffic light mode, active direction, durations, AI/manual mode

- `system_health.json`
  - CPU, battery, memory, network, temperature

- `monitor_ui.json`
  - labels, panel wording, topic hints

- `robot_telemetry.json`
  - robot map, mission state, route state, status, location

### 6.2 App Behavior

The QML app:

- watches these files live
- writes edits immediately
- reloads external changes automatically

This means the JSON database acts like:

- shared HMI state
- local control memory
- persistence layer between ROS updates and UI

## 7. How RPi4, RPi5, And Server Connect In The Intended System

Based on the code and the user description, the intended full system architecture is:

### 7.1 Raspberry Pi 5 Side

- hosts robot movement stack
- may host robot camera publishing
- may own local robot-side database copy at `/root/database/monitor_app`
- sends database state to the server
- receives operator changes back from the server

### 7.2 Raspberry Pi 4 Side

- runs the traffic AI model on two street cameras
- detects traffic violations and emergency vehicles
- computes emergency road-open requests
- should provide AI outputs to the server side for visualization and control

### 7.3 Server Side

- aggregates the monitor database
- runs the QML dashboard
- subscribes to live camera and AI topics
- acts as operator console for monitoring and traffic control
- can send control changes back toward the Raspberry Pi side through the bidirectional database sync

## 8. What Is Implemented Today Vs What Still Needs A Bridge

This distinction is important.

### 8.1 Implemented Today

- ROS 2 JSON database sync between Pi and server
- QML monitor app reading and writing the JSON database
- QML monitor app subscribing to live ROS image and AI text topics
- robot manual control on Pi 5
- robot AI follow-me control using ROS vision topics
- traffic AI model generating emergency request file and reports

### 8.2 Not Fully Connected Yet In The Reviewed Code

- direct publisher from the traffic AI model to `/street_ai_monitor`
- direct bridge from traffic AI model outputs into `traffic_violations.json`
- direct bridge from traffic AI model outputs into `priority_vehicles.json`
- direct bridge from traffic AI model outputs into `signal_control.json`
- direct bridge from traffic AI model into robot movement topics such as `/cmd_vel`
- unified topic naming between `/camera/image_raw` and `/cam_*`

## 9. Realistic Control Interpretation

The current reviewed code supports two different kinds of AI control:

### 9.1 Robot Motion AI

This exists in the ROS robot project.

Flow:

- camera -> vision topics -> `abso_follower` -> `/cmd_vel` -> motor driver

### 9.2 Traffic Signal AI

This exists in the traffic AI model.

Flow:

- street cameras -> AI detection -> `emergency_request.txt` -> external signal controller

### 9.3 What Is Not Shown Yet

The reviewed code does not show the traffic AI model directly moving the robot.

So if the desired architecture is:

- RPi4 AI model decides robot movement

then a new ROS bridge is still needed to convert AI outputs into robot motion topics or into the server-side control app.

## 10. Recommended IoT Integration Architecture

To make the whole system match the requested design, the cleanest architecture is:

### Layer A: Robot Side On RPi5

- run robot control stack
- publish robot camera as `/cam_robot`
- publish robot telemetry updates
- run bidirectional database sync node

### Layer B: Traffic AI Side On RPi4

- run the two-camera traffic AI model
- add a ROS publisher for `/street_ai_monitor`
- add a bridge node that converts AI results into:
  - `traffic_violations.json`
  - `priority_vehicles.json`
  - possibly `signal_control.json`
- optionally publish camera streams as `/cam_A` and `/cma_B`

### Layer C: Server / Monitor Host

- run `monitor_app_db_sync`
- run `traffic-robot-app`
- subscribe to `/cam_robot`, `/cam_A`, `/cma_B`, `/street_ai_monitor`
- allow operator changes to flow back through the JSON sync layer

## 11. Recommended Next Engineering Steps

1. Standardize camera topic names across all ROS projects.
2. Add a dedicated ROS publisher node for `/street_ai_monitor`.
3. Add an adapter from RPi4 AI outputs into the monitor database files.
4. Decide whether traffic AI should control only signals or also robot movement.
5. If robot movement should be controlled by RPi4 AI, add a ROS command bridge to `/cmd_vel` or `/manual_control/cmd_vel`.
6. Keep the server as the single operator-facing monitor and control point.
7. Validate the full multi-machine system with all devices on the same ROS domain and subnet.

## 12. Suggested Runtime Deployment

### On RPi5

- robot control nodes
- camera publisher
- `ros2 launch monitor_app_db_sync rpi_db_bidirectional.launch.py`

### On RPi4

- traffic AI model
- future `/street_ai_monitor` publisher
- future AI-to-database or AI-to-ROS bridge

### On Server

- `source /opt/ros/jazzy/setup.bash`
- `source /media/abso/project/database/monitor_app/monitor_app_db_sync_ws/install/setup.bash`
- `ros2 launch monitor_app_db_sync laptop_db_bidirectional.launch.py`
- start the QML monitor app

## 13. Source Files Used

- `/media/abso/project/database/monitor_app/database.sh`
- `/media/abso/project/database/monitor_app/monitor_ui.json`
- `/media/abso/project/database/monitor_app/robot_telemetry.json`
- `/media/abso/project/database/monitor_app/signal_control.json`
- `/media/abso/project/database/monitor_app/system_health.json`
- `/media/abso/project/database/monitor_app/traffic_violations.json`
- `/media/abso/project/database/monitor_app/priority_vehicles.json`
- `/media/abso/project/database/monitor_app/monitor_app_db_sync_ws/src/monitor_app_db_sync/README.md`
- `/media/abso/project/database/monitor_app/monitor_app_db_sync_ws/src/monitor_app_db_sync/monitor_app_db_sync/common.py`
- `/media/abso/project/database/monitor_app/monitor_app_db_sync_ws/src/monitor_app_db_sync/monitor_app_db_sync/rpi_db_publisher.py`
- `/media/abso/project/database/monitor_app/monitor_app_db_sync_ws/src/monitor_app_db_sync/monitor_app_db_sync/rpi_db_subscriber.py`
- `/media/abso/project/database/monitor_app/monitor_app_db_sync_ws/src/monitor_app_db_sync/monitor_app_db_sync/laptop_db_publisher.py`
- `/media/abso/project/database/monitor_app/monitor_app_db_sync_ws/src/monitor_app_db_sync/monitor_app_db_sync/laptop_db_subscriber.py`
- `/media/abso/project/database/monitor_app/monitor_app_db_sync_ws/src/monitor_app_db_sync/launch/*.launch.py`
- `/media/abso/yocto/traffic_robot/traffic_robot_app/source/README.md`
- `/media/abso/yocto/traffic_robot/traffic_robot_app/source/DATABASE_SETUP.md`
- `/media/abso/yocto/traffic_robot/traffic_robot_app/source/rosstreammanager.cpp`
- `/media/abso/yocto/traffic_robot/traffic_robot_app/source/rosstreammanager.h`
- `/media/abso/yocto/traffic_robot/traffic_robot_app/PROJECT_REPORT.md`
- `/media/abso/yocto/traffic_robot/ros2_autonoums/PROJECT_REPORT.md`
- `/media/abso/yocto/traffic_robot/ros2_autonoums/NODE_REFERENCE.md`
- `/media/abso/yocto/traffic_robot/traffic_ai_model/PROJECT_REPORT.md`
- `/media/abso/yocto/traffic_robot/traffic_ai_model/source/finish.py`
