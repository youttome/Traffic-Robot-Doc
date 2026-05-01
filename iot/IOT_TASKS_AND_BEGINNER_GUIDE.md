# IoT Tasks And Beginner Guide

## Goal

This file is a practical guide for anyone reading the IoT side of the project for the first time.

It explains:

- what the IoT system is
- how the network connection works
- what each machine does
- what tasks must be completed
- what to test first

Project area:

- `/media/abso/yocto/traffic_robot/iot`

Related report:

- `/media/abso/yocto/traffic_robot/iot/IOT_RPI4_RPI5_SERVER_ROS_REPORT.md`

---

## 1. Simple System Overview

This project connects three main machines:

1. Raspberry Pi 5
   The robot control side

2. Raspberry Pi 4
   The traffic AI and computer vision side

3. Server / laptop / monitor host
   The operator and monitoring side

The machines communicate using:

- ROS 2 over the local network
- a shared JSON database synchronized by ROS 2
- camera topics for live video
- AI messages and control data for robot and traffic management

---

## 2. What IoT Means Here

In this project, IoT means:

- cameras, robot, and AI are running on separate devices
- devices exchange live data over the network
- the monitor application on the server shows the system state
- the operator can control the system remotely

So this is not only one local app.

It is a distributed ROS 2 system across multiple devices.

---

## 3. Network Idea In Simple Words

The network flow is:

- RPi5 sends robot data and may send robot camera
- RPi4 sends AI-related camera and analysis results
- server receives the data and shows it in the monitor app
- server can send control changes back to the Raspberry Pi side

This happens through ROS 2 DDS on the same subnet.

Important network settings already used in the database sync project:

- `ROS_DOMAIN_ID=42`
- `ROS_LOCALHOST_ONLY=0`
- `ROS_AUTOMATIC_DISCOVERY_RANGE=SUBNET`

Meaning:

- all machines must use the same ROS domain ID
- machines must not be limited to localhost only
- machines should be on the same local network

---

## 4. First-Time Reader Architecture

If you are reading this project for the first time, think of it as four layers.

### Layer 1: Robot Layer

Runs mainly on Raspberry Pi 5.

Responsibilities:

- move the robot
- receive teleoperation commands
- use vision results for robot motion
- publish robot camera or telemetry

### Layer 2: Traffic AI Layer

Runs mainly on Raspberry Pi 4.

Responsibilities:

- read two camera streams
- detect vehicles and emergency vehicles
- detect violations
- generate emergency road-open request

### Layer 3: Shared Data Layer

Runs between Pi and server through ROS 2 sync.

Responsibilities:

- synchronize JSON files
- keep monitor database updated
- allow server and Pi to share state

### Layer 4: Monitor Layer

Runs on the server / laptop.

Responsibilities:

- show live camera streams
- show traffic data and robot telemetry
- show AI summary text
- allow operator control through the app

---

## 5. Current Important Paths

### Monitor database

- `/media/abso/project/database/monitor_app`

### Database sync workspace

- `/media/abso/project/database/monitor_app/monitor_app_db_sync_ws`

### IoT reports

- `/media/abso/yocto/traffic_robot/iot`

### Traffic monitor app

- `/media/abso/yocto/traffic_robot/traffic_robot_app`

### Traffic AI model

- `/media/abso/yocto/traffic_robot/traffic_ai_model`

### ROS robot project documentation

- `/media/abso/yocto/traffic_robot/ros2_autonoums`

---

## 6. Main Data That Moves Over The Network

There are three kinds of data in this IoT system.

### 6.1 JSON Database State

Files:

- `traffic_violations.json`
- `priority_vehicles.json`
- `signal_control.json`
- `system_health.json`
- `monitor_ui.json`
- `robot_telemetry.json`

These files are synchronized between Raspberry Pi and server.

### 6.2 Live Camera Streams

Main expected ROS topics:

- `/cam_robot`
- `/cam_A`
- `/cma_B`

Optional compressed variants:

- `/cam_robot/compressed`
- `/cam_A/compressed`
- `/cma_B/compressed`

### 6.3 AI And Control Messages

Examples:

- `/street_ai_monitor`
- `/cmd_vel`
- `/manual_control/cmd_vel`
- emergency road-open request file from AI:
  - `exports/emergency_request.txt`

---

## 7. What Is Already Working

From the current reviewed code and reports, these parts already exist:

- ROS 2 database sync between Pi and server
- monitor app reads and writes the JSON database
- monitor app subscribes to ROS camera topics
- monitor app subscribes to AI summary topic
- robot manual control path exists
- robot AI follow-me path exists
- traffic AI model exists for two cameras
- traffic AI model writes emergency request output

---

## 8. What Still Needs Work

These are the main missing or incomplete links:

- standardize camera topic naming across the whole project
- create or verify the publisher for `/street_ai_monitor`
- connect traffic AI outputs into the shared monitor database
- decide how RPi4 AI affects robot movement, if required
- connect AI decisions to robot motion topics if that is part of the final design

---

## 9. Tasks To Complete The IoT System

This section is the action list.

---

## Task 1: Make the network environment consistent on all machines

Machines:

- RPi4
- RPi5
- server

Must do:

- connect all devices to the same LAN or hotspot
- make sure all devices can ping each other
- use the same `ROS_DOMAIN_ID`
- set `ROS_LOCALHOST_ONLY=0`
- confirm subnet discovery works

Recommended checks:

```bash
ping <other-machine-ip>
printenv ROS_DOMAIN_ID
printenv ROS_LOCALHOST_ONLY
```

Why:

- without network visibility, no ROS topic or sync will work

---

## Task 2: Run the database sync between Raspberry Pi and server

Pi side:

- run `rpi_db_bidirectional.launch.py`

Server side:

- run `laptop_db_bidirectional.launch.py`

Why:

- this is the shared state channel for the monitor app

Must verify:

- file edits on Pi appear on server
- file edits on server appear on Pi
- no infinite sync loop happens

First files to test:

- `robot_telemetry.json`
- `signal_control.json`

---

## Task 3: Verify the monitor app database reload

Machine:

- server

Must do:

- run the QML monitor app
- edit `robot_telemetry.json`
- edit `signal_control.json`
- confirm the UI updates automatically

Why:

- this proves the app and database layer are working correctly

---

## Task 4: Standardize camera topic names

Current problem:

- one part of the project uses `/camera/image_raw`
- the monitor app expects `/cam_robot`, `/cam_A`, `/cma_B`

Must decide:

- use remapping
- or rename publishers
- or add bridge/republish nodes

Recommended final topic naming:

- robot camera: `/cam_robot`
- street A camera: `/cam_A`
- street B camera: `/cma_B` or rename to `/cam_B`

Why:

- without matching topic names, the monitor app will show waiting placeholders

---

## Task 5: Connect live camera topics to the server app

Must do:

- start camera publishers on the source devices
- confirm the server receives the streams
- confirm the app camera cards become live

Must test:

- `/cam_robot`
- `/cam_A`
- `/cma_B`

Why:

- this is the main live IoT visualization path

---

## Task 6: Add or verify the AI summary publisher

Expected topic:

- `/street_ai_monitor`

Current finding:

- the monitor app subscribes to it
- reviewed code does not clearly show the active publisher

Must do:

- create a ROS 2 publisher for AI summary text
- or find and document the existing publisher if it already exists elsewhere

Output example:

- current emergency state
- current road recommendation
- AI incident summary
- latest violation summary

Why:

- this is needed for the AI panel in the monitor app

---

## Task 7: Bridge the traffic AI model to the monitor database

Machine:

- RPi4 or server bridge node

Must connect AI output into:

- `traffic_violations.json`
- `priority_vehicles.json`
- possibly `signal_control.json`

Why:

- today the AI model produces emergency request and logs
- the monitor app needs JSON state for direct display and operator interaction

Recommended approach:

- create a ROS or Python bridge node
- read AI outputs
- transform them into the database JSON schema
- write them safely into the monitor database

---

## Task 8: Clarify control authority

You must decide who controls what.

Question 1:

- does RPi4 AI control only traffic lights
- or also the robot movement

Question 2:

- does the server app only monitor
- or also send final operator commands

Why:

- without clear control ownership, the project may have conflicting commands

Recommended model:

- RPi5 controls robot motion execution
- RPi4 provides AI perception and traffic decisions
- server provides operator supervision and overrides

---

## Task 9: Connect AI or operator commands to robot motion if needed

If the final project requires AI-driven remote motion:

- create a bridge to `/cmd_vel`
- or create a bridge to `/manual_control/cmd_vel`

Possible sources:

- operator action from app
- AI output from RPi4
- safety logic from telemetry or emergency status

Why:

- this is the missing path if the final design wants traffic AI to move the robot directly

---

## Task 10: Validate the full end-to-end IoT workflow

Final test:

1. start ROS network on all machines
2. start database sync
3. start server monitor app
4. start robot-side ROS nodes
5. start AI-side traffic model
6. confirm cameras appear in app
7. confirm JSON data updates in app
8. confirm operator changes sync back
9. confirm emergency or AI result reaches the control side

---

## 10. Beginner-Friendly Network Checklist

If you are new to IoT and ROS, use this checklist first.

### Basic network

- all devices connected to the same router or hotspot
- each device has an IP address
- each device can ping the others

### ROS environment

- same ROS 2 version on all machines
- same `ROS_DOMAIN_ID`
- `ROS_LOCALHOST_ONLY=0`

### Quick ROS checks

On one machine:

```bash
ros2 topic list
```

On another machine:

```bash
ros2 topic echo /monitor_app_db_sync/update
```

If topics do not appear:

- check firewall
- check IP connectivity
- check ROS domain ID
- check that both nodes are actually running

---

## 11. Suggested Network Topology

Simple recommended topology:

```text
                 +----------------------+
                 |  Server / Laptop     |
                 |  QML Monitor App     |
                 |  DB Sync Subscriber  |
                 |  DB Sync Publisher   |
                 +----------+-----------+
                            |
                     Local LAN / Wi-Fi
                            |
          +-----------------+-----------------+
          |                                   |
 +--------+---------+               +---------+--------+
 | Raspberry Pi 5   |               | Raspberry Pi 4   |
 | Robot Control    |               | Traffic AI       |
 | ROS Motion       |               | 2-Camera Vision  |
 | Camera / DB Sync |               | AI Bridge Future |
 +------------------+               +------------------+
```

---

## 12. Recommended Reading Order For New Team Members

If someone is reading this project for the first time, read in this order:

1. this file
2. `IOT_RPI4_RPI5_SERVER_ROS_REPORT.md`
3. monitor database files under `/media/abso/project/database/monitor_app`
4. `monitor_app_db_sync` README and launch files
5. `traffic_robot_app` README and `DATABASE_SETUP.md`
6. `ros2_autonoums` report and node reference
7. `traffic_ai_model` report

This order helps the reader understand:

- the system idea first
- then the shared data
- then the app
- then robot and AI parts

---

## 13. Suggested First Demo Scenario

This is the easiest first demo for a new reader.

### Demo 1: Database Sync Demo

1. run database sync on Pi and server
2. open monitor app on server
3. edit `robot_telemetry.json` on Pi
4. confirm the app map updates on server

### Demo 2: Camera Demo

1. publish one camera topic
2. confirm one camera card becomes live in the app

### Demo 3: Manual Robot Control Demo

1. run manual control stack
2. send teleop commands
3. confirm robot movement

### Demo 4: AI Traffic Demo

1. run the traffic AI model on two streams
2. generate emergency request
3. confirm output file changes
4. later connect that result into the app and signal controller

---

## 14. Final Notes For First-Time IoT Readers

The most important thing to understand is:

- the JSON database is the shared operator state
- ROS topics are the live transport
- the server app is the main human interface
- RPi5 is the robot-action side
- RPi4 is the traffic-AI side

The project already has a strong base.

The main remaining work is not the basic network idea.
The main remaining work is the final bridge logic between:

- AI outputs
- live ROS topics
- monitor database
- robot or signal control decisions

---

## 15. Short Task Summary

1. Fix network setup on all machines.
2. Run and verify ROS database sync.
3. Verify monitor app live JSON reload.
4. Standardize camera topic names.
5. Connect live camera streams to the server app.
6. Add or verify `/street_ai_monitor` publisher.
7. Bridge RPi4 AI outputs into monitor database files.
8. Decide control ownership between RPi4, RPi5, and server.
9. Add robot motion bridge if AI must control movement remotely.
10. Test the full multi-machine workflow end to end.
