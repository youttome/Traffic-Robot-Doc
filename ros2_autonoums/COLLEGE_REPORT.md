# College Report: ROS 2 Autonomous Robot Directory

## 1. Introduction

This directory documents the ROS 2 autonomous robot part of the project.

It is the robotics core that explains how the robot:

- receives camera input
- recognizes a target
- decides how to move
- supports manual control
- supports simulation with RViz and URDF

## 2. Directory Purpose

The `ros2_autonoums` directory acts as the robot behavior knowledge base.

It documents:

- package roles
- nodes
- topics
- launch workflows
- simulation support

## 3. Main Files

- `README.md`
- `PROJECT_REPORT.md`
- `NODE_REFERENCE.md`
- `SIMULATION_RVIZ_GUIDE.md`
- `TASKS.md`

## 4. Main Technical Focus

This directory describes a robot that combines:

- ROS 2 camera publishing
- computer vision target detection
- autonomous follow-me behavior
- manual motor control
- simulation and validation support

## 5. Major Package Groups

- `ros2_opencv`
- `vision_ai`
- `camjam_control`
- `camjam_sensors`
- `motor_control`
- `my_robot_description`
- `my_robot_bringup`

## 6. Academic Importance

This folder is central for a college project because it demonstrates:

- robot perception pipeline design
- ROS topic-based control
- separation between sensing and actuation
- support for both hardware and simulation

## 7. Strong Engineering Points

- follow-me logic is simple and explainable
- sensor and control paths are separated cleanly
- manual control exists for testing and safety
- simulation exists for controller validation
- Raspberry Pi 5 GPIO migration to `gpiod` is documented

## 8. Real Hardware Role

On real hardware, this part of the project is responsible for:

- publishing or receiving camera frames
- running face or target detection
- producing `/cmd_vel`
- driving the robot motors

## 9. Simulation Role

In simulation, it supports:

- URDF-based robot modeling
- `ros2_control`
- `diff_drive_controller`
- RViz validation

This is valuable academically because it allows demonstration even when hardware is unavailable.

## 10. Skills A Student Can Learn Here

- ROS 2 publishers and subscribers
- launch file organization
- topic-driven robot control
- camera-to-control data flow
- motor control design choices
- hardware versus simulation comparison

## 11. Connection To The Full System

This directory provides the robot-side motion logic that connects to:

- the monitor app through ROS topics
- the IoT design through networked ROS communication
- the embedded deployment plan through Yocto

## 12. Conclusion

The `ros2_autonoums` folder is the robotics heart of the project.

For a college report, it proves that the team has built more than a UI or an AI script.

It shows a full ROS 2 robot control architecture with both practical and educational value.

## 13. Code Example And How To Use It

Example workflow command from the documented ROS stack:

```bash
ros2 run camjam_control move
ros2 run teleop_twist_keyboard teleop_twist_keyboard --ros-args -p stamped:=true
```

How to use it:

- the first command starts the robot motor node
- the second command sends manual motion commands from the keyboard

This is useful for:

- validating motor wiring
- validating the `/cmd_vel` path
- testing movement before autonomous behavior is used

## 14. Detailed Walkthrough

The robot-side ROS logic is easiest to understand as a perception-to-motion chain.

Documented chain:

1. camera publishes frames
2. vision node reads frames
3. follower node converts perception to command
4. movement node drives hardware

Important topics from the documentation:

- `/camera/image_raw`
- `/vision/abso_detected`
- `/vision/abso_position`
- `/vision/abso_emergency`
- `/cmd_vel`

This means the robot side is designed in a modular ROS style:

- sensing is separate from decision logic
- decision logic is separate from motor actuation

Why this is good:

- each node can be tested independently
- manual teleop can replace AI temporarily
- camera sources can be changed without rewriting the motor code
- simulation can validate the control logic before running on hardware
