# ROS 2 Autonomous Traffic Robot Documentation

This folder contains project documentation for the ROS 2 robot workspace located at:

`/media/abso/project/workspace/control/ros2/camera-ros/urdf_practise/ros2_ws_urdf`

The project combines:

- camera publishing with OpenCV
- vision-based Abso recognition
- follow-me behavior
- manual motor control over PWM
- CamJam robot control
- RViz and `ros2_control` simulation for the differential drive model

## Files In This Folder

- `PROJECT_REPORT.md`
  Full project report with architecture, package roles, behavior, and deployment notes.

- `NODE_REFERENCE.md`
  Node-by-node reference for all important ROS 2 executables, topics, and responsibilities.

- `SIMULATION_RVIZ_GUIDE.md`
  Guide for launching the URDF model, controllers, and RViz simulation environment.

- `TASKS.md`
  Development roadmap and task list for hardware, vision, simulation, and testing work.

## Main Package Groups

- `ros2_opencv`
  Camera publisher and camera subscriber nodes.

- `vision_ai`
  Face recognition, direction detection, Abso recognition, and YOLO perception utilities.

- `camjam_control`
  CamJam motor movement node, Abso follower, and autonomous behavior logic.

- `camjam_sensors`
  Line sensor and ultrasonic distance sensor publishers.

- `motor_control`
  PWM driver, obstacle detector, manual control, and motor command logic for Raspberry Pi 5.

- `my_robot_description`
  URDF/Xacro model and RViz configuration for the simulated robot.

- `my_robot_bringup`
  Launch files for `ros2_control`, RViz, and manual keyboard simulation control.

## Important Launch Workflows

### 1. Real Robot Follow-Me With Local Camera

```bash
ros2 launch camjam_control abso_follow.launch.py
```

### 2. Real Robot Follow-Me With Laptop Camera Shared To Pi

On the laptop:

```bash
ros2 launch ros2_opencv laptop_camera.launch.py
```

On the Raspberry Pi:

```bash
ros2 launch camjam_control abso_follow_laptop_camera.launch.py
```

### 3. Manual CamJam Motor Driving

```bash
ros2 run camjam_control move
ros2 run teleop_twist_keyboard teleop_twist_keyboard --ros-args -p stamped:=true
```

### 4. RViz / URDF Simulation

```bash
ros2 launch my_robot_bringup complete_system.launch.py
```

## Project Goal

The current goal of this project is to create a robot that can:

- see a human target through camera vision
- identify Abso specifically
- decide whether the target is left, center, or right
- steer the robot to keep the target centered
- move toward the target when centered
- support real hardware control and simulation workflows in the same workspace
