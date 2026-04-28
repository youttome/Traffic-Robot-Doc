# Project Tasks And Roadmap

## Phase 1: Documentation Baseline

- [x] Create project overview
- [x] Create node reference
- [x] Create simulation and RViz guide
- [x] Create development task list
- [ ] Add wiring diagrams for each hardware path
- [ ] Add package dependency diagram

## Phase 2: Camera And Vision

- [x] Publish `/camera/image_raw` with `ros2_opencv`
- [x] Add laptop camera launch
- [x] Publish Abso recognition state
- [x] Publish Abso left/center/right position
- [ ] Add confidence filtering for noisy detections
- [ ] Add more robust target reacquisition behavior
- [ ] Save debug bags for vision replay

## Phase 3: Follow-Me Behavior

- [x] Create `abso_follower` node
- [x] Stop when target is not detected
- [x] Stop when emergency is active
- [x] Add integrated follow launch
- [x] Add laptop-camera follow launch
- [ ] Convert left/right/center behavior into proportional steering
- [ ] Add distance-aware forward speed scaling
- [ ] Add target-loss search behavior

## Phase 4: CamJam Hardware Control

- [x] Move CamJam motor node to Pi 5 safe `gpiod`
- [x] Release stale `gpioset` holders on startup
- [x] Support stamped teleop commands on `/cmd_vel`
- [x] Remove forced timeout for persistent driving
- [ ] Confirm final motor wiring for GPIO 20, 21, 22, 23
- [ ] Add a dedicated stop service or stop topic
- [ ] Add startup self-check for busy GPIO lines with friendlier errors

## Phase 5: Raspberry Pi 5 PWM Stack

- [x] Create `manual_control` node in `motor_control`
- [x] Support teleop through `/manual_control/cmd_vel`
- [x] Use Pi 5 safe direction control in `pwm_driver`
- [x] Validate `pwmchip0`, `pwm0`, and `pwm1`
- [ ] Standardize all legacy `RPi.GPIO` paths to `gpiod`
- [ ] Add per-wheel calibration values
- [ ] Add controlled stop ramp instead of instant stop

## Phase 6: Sensors

- [x] Implement line sensor publisher
- [x] Implement HC-SR04 distance publisher
- [ ] Validate sensor topics on Pi 5 with final wiring
- [ ] Add launch file combining CamJam sensors and follower
- [ ] Add unit-safe conversion notes for `Range` messages

## Phase 7: Simulation And RViz

- [x] Provide URDF/Xacro robot model
- [x] Launch `ros2_control` simulation
- [x] Launch RViz visualization
- [x] Add manual teleop simulation path
- [ ] Match simulated geometry more closely to hardware dimensions
- [ ] Add follow-controller simulation bridge for vision testing
- [ ] Add screenshot set for report and presentation use

## Phase 8: Integration

- [ ] Decide on primary robot stack:
  either `camjam_control` or `motor_control` as the production hardware path
- [ ] Standardize camera topic naming across all packages
- [ ] Standardize velocity topic types across all robot control nodes
- [ ] Add one deployment script for Pi startup
- [ ] Add one launch for laptop camera + Pi follower + movement

## Phase 9: Testing

- [x] Add pure logic tests for CamJam movement mixing
- [x] Add pure logic tests for Abso follow behavior
- [x] Add logic tests for motor manual control
- [ ] Add end-to-end ROS topic tests for follow mode
- [ ] Add bag replay tests for recorded camera frames
- [ ] Add Pi hardware checklist for each release

## Phase 10: Reporting And Delivery

- [x] Create written report set
- [ ] Capture final architecture diagram
- [ ] Record demo of follow-me robot
- [ ] Record demo of RViz simulation
- [ ] Write final setup instructions for another machine

## Recommended Immediate Next Tasks

1. Verify final GPIO wiring for `camjam_movement`.
2. Run the laptop-camera-to-Pi follow workflow end to end.
3. Tune `abso_follower` forward and turn speeds for smoother behavior.
4. Add a stop topic or stop service for safe operator intervention.
5. Decide whether the final robot platform should be documented primarily as `camjam_control` or `motor_control`.
