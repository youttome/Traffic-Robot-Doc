# Node Reference

This reference lists the important nodes in the project, grouped by package.

## 1. `ros2_opencv`

### `camera_publisher_cv`

Role:

- opens a camera device with OpenCV
- publishes frames to `/camera/image_raw`

Important parameters:

- `camera_device`
- `camera_topic`
- `frame_id`
- `publish_period`
- `frame_width`
- `frame_height`

### `camera_subscriber_cv`

Role:

- subscribes to `/camera/image_raw`
- displays frames with OpenCV for debug viewing

## 2. `vision_ai`

### `abso_face_camera_recorder`

Role:

- receives `/camera/image_raw`
- detects and recognizes Abso
- estimates left/center/right target position
- optionally records annotated images

Published topics:

- `/vision/abso_name` as `std_msgs/String`
- `/vision/abso_detected` as `std_msgs/Bool`
- `/vision/abso_position` as `std_msgs/String`
- `/vision/abso_emergency` as `std_msgs/Bool`
- `/vision/abso_distance_cm` as `std_msgs/String`

Subscribed topics:

- `/camera/image_raw`
- `distance`

### `face_direction_detector`

Role:

- generic face detector
- publishes face position direction and face box

Published topics:

- `/vision/face_direction`
- `/vision/face_box`

### `yolo_obstacle_detector`

Role:

- optional YOLO detector for person/car obstacles

Published topics:

- `/vision/avoid_obstacle`
- `/vision/obstacle_summary`
- `/vision/obstacle_boxes`

## 3. `camjam_control`

### `camjam_movement` (`ros2 run camjam_control move`)

Role:

- receives stamped velocity commands
- drives the CamJam motor pins with Pi 5 safe `gpiod`
- releases old `gpioset` holders on startup

Subscribed topics:

- `/cmd_vel` as `geometry_msgs/TwistStamped`

Important parameters:

- `motor_a_forward_pin`
- `motor_a_reverse_pin`
- `motor_b_forward_pin`
- `motor_b_reverse_pin`
- `gpiochip_path`
- `pwm_frequency`
- `max_duty_cycle`
- `command_timeout`

### `abso_follower`

Role:

- converts vision topics into robot follow commands
- turns left when Abso is left
- turns right when Abso is right
- moves forward when Abso is centered
- stops when target is missing or emergency is active

Published topics:

- `/cmd_vel` as `geometry_msgs/TwistStamped`

Subscribed topics:

- `/vision/abso_detected`
- `/vision/abso_name`
- `/vision/abso_position`
- `/vision/abso_emergency`

### `camjam_controller` (`ros2 run camjam_control control`)

Role:

- line-follow and obstacle-avoid logic for the CamJam platform

Published topics:

- `cmd_vel` as `geometry_msgs/Twist`

Subscribed topics:

- `line_detected`
- `distance`

## 4. `camjam_sensors`

### `line_sensor_publisher`

Role:

- publishes binary line detection state from the line sensor

Published topics:

- `line_detected` as `std_msgs/Bool`

### `hc_sr04_publisher`

Role:

- publishes measured ultrasonic distance

Published topics:

- `distance` as `sensor_msgs/Range`

## 5. `motor_control`

### `manual_control`

Role:

- accepts teleop-style `TwistStamped` on `/manual_control/cmd_vel`
- converts them into left/right motor command arrays

Published topics:

- `/motor_commands`

Subscribed topics:

- `/manual_control/cmd_vel`

### `motor_controller`

Role:

- obstacle-avoidance decision node
- converts obstacle detections into motor commands

Published topics:

- `/motor_commands`

Subscribed topics:

- `/obstacle_detection`

### `obstacle_detector`

Role:

- detects obstacles from camera frames with OpenCV image processing

Published topics:

- `/obstacle_detection`

Subscribed topics:

- `/camera/image_raw`

### `pwm_driver`

Role:

- writes PWM and direction outputs for Raspberry Pi 5
- uses sysfs PWM and `gpiod`

Subscribed topics:

- `/motor_commands`

### `pwm_sysfs_test`

Role:

- direct hardware utility to test `pwmchip0` channels

## 6. `my_robot_bringup` Simulation Nodes

### `robot_state_publisher`

Role:

- publishes TF from robot URDF

### `controller_manager / ros2_control_node`

Role:

- hosts the simulated robot hardware interface and controllers

### `joint_state_broadcaster`

Role:

- publishes simulated joint state interfaces

### `diff_drive_controller`

Role:

- receives velocity commands and simulates differential-drive motion

### `rviz2`

Role:

- visualizes robot model, TF, and controller outputs

## 7. Main Launch Files

### Real Hardware

- `camjam_control/launch/abso_follow.launch.py`
- `camjam_control/launch/abso_follow_laptop_camera.launch.py`
- `motor_control/launch/manual_control.launch.py`
- `motor_control/launch/motor_control.launch.py`

### Vision

- `vision_ai/launch/abso_camera.launch.py`
- `vision_ai/launch/vision_perception.launch.py`
- `ros2_opencv/launch/laptop_camera.launch.py`

### Simulation

- `my_robot_bringup/launch/complete_system.launch.py`
- `my_robot_bringup/launch/manual_control.launch.py`
- `my_robot_bringup/launch/robot_control.launch.py`
