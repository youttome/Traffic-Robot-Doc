# Project Report: ROS 2 Autonomous Traffic Robot

## 1. Introduction

This ROS 2 workspace is a mixed hardware-and-simulation robot project. It combines Raspberry Pi motor control, camera perception, target-following behavior, and a separate RViz-based simulation stack using URDF and `ros2_control`.

The workspace supports two main robot operation styles:

1. Real hardware control on Raspberry Pi 5 using GPIO/PWM and camera perception.
2. Simulated differential-drive robot control in RViz using a URDF model and `diff_drive_controller`.

The most recent functional milestone is a follow-me behavior where the robot uses:

- `vision_ai` to recognize Abso from camera frames
- `camjam_control` to convert vision outputs into movement commands
- `camjam_movement` to drive CamJam motor pins through Pi 5 safe `gpiod`

## 2. System Objectives

The project currently addresses these objectives:

- publish live camera frames over ROS 2
- recognize a target person named Abso
- classify target position as `left`, `center`, or `right`
- steer the robot left or right to re-center the target
- move forward when the target is centered
- support manual teleoperation
- support direct PWM motor testing
- provide a URDF and RViz simulation path for controller validation

## 3. Package Overview

### 3.1 `ros2_opencv`

Purpose:

- publish camera frames as `sensor_msgs/Image`
- optionally run from the laptop webcam for network-shared perception

Key nodes:

- `camera_publisher_cv`
- `camera_subscriber_cv`

Important launch:

- `laptop_camera.launch.py`

### 3.2 `vision_ai`

Purpose:

- perform face detection and Abso recognition
- publish identity, detection state, position, and emergency state
- support optional YOLO obstacle perception

Key nodes:

- `abso_face_camera_recorder`
- `face_direction_detector`
- `yolo_obstacle_detector`

Important launch:

- `abso_camera.launch.py`
- `vision_perception.launch.py`

### 3.3 `camjam_control`

Purpose:

- drive the physical CamJam robot motors
- follow Abso using camera results
- translate follow logic into `/cmd_vel`

Key nodes:

- `move` from `camjam_movement.py`
- `abso_follower`
- `control` from `camjam_controller.py`

Important launches:

- `camjam_control.launch.py`
- `abso_follow.launch.py`
- `abso_follow_laptop_camera.launch.py`

### 3.4 `camjam_sensors`

Purpose:

- publish line sensor and distance sensor data for CamJam autonomous behavior

Key nodes:

- `line_sensor_publisher`
- `hc_sr04_publisher`

### 3.5 `motor_control`

Purpose:

- provide a second hardware-control path focused on Raspberry Pi 5 PWM and motor command messaging
- support manual motor control and vision obstacle avoidance

Key nodes:

- `manual_control`
- `motor_controller`
- `obstacle_detector`
- `pwm_driver`
- `pwm_sysfs_test`

Important launches:

- `manual_control.launch.py`
- `motor_control.launch.py`

### 3.6 `my_robot_description`

Purpose:

- define the simulated robot model in URDF/Xacro
- define the `ros2_control` compatible differential drive robot

### 3.7 `my_robot_bringup`

Purpose:

- start the simulation and RViz environment
- spawn the controllers
- support manual teleop into `diff_drive_controller`

Important launches:

- `complete_system.launch.py`
- `manual_control.launch.py`
- `robot_control.launch.py`

## 4. Real Hardware Architecture

### 4.1 Camera To Follow Controller Flow

For follow-me behavior, the real robot path is:

1. `ros2_opencv/camera_publisher_cv` publishes `/camera/image_raw`
2. `vision_ai/abso_face_camera_recorder` detects Abso and publishes:
   - `/vision/abso_detected`
   - `/vision/abso_name`
   - `/vision/abso_position`
   - `/vision/abso_emergency`
3. `camjam_control/abso_follower` converts those topics into `/cmd_vel`
4. `camjam_control/camjam_movement` receives `/cmd_vel` and drives the motor pins

### 4.2 Laptop Camera Shared To Pi

For networked operation:

1. laptop publishes `/camera/image_raw`
2. Pi runs the vision and follower stack without starting a Pi-local camera
3. DDS transports the camera topic from laptop to Pi
4. Pi uses those frames to steer the robot

This allows the robot to use a better or more convenient laptop webcam while the movement computation still executes on the Pi.

### 4.3 Pi 5 GPIO Strategy

An important implementation detail is Raspberry Pi 5 compatibility.

Older `RPi.GPIO` based workflows caused failures such as:

- `Cannot determine SOC peripheral base address`
- sysfs GPIO export problems

The project now uses:

- `libgpiod` / `gpiod` for GPIO line ownership
- `gpioset` cleanup on startup where needed
- sysfs PWM only where appropriate

This is a safer direction for Pi 5 hardware support.

## 5. Autonomous Follow-Me Logic

The follow logic is intentionally simple and explainable.

If Abso is detected:

- position `left` -> turn left
- position `right` -> turn right
- position `center` -> move forward

If Abso is not detected:

- stop

If Abso emergency state is active:

- stop

This behavior is implemented in:

- `camjam_control/abso_follow_logic.py`
- `camjam_control/abso_follower.py`

The control policy is easy to test and easy to tune.

## 6. Manual Control Paths

The workspace contains several manual control mechanisms:

### 6.1 CamJam Manual Control

```bash
ros2 run camjam_control move
ros2 run teleop_twist_keyboard teleop_twist_keyboard --ros-args -p stamped:=true
```

This path writes directly into `/cmd_vel`, and `camjam_movement` applies software PWM through `gpiod`.

### 6.2 Raspberry Pi 5 Manual PWM Control

```bash
ros2 launch motor_control manual_control.launch.py
ros2 run teleop_twist_keyboard teleop_twist_keyboard --ros-args -r /cmd_vel:=/manual_control/cmd_vel -p stamped:=true
```

This path converts teleop commands into motor command arrays and sends them to `pwm_driver`.

### 6.3 RViz Manual Control

```bash
ros2 launch my_robot_bringup manual_control.launch.py
```

This starts the simulated robot and a teleop node for the `diff_drive_controller`.

## 7. Simulation And RViz

The workspace also supports a simulation-oriented development path.

Simulation features:

- URDF/Xacro robot model
- `robot_state_publisher`
- `ros2_control_node`
- `joint_state_broadcaster`
- `diff_drive_controller`
- RViz visualization

This is useful for:

- testing robot structure and frames
- checking controller topic names
- validating teleop integration
- demonstrating a robot workflow without hardware

The simulation stack is separate from the CamJam real motor stack, but both represent differential-drive behavior. This makes RViz useful as a system-design and controller-validation environment even when the actual hardware node implementation is different.

## 8. Main Topics

### Camera And Vision Topics

- `/camera/image_raw`
- `/vision/abso_name`
- `/vision/abso_detected`
- `/vision/abso_position`
- `/vision/abso_emergency`
- `/vision/abso_distance_cm`
- `/vision/face_direction`
- `/vision/face_box`
- `/vision/obstacle_summary`
- `/vision/obstacle_boxes`

### Motion Topics

- `/cmd_vel`
- `/manual_control/cmd_vel`
- `/motor_commands`
- `/obstacle_detection`

### Simulation Topics

- `/diff_drive_controller/cmd_vel`
- `/joint_states`
- `/tf`
- `/tf_static`
- `/odom`

## 9. Strengths Of The Current Project

- multiple robot control paths in one workspace
- real camera integration already working
- laptop-camera-to-Pi workflow supported
- Pi 5 GPIO compatibility improved with `gpiod`
- clear follow-me behavior built on ROS topics
- RViz and URDF simulation path available
- modular packages make future refactoring easier

## 10. Current Risks And Gaps

- the project mixes multiple robot paradigms in one workspace, which can confuse deployment unless launches are well documented
- some older README files still describe pre-Pi-5 behavior
- some hardware packages still contain legacy `RPi.GPIO` code
- there is not yet a single integrated “production” launch for all sensors, robot control, and safety checks
- the follow behavior is discrete rather than proportional, so movement may be abrupt

## 11. Recommendations

Short-term:

- standardize hardware GPIO access around `gpiod`
- add clearer startup/shutdown scripts for Pi deployment
- document exact hardware wiring for each robot variant
- add one-stop launch files for laptop-camera and Pi-camera follow workflows

Medium-term:

- add proportional steering based on bounding box center error
- add distance-based forward speed control
- add watchdog and emergency stop topics
- separate experimental packages from production packages

Long-term:

- unify simulation and hardware interfaces more tightly
- add recorded bag-based replay testing
- add formal ROS 2 integration tests
- add navigation and mapping extensions

## 12. Conclusion

This workspace has evolved into a practical ROS 2 robotics platform that supports:

- camera streaming
- target recognition
- follow-me behavior
- manual motor control
- simulation in RViz

It already demonstrates a meaningful full-stack robotics pipeline:

perception -> decision -> motion

The project is suitable as a strong practical robotics report and as a base for continued autonomous mobile robot development.
