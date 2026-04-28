# Simulation And RViz Guide

## Goal

This guide explains the simulation part of the project. The simulation path is useful even though the real robot uses separate CamJam and Raspberry Pi 5 motor-control nodes.

The RViz path helps validate:

- robot geometry
- TF tree
- controller naming
- differential-drive interfaces
- keyboard teleoperation behavior

## Packages Used

- `my_robot_description`
- `my_robot_bringup`

## Core Files

- `src/my_robot_description/urdf/my_robot.urdf.xacro`
- `src/my_robot_description/urdf/mobile_base.xacro`
- `src/my_robot_description/urdf/mobile_base.ros2_control.xacro`
- `src/my_robot_description/rviz/urdf_config.rviz`
- `src/my_robot_bringup/config/my_robot_controller.yaml`
- `src/my_robot_bringup/launch/complete_system.launch.py`

## Simulation Architecture

The simulation launch starts:

1. `robot_state_publisher`
2. `controller_manager` with `ros2_control_node`
3. `joint_state_broadcaster`
4. `diff_drive_controller`
5. `rviz2`

The robot model is loaded from Xacro and fed into both:

- `robot_state_publisher`
- `controller_manager`

This means the simulation has both:

- TF visualization
- controller-based wheel motion

## Main Simulation Launch

```bash
cd /media/abso/project/workspace/control/ros2/camera-ros/urdf_practise/ros2_ws_urdf
source /opt/ros/jazzy/setup.bash
source install/local_setup.bash
ros2 launch my_robot_bringup complete_system.launch.py
```

Useful arguments:

```bash
ros2 launch my_robot_bringup complete_system.launch.py use_rviz:=false
ros2 launch my_robot_bringup complete_system.launch.py enable_movement:=true
ros2 launch my_robot_bringup complete_system.launch.py use_sim_time:=false
```

## Manual Teleop In RViz

```bash
ros2 launch my_robot_bringup manual_control.launch.py
```

This launch:

- starts the base simulation
- starts `turtlesim turtle_teleop_key`
- bridges teleop commands into the diff-drive command topic

This is the easiest way to verify:

- the controller accepts commands
- the robot moves in RViz
- the TF tree updates correctly

## Important Simulation Topics

- `/diff_drive_controller/cmd_vel`
- `/joint_states`
- `/tf`
- `/tf_static`
- `/diff_drive_controller/odom`

## Why RViz Matters In This Project

Even though the hardware robot uses direct GPIO and PWM control, RViz is still important because it gives a safe software-only environment to:

- test command directions
- test differential-drive assumptions
- validate topic names
- confirm robot frame naming
- demonstrate the robot system without hardware

It also helps compare the hardware control stack with the simulation control stack.

## Suggested Simulation Use Cases

### 1. Controller Validation

Use simulation first to verify:

- left turn means positive angular velocity
- right turn means negative angular velocity
- forward means positive linear velocity

### 2. URDF Debugging

Use RViz to check:

- wheel placement
- base frame alignment
- TF tree correctness

### 3. Launch Debugging

Use the simulation stack to test:

- `ros2_control` startup
- teleop bridges
- controller availability

### 4. Documentation And Demonstration

RViz is useful for:

- reports
- screenshots
- classroom demos
- design reviews

## Known Difference Between Simulation And Hardware

The RViz robot uses:

- `diff_drive_controller`
- `ros2_control`
- URDF-defined wheel geometry

The CamJam hardware robot uses:

- `camjam_movement`
- software PWM
- `gpiod`

So the simulation is not a perfect electrical model of the hardware robot. It is a control-and-geometry model. That is still highly valuable for design and software validation.

## Recommended RViz Tasks

- verify the robot model renders correctly
- verify `joint_state_broadcaster` starts
- verify `diff_drive_controller` starts
- publish commands and confirm odometry changes
- compare turning direction with hardware behavior
- capture screenshots for project reporting
