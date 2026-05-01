# Embedded System Book 1: Project Report and Main Design Explanation

## 1. Cover Page

- Title: Embedded System Graduation Project Report
- Source workspace: `/media/abso/project/workspace/embedded system`
- Report output path: `/media/abso/yocto/traffic_robot/EMBEDDED_SYSTEM_BOOK_1_PROJECT_REPORT.md`
- Main target MCU family: AVR ATmega32
- Main embedded toolchain style: Atmel Studio / AVR-GCC project structure
- Main project type: smart robot and traffic-control embedded subsystems

## 2. Introduction

This report explains the embedded-system workspace located at `/media/abso/project/workspace/embedded system`.

The workspace does not contain only one simple microcontroller program.

It contains two separate AVR embedded projects:

- `GccApplication48`
- `GccApplication51`

These two projects represent two different but related embedded roles inside a larger traffic-robot system.

The first project focuses on a traffic-control robotic arm or traffic-lane actuator system based on six servo motors, a PCA9685 PWM controller, LCD display, and UART command input.

The second project focuses on a mobile robot controller that supports:

- Bluetooth manual control
- autonomous obstacle avoidance
- encoder-based goal movement
- encoder-based turn execution
- ultrasonic sensing
- LCD status display

This makes the whole workspace valuable for a graduation project because it demonstrates more than one embedded function.

It demonstrates:

- traffic-side actuation
- robot-side motion control
- embedded communication
- sensor integration
- non-blocking state-machine design
- LCD-based debugging and user feedback

## 3. Why This Workspace Is Important

This workspace is important because it shows how embedded systems can be divided into specialized controllers instead of forcing every behavior into one monolithic firmware image.

The two main ideas are:

- a traffic mechanism controller
- a mobile robot motion controller

This separation is good engineering practice because each controller has a clear role.

The result is easier to:

- understand
- test
- explain
- debug
- extend later

For a graduation project, this also helps the student explain the complete system to supervisors in a structured way.

## 4. Directory Overview

The embedded workspace contains:

- [GccApplication48](/media/abso/project/workspace/embedded%20system/GccApplication48)
- [GccApplication51](/media/abso/project/workspace/embedded%20system/GccApplication51)

### 4.1 `GccApplication48`

This project contains:

- [main.c](/media/abso/project/workspace/embedded%20system/GccApplication48/GccApplication48/main.c)
- [main-9.c](/media/abso/project/workspace/embedded%20system/GccApplication48/GccApplication48/main-9.c)
- [pca9685.c](/media/abso/project/workspace/embedded%20system/GccApplication48/GccApplication48/pca9685.c)
- [pca9685.h](/media/abso/project/workspace/embedded%20system/GccApplication48/GccApplication48/pca9685.h)
- [lcd_i2c.c](/media/abso/project/workspace/embedded%20system/GccApplication48/GccApplication48/lcd_i2c.c)
- [lcd_i2c.h](/media/abso/project/workspace/embedded%20system/GccApplication48/GccApplication48/lcd_i2c.h)

The simple `main.c` is effectively a placeholder.

The real application logic is in `main-9.c`.

### 4.2 `GccApplication51`

This project contains:

- [main.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/main.c)
- [config.h](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/config.h)
- [timer.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/timer.c)
- [timer.h](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/timer.h)
- [encoder.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/encoder.c)
- [encoder.h](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/encoder.h)
- [motor.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/motor.c)
- [motor.h](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/motor.h)
- [ultrasonic.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/ultrasonic.c)
- [ultrasonic.h](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/ultrasonic.h)
- [bluetooth.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/bluetooth.c)
- [bluetooth.h](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/bluetooth.h)
- [nav.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/nav.c)
- [nav.h](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/nav.h)
- [display.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/display.c)
- [display.h](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/display.h)
- [lcd.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/lcd.c)
- [lcd.h](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/lcd.h)

This second project is a much more complete embedded firmware system.

## 5. Project 1: `GccApplication48` Summary

### 5.1 Main Idea

`GccApplication48` is a traffic robot arm controller.

It manages six servo motors.

It receives UART commands:

- `'0'`
- `'1'`
- `'2'`

These commands select:

- normal repeating traffic behavior
- emergency-right priority behavior
- emergency-left priority behavior

The firmware drives the servos through a PCA9685 16-channel PWM driver over I2C.

It also updates a 16x2 LCD through a PCF8574 I2C backpack.

### 5.2 Hardware Used

Based on the source code comments, this project uses:

- ATmega32 at 8 MHz
- PCA9685 PWM controller
- 16x2 LCD over PCF8574
- Bluetooth or UART serial input
- six servo outputs
- traffic-light outputs using GPIO on `PORTB`

### 5.3 Servo Mapping

The six servo channels are:

- CH0 = right shoulder A
- CH1 = right shoulder B
- CH2 = right elbow
- CH3 = left shoulder A
- CH4 = left shoulder B
- CH5 = left elbow

This means the project is modeling a two-sided traffic arm or lane-control mechanism where both sides can be raised or lowered in different patterns.

### 5.4 High-Level Behavior

The firmware defines three command classes:

- Normal mode
- Emergency right
- Emergency left

Normal mode is not just one static position.

It is split into:

- Normal Phase A
- Normal Phase B

This means the system alternates between two traffic states, each with its own servo posture and traffic-light output.

### 5.5 Why This Design Is Good

This is good because the project does not directly jump from command to final pose in one blocking delay-heavy sequence.

Instead, it uses:

- state machine steps
- timer-based waiting
- non-blocking execution

This is more professional embedded design than writing one long blocking procedure.

## 6. Project 1 Hardware and Interface Explanation

### 6.1 Microcontroller

The microcontroller is ATmega32 running at `8 MHz`.

This is a common AVR MCU for student embedded projects because it provides:

- UART
- hardware timers
- external interrupts
- enough GPIO
- TWI/I2C support

### 6.2 PCA9685

The PCA9685 is used because ATmega32 does not have enough high-quality independent servo PWM outputs for six channels plus other control functions.

The PCA9685 solves this by:

- generating many PWM channels
- operating through I2C
- reducing MCU timing burden

### 6.3 LCD Over I2C

The LCD uses a PCF8574 I/O expander.

This is efficient because it saves many MCU pins.

The LCD is updated to show servo angles continuously.

That is very useful during testing because the student can verify the current state without external debugging tools.

### 6.4 UART / Bluetooth

The code comments show UART is used for command input.

This likely allows:

- Bluetooth serial module integration
- direct UART terminal control

Commands are simple and compact, which is a strong choice for reliability and easy testing.

### 6.5 Traffic Light Outputs

The project also controls traffic lights through `PORTB` outputs:

- right red
- right green
- left red
- left green

This means the firmware controls both:

- physical arm or servo mechanism
- traffic light signaling logic

That makes it a more complete embedded traffic node.

## 7. Project 1 Main Logic Explanation

### 7.1 Global Timing

The project uses Timer1 in CTC mode to generate a `1 ms` system tick.

This tick increments `sys_ms`.

That time base is then used to implement:

- movement delay windows
- hold windows
- emergency hold duration

### 7.2 Command Reception

UART receive interrupt reads incoming commands.

When one of these commands arrives:

- `'0'`
- `'1'`
- `'2'`

the command is stored as pending and a preemption flag is set.

This is important because emergency commands can interrupt current behavior.

### 7.3 Preemption

The source code includes a `handle_preempt()` function.

This function:

- clears pending command state
- resets wait timing
- changes current priority
- sets the new state-machine entry step

This means emergency commands can interrupt normal operation immediately.

That is exactly what a real priority-traffic or ambulance system needs.

### 7.4 Normal State Flow

The normal flow alternates between:

- `S_C0A_*`
- `S_C0B_*`

These two sets of states represent two traffic phases.

Each phase:

- moves the required servos
- updates traffic lights
- waits the required hold time
- transitions to the next phase

### 7.5 Emergency Right

Emergency right uses the `S_C1_*` steps.

This sequence:

- prepares the left side down
- prepares the right side up
- activates the right-priority light state
- holds the emergency state
- finishes and returns to IDLE

### 7.6 Emergency Left

Emergency left uses the `S_C2_*` steps.

This is the mirrored behavior for the left side.

### 7.7 LCD Feedback

Every time a servo angle changes, the code updates the LCD.

This is a strong debugging idea because it gives real-time visibility into:

- servo channel state
- angle changes
- whether the system really accepted a command

## 8. Project 1 Strengths

The major strengths of `GccApplication48` are:

- clean state-machine structure
- interrupt-based command reception
- I2C peripheral reuse for both servo driver and LCD
- immediate preemption support
- LCD monitoring support
- separate helper modules for PCA9685 and LCD
- good embedded comments in `main-9.c`

## 9. Project 1 Weaknesses or Improvement Areas

The project is already good structurally, but some improvements are still possible:

- rename `main-9.c` to a clearer final production filename
- remove or archive the empty placeholder `main.c`
- document exact servo mechanical meaning in a wiring diagram
- add explicit command acknowledgment strings for all command types
- add fault handling if LCD initialization fails
- add watchdog or timeout recovery logic

## 10. Project 2: `GccApplication51` Summary

### 10.1 Main Idea

`GccApplication51` is the main mobile robot controller.

It is a more advanced firmware system than `GccApplication48`.

It supports three robot modes:

- Manual mode
- Auto mode
- Goal mode

### 10.2 Manual Mode

In manual mode, the robot receives Bluetooth commands and performs:

- forward
- backward
- pivot left
- pivot right
- strafe-left style arc
- strafe-right style arc
- stop
- speed up
- speed down

### 10.3 Auto Mode

In auto mode, the robot performs free-roam obstacle avoidance.

It reads four ultrasonic sensors:

- front
- back
- left
- right

Then it decides whether to:

- move full forward
- move slower
- stop
- reverse
- reverse while curving left
- reverse while curving right
- pause
- resume

### 10.4 Goal Mode

In goal mode, the robot performs distance-based movement and turn-based movement using encoders.

This means the user can send a target distance and then later send a turn command.

This is much stronger than time-only movement because encoder tracking improves repeatability.

## 11. Project 2 Hardware

The hardware listed in [config.h](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/config.h:1) includes:

- ATmega32 at 8 MHz
- 2 DC motors with L298N
- 2 encoders
- 4 HC-SR04 ultrasonic sensors
- HC-05 or HC-06 Bluetooth module
- 16x2 LCD over I2C

### 11.1 Why This Hardware Set Is Good

This set is appropriate for a graduation embedded robot because it covers:

- motion control
- environment sensing
- communication
- operator feedback
- autonomous behavior

## 12. Project 2 Software Architecture

The project is divided into separate modules:

- timer
- encoder
- motor
- ultrasonic
- Bluetooth
- navigation
- display
- LCD

This is a strong modular design.

The firmware is easier to maintain than if all code were inside one large `main.c`.

## 13. Project 2 Main Loop Design

The main loop in [main.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/main.c:1) runs a set of non-blocking tasks:

- `us_task()`
- `bt_task()`
- `safety_task()`
- `nav_task()` when sonar data is fresh
- `display_task()`

This is one of the most important design choices in the entire workspace.

### 13.1 Why It Is Important

This means the firmware is built as a cooperative scheduler style.

It does not use a real RTOS, but it still behaves in a structured way:

- each subsystem advances a little each loop
- no subsystem should block too long
- the display is throttled
- sonar scanning is round-robin and non-blocking

This is excellent for an AVR graduation project.

## 14. Project 2 Global State

The main firmware stores:

- robot mode
- navigation state
- manual command
- manual speed
- sonar values
- encoder totals
- goal tick target
- turn tick target

This global state model is useful because each module can contribute to one shared robot behavior.

## 15. Bluetooth Command System

The Bluetooth parser supports:

- `M`
- `A`
- `F`
- `B`
- `L`
- `R`
- `S`
- `+`
- `-`
- `Q`
- `E`
- `G<cm>`
- `T<deg>R`
- `T<deg>L`

### 15.1 Why This Command Set Is Strong

This is a small but expressive command protocol.

It supports:

- mode switching
- manual motion
- speed control
- absolute travel goals
- absolute turn goals

For a serial Bluetooth interface, this is a very practical design.

## 16. Motor System

The motor subsystem uses:

- Timer0 PWM for left motor
- Timer2 PWM for right motor
- L298N direction pins

This means the robot can perform:

- forward
- backward
- pivot turns
- arc-like one-wheel movement
- reverse curves

### 16.1 Why This Is Good

The abstraction in `motor_drive()` allows the navigation layer to request directions without rewriting low-level pin logic every time.

That is clean layered embedded programming.

## 17. Encoder System

The encoders use:

- INT0 for left wheel
- INT1 for right wheel

Each interrupt increments a wheel count.

The code uses:

- `encoder_left()`
- `encoder_right()`
- `encoder_avg()`
- `cm_to_ticks()`
- `deg_to_ticks()`

This means the project converts physical targets into measurable wheel counts.

That is much better than using only time delays.

## 18. Ultrasonic System

The ultrasonic subsystem is one of the best technical parts of the robot project.

Instead of blocking and measuring one sensor with long delays, the firmware implements a non-blocking round-robin state machine.

The four sensors are:

- front
- back
- left
- right

### 18.1 Why This Design Is Strong

This allows:

- continuous sensing
- reduced blocking
- frequent updates
- compatibility with the rest of the robot loop

### 18.2 Sensor Meaning

The main thresholds are:

- `DIST_STOP = 20 cm`
- `DIST_WARN = 35 cm`
- `DIST_SIDE = 15 cm`
- `DIST_BACK_SAFE = 20 cm`

These thresholds guide obstacle avoidance decisions.

## 19. Navigation System

The navigation module is the brain of the mobile robot firmware.

It handles:

- free-roam automatic behavior
- goal-distance tracking
- turn tracking
- obstacle avoidance

### 19.1 Auto Navigation

In auto mode, the robot:

- moves forward normally
- slows down in warning distance
- stops when an obstacle is close
- reverses and curves to avoid obstacles
- pauses
- resumes

### 19.2 Goal Navigation

In goal mode, the robot:

- starts moving toward a target distance
- pauses encoder progress during avoidance behavior
- marks goal completion
- waits for turn command
- performs encoder-based pivot turn
- reports turn completion

This is very good graduation-project behavior because it combines:

- autonomy
- precise movement
- safety
- state-driven logic

## 20. Display System

The display system shows different information depending on mode.

### 20.1 Manual Mode Display

It shows:

- current manual command
- current speed
- sensor summary

### 20.2 Auto Mode Display

It shows:

- auto navigation state
- sensor summary

### 20.3 Goal Mode Display

It shows:

- goal progress
- traveled distance
- front sensor status
- turn progress
- goal reached status
- turn done status

### 20.4 Why This Matters

A small LCD becomes a major debugging tool in embedded systems.

This project uses it well.

## 21. Main Code Explanation for `GccApplication51`

The main startup sequence is:

1. initialize timer
2. initialize encoder
3. initialize motor
4. initialize ultrasonic
5. initialize Bluetooth
6. initialize display
7. enable interrupts
8. show boot screen
9. show mode banner
10. initialize navigation
11. send ready strings over Bluetooth
12. enter infinite loop

This is a clean and logical initialization order.

### 21.1 Why The Order Is Good

- timing is ready first
- encoder and motor hardware are initialized before navigation begins
- ultrasonic sensing is ready before auto decisions
- Bluetooth is ready before command reception
- display is ready before status output
- interrupts are enabled only after essential initialization

That is correct embedded thinking.

## 22. Comparison Between the Two Projects

### 22.1 `GccApplication48`

This project is:

- servo-based
- traffic-state driven
- UART-command driven
- arm and signal controller

### 22.2 `GccApplication51`

This project is:

- wheel-motion based
- autonomous and manual
- multi-sensor
- encoder-aware
- navigation oriented

### 22.3 Engineering Value

Together, the two projects show that the student worked on:

- actuation control
- serial protocol design
- sensing
- autonomous behavior
- real-time event handling
- embedded UI feedback

That is strong graduation-project value.

## 23. Communication Interfaces Used

Across the two projects, the embedded code uses:

- UART
- I2C
- GPIO
- PWM
- external interrupts
- timer interrupts

### 23.1 Why This Is Important

This means the student is not using only one microcontroller feature.

The firmware demonstrates broad embedded-system knowledge.

## 24. Real-Time Design Style

A major strength of the workspace is that both projects avoid naive long blocking behavior as much as possible.

Examples:

- `GccApplication48` uses state-machine timing with `sys_ms`
- `GccApplication51` uses task-like loop progression
- ultrasonic measurement is non-blocking and round-robin
- display updates are throttled
- Bluetooth parsing is buffered and interrupt-assisted

This is a very good embedded design style for AVR systems.

## 25. Educational Value

This workspace is educationally strong because it teaches:

- modular embedded design
- actuator abstraction
- sensor abstraction
- state machines
- cooperative scheduling
- encoder calibration
- UART protocol parsing
- I2C peripheral integration
- live LCD diagnostics

## 26. Main Risks and Technical Limits

The main technical limits are:

- no RTOS
- shared global-state model instead of strict encapsulation
- no formal error-reporting framework
- no persistent logging
- no advanced sensor fusion
- no closed-loop motor speed PID visible in the current code

These are normal limitations for a student embedded firmware project and do not remove the project’s value.

## 27. Suggested Future Improvements

Recommended future improvements include:

- add watchdog timer support
- add better fault banners on LCD
- add checksum or framed Bluetooth protocol
- add PID speed control
- add battery-voltage monitoring
- add modular command acknowledgments
- rename prototype filenames like `main-9.c`
- add a wiring diagram document
- add test procedures and calibration document

## 28. Conclusion

The embedded workspace at `/media/abso/project/workspace/embedded system` contains two meaningful AVR projects that fit well into a traffic-robot graduation system.

`GccApplication48` is a traffic actuator and signal controller based on:

- six servos
- PCA9685
- LCD I2C
- UART/Bluetooth commands
- non-blocking state transitions

`GccApplication51` is a mobile robot controller based on:

- Bluetooth control
- autonomous obstacle avoidance
- encoder-guided goal movement
- encoder-guided turning
- ultrasonic sensing
- LCD monitoring
- non-blocking cooperative embedded scheduling

The strongest quality of the workspace is that the code is modular and explainable.

The project is not just “working code.”

It is also a good example of:

- embedded architecture
- hardware/software integration
- task decomposition
- event-driven firmware design

That makes it very suitable for use as graduation-project documentation and technical study material.
