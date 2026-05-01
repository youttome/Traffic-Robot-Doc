# Embedded System Book 2: Code Guide and Source Explanation

## 1. Cover Page

- Title: Embedded System Code Explanation Guide
- Source workspace: `/media/abso/project/workspace/embedded system`
- Output path: `/media/abso/yocto/traffic_robot/EMBEDDED_SYSTEM_BOOK_2_CODE_GUIDE.md`
- Focus: explain the real source code, the main firmware flow, and the helper modules

## 2. Reading Strategy

If you are reading this workspace for the first time, use this order:

1. read the real main file of `GccApplication48`: [main-9.c](/media/abso/project/workspace/embedded%20system/GccApplication48/GccApplication48/main-9.c:1)
2. read the helper drivers:
   - [pca9685.c](/media/abso/project/workspace/embedded%20system/GccApplication48/GccApplication48/pca9685.c:1)
   - [lcd_i2c.c](/media/abso/project/workspace/embedded%20system/GccApplication48/GccApplication48/lcd_i2c.c:1)
3. read the main robot controller: [main.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/main.c:1)
4. read the central config file: [config.h](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/config.h:1)
5. then read these support modules:
   - [bluetooth.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/bluetooth.c:1)
   - [motor.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/motor.c:1)
   - [ultrasonic.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/ultrasonic.c:1)
   - [encoder.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/encoder.c:1)
   - [nav.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/nav.c:1)
   - [display.c](/media/abso/project/workspace/embedded%20system/GccApplication51/GccApplication51/display.c:1)

This order is best because it follows real control flow.

## 3. Code Structure Overview

### 3.1 `GccApplication48`

- `main.c`: placeholder empty project entry
- `main-9.c`: real traffic-arm state machine
- `pca9685.c/.h`: I2C PWM driver for servo control
- `lcd_i2c.c/.h`: I2C LCD driver over PCF8574

### 3.2 `GccApplication51`

- `main.c`: robot coordination logic
- `config.h`: all major settings, pins, modes, and thresholds
- `timer.c/.h`: 1 ms system tick
- `encoder.c/.h`: wheel tick counting and conversion helpers
- `motor.c/.h`: motor direction and PWM driver abstraction
- `ultrasonic.c/.h`: non-blocking round-robin HC-SR04 state machine
- `bluetooth.c/.h`: UART receive buffer and command parser
- `nav.c/.h`: autonomous and goal-based navigation state machine
- `display.c/.h`: LCD output formatting

## 4. Project 1 Main File: `main-9.c`

### 4.1 Identity of the File

This is the real logic file for `GccApplication48`.

The header comment clearly says:

- Traffic Robot Arm
- 6 servos
- LCD I2C
- PCA9685 I2C
- Bluetooth/UART
- non-blocking logic
- priority logic

That comment is actually very useful because it describes the embedded design clearly.

### 4.2 Important Definitions

The code defines:

```c
#define CH_SRA  0
#define CH_SRB  1
#define CH_ER   2
#define CH_SLA  3
#define CH_SLB  4
#define CH_EL   5
#define N_SERVO 6
```

This means each servo channel has a dedicated logical name.

This is much better than using raw numbers everywhere in the code.

### 4.3 Traffic Light Pins

The code also defines light pins:

```c
#define PIN_RED_R    PB1
#define PIN_GREEN_R  PB2
#define PIN_RED_L    PB3
#define PIN_GREEN_L  PB4
```

This means the controller is not only a servo controller.

It also drives a traffic light output interface.

### 4.4 Timing Constants

```c
#define T_MOVE          600UL
#define T_NORMAL_HOLD   30000UL
#define T_AMB_HOLD      15000UL
```

These constants define:

- servo movement settling time
- normal traffic phase hold duration
- ambulance priority hold duration

Putting them in named constants is good embedded practice.

## 5. Project 1 State Machine

### 5.1 Why the State Machine Matters

The strongest design choice in `main-9.c` is the state machine.

The code defines a large `Step` enum for:

- idle
- normal phase A states
- normal phase B states
- emergency-right states
- emergency-left states

This structure means the firmware executes behavior as a sequence of small deterministic states.

### 5.2 Example States

```c
typedef enum {
    S_IDLE = 0,
    S_C0A_SR90,
    S_C0A_ER90,
    S_C0A_SL90,
    S_C0A_EL0,
    S_C0A_HOLD,
    ...
    S_C1_EL0,
    S_C1_SL0,
    ...
    S_C2_ER0,
    S_C2_SR0,
    ...
} Step;
```

### 5.3 Why This Is Good

Each name tells you:

- which case it belongs to
- which side it affects
- which motion is expected

That makes debugging much easier.

## 6. Project 1 Timing Logic

The code uses:

```c
static volatile uint32_t sys_ms = 0;
static uint32_t wait_end = 0;
```

and helper functions:

```c
static void wait_ms(uint32_t ms) { wait_end = sys_ms + ms; }
static uint8_t wait_done(void)   { return (sys_ms >= wait_end) ? 1 : 0; }
```

This is a classic non-blocking embedded timing pattern.

Instead of delaying the CPU in every movement step, the code:

- sets a target end time
- checks later if the time has elapsed

That allows interrupt-driven events like UART commands to remain responsive.

## 7. Project 1 UART Receive Logic

The receive interrupt:

```c
ISR(USART_RXC_vect) {
    uint8_t b = UDR;
    uart_tx(b);

    if (b != '0' && b != '1' && b != '2') return;
    if (b == current_cmd) return;

    pend_cmd    = b;
    preempt_flg = 1;
}
```

### 7.1 Explanation

- `UDR` reads the received serial byte.
- `uart_tx(b)` echoes it back.
- only `'0'`, `'1'`, and `'2'` are accepted
- repeated same command is ignored
- valid command becomes the new pending command
- `preempt_flg` tells the main state machine to interrupt current behavior

### 7.2 Why This Is Important

This is how the project implements command preemption safely.

The interrupt itself stays short.

It does not directly perform servo sequences.

That is good ISR design.

## 8. Project 1 Preemption Handler

The key function is:

```c
static void handle_preempt(void) {
    uint8_t cmd = pend_cmd;
    pend_cmd    = 0xFF;
    preempt_flg = 0;
    current_cmd = cmd;
    wait_end    = 0;

    if      (cmd == '0') { cur_prio = PRIO_NORMAL;    cur_step = S_C0A_SR90; }
    else if (cmd == '1') { cur_prio = PRIO_AMBULANCE; cur_step = S_C1_EL0;  }
    else                 { cur_prio = PRIO_AMBULANCE; cur_step = S_C2_ER0;  }
}
```

### 8.1 What It Does

- reads the pending command
- clears pending state
- clears preemption flag
- updates current command
- cancels current wait timing
- jumps into the correct state-machine branch

### 8.2 Why It Is Good

This function centralizes command priority behavior in one place.

That is much cleaner than scattering emergency checks all over the tick function.

## 9. Project 1 Tick Function

The `tick()` function is the core state machine runner.

Its first line is:

```c
if (preempt_flg) { handle_preempt(); return; }
```

This means command interruption has the highest priority.

That is the correct behavior for emergency traffic control.

### 9.1 Example Flow: Normal Phase A

```c
case S_C0A_SR90:
    lights_right_stop();
    shoulder_r(90);
    wait_ms(T_MOVE);
    cur_step = S_C0A_ER90;
    break;
```

This state:

- updates the right-stop traffic-light pattern
- moves the right shoulder pair
- starts a timed wait
- selects the next step

### 9.2 Why This Pattern Is Good

Each state does one small clear thing.

That keeps the code readable and deterministic.

## 10. Project 1 Servo Helper Functions

The file contains helper functions such as:

- `servo_apply(...)`
- `shoulder_r(...)`
- `shoulder_l(...)`

### 10.1 `servo_apply`

```c
static void servo_apply(uint8_t ch, uint8_t deg) {
    if (cur_angle[ch] == deg) return;
    pca9685_set_servo_angle(ch, deg);
    cur_angle[ch] = deg;
    lcd_update();
}
```

### 10.2 Why This Is Good

- it avoids unnecessary servo writes
- it updates cached angle state
- it refreshes LCD display immediately

This is a clean helper function because it combines:

- output optimization
- state bookkeeping
- user feedback

## 11. Project 1 Main Startup Sequence

The `main()` function in `main-9.c` does the following:

1. initializes a debug LED pin
2. initializes PCA9685
3. sets all servo channels to `0°`
4. initializes LCD
5. prints startup text
6. initializes Timer1
7. initializes UART
8. enables interrupts
9. sets all lights red
10. waits briefly for startup visibility
11. clears LCD and shows current angles
12. enters state-machine loop

This is a very good startup sequence for a small embedded actuator controller.

## 12. Project 1 Driver: `pca9685.c`

### 12.1 File Role

This file is the low-level I2C driver and PCA9685 control driver.

It contains:

- I2C start/stop/read/write
- PCA9685 register writes
- PWM frequency setup
- per-channel PWM writes
- servo-angle conversion

### 12.2 Example Function

```c
PCA9685_Status pca9685_set_servo_angle(uint8_t channel, uint8_t angle) {
    if (channel > 15) return PCA9685_ERROR;
    if (angle > 180)  angle = 180;
    uint16_t ticks = SERVO_MIN_TICKS +
        (uint16_t)(((uint32_t)(SERVO_MAX_TICKS-SERVO_MIN_TICKS)*angle)/180);
    return pca9685_set_pwm(channel, 0, ticks);
}
```

### 12.3 Explanation

- validates channel range
- clamps angle to `180`
- converts angle to PWM tick value
- writes PWM setting for that channel

This function is very important because it converts a human-friendly angle into real PWM timing.

## 13. Project 1 Driver: `lcd_i2c.c`

### 13.1 File Role

This file drives a 16x2 LCD through a PCF8574 I2C expander.

### 13.2 Important Functions

- `lcd_init()`
- `lcd_clear()`
- `lcd_set_cursor()`
- `lcd_print_char()`
- `lcd_print_str()`
- `lcd_print_angle()`

### 13.3 Example Snippet

```c
void lcd_set_cursor(uint8_t col, uint8_t row) {
    lcd_cmd(0x80 | ((row ? 0x40 : 0x00) + col));
}
```

This function computes the correct HD44780 cursor address and sends it through the I2C LCD driver.

### 13.4 Important Note

The current `lcd_print_angle()` implementation prints only two digit positions from the value.

That may be intentional for formatting or may need a review if the goal was true three-digit display.

## 14. Project 2 Main File: `GccApplication51/main.c`

### 14.1 File Role

This is the top-level coordinator for the mobile robot.

It does not directly implement every subsystem.

Instead, it:

- stores global state
- defines task functions
- initializes modules
- runs the main loop

That is a very good structure.

### 14.2 Global State Snippet

```c
volatile RobotMode  g_mode        = MODE_AUTO;
volatile NavState   g_nav         = NAV_STOPPED;
volatile ManualCmd  g_mcmd        = MCMD_STOP;
volatile uint8_t    g_mspd        = SPEED_FULL;
volatile Sonar      g_sonar       = {999,999,999,999};
volatile bool       g_sonar_fresh = false;
```

### 14.3 Why This Matters

This defines the robot’s shared live state:

- current mode
- current navigation state
- current manual command
- current manual speed
- current sonar values
- whether new sonar data is ready

## 15. Project 2 Task Design

The file defines small task-like functions:

- `bt_task()`
- `us_task()`
- `nav_task()`
- `safety_task()`
- `display_task()`

This is a cooperative embedded scheduler style.

### 15.1 Why This Is Strong

It makes the firmware easier to:

- read
- test
- expand
- debug

Instead of a giant `while(1)` with random inline logic, each concern has its own function.

## 16. Project 2 Bluetooth Task

The `bt_task()` function reads parsed Bluetooth commands and reacts based on command type.

### 16.1 Example Logic

```c
case BT_SET_MANUAL:
    g_mode = MODE_MANUAL;
    g_mcmd = MCMD_STOP;
    motor_stop();
    display_mode_banner(MODE_MANUAL);
    bt_send("MODE:MANUAL\r\n");
    break;
```

### 16.2 Explanation

When manual mode command arrives:

- robot mode changes to manual
- manual command resets to stop
- motors stop immediately
- LCD mode banner updates
- confirmation string is sent over Bluetooth

This is excellent because the mode switch is explicit and observable.

## 17. Project 2 Goal Mode Commands

### 17.1 Distance Goal

```c
case BT_GOAL:
    g_mode      = MODE_GOAL;
    d_goal_cm   = c.value;
    d_traveled  = 0;
    nav_goal_set(c.value);
    display_mode_banner(MODE_GOAL);
    ...
```

This means:

- switch into goal mode
- store display target
- clear traveled shadow
- tell navigation layer to start encoder-based goal motion

### 17.2 Turn Command

```c
case BT_TURN:
    if (g_mode == MODE_GOAL &&
        nav_state() == NAV_GOAL_REACHED) {
        d_turn_deg   = c.value;
        d_turned_deg = 0;
        nav_turn_set(c.value, c.cw);
        bt_send("TURN:START\r\n");
    } else {
        bt_send("ERR:NOT_REACHED\r\n");
    }
```

This is strong logic because turn commands are only accepted after the goal has been reached.

That prevents confusing behavior.

## 18. Project 2 Safety Task

The safety task is:

```c
static void safety_task(void) {
    if (g_mode != MODE_MANUAL) return;
    if (g_mcmd != MCMD_STOP &&
        timer_elapsed(bt_last_ms) > BT_IDLE_TIMEOUT_MS) {
        g_mcmd = MCMD_STOP;
        motor_stop();
    }
}
```

### 18.1 Why This Is Good

This is a very important safety feature.

If Bluetooth control becomes silent while manual motion is active, the robot stops automatically.

That is good defensive embedded behavior.

## 19. Project 2 Main Loop

The main loop is:

```c
while (1) {
    us_task();
    bt_task();
    safety_task();

    if (g_sonar_fresh) {
        g_sonar_fresh = false;
        nav_task();
    }

    display_task();
}
```

### 19.1 Why This Loop Is Excellent

- ultrasonic task runs continuously
- Bluetooth commands are processed continuously
- safety timeout is checked continuously
- navigation runs only when fresh sensor data exists
- display updates every loop but is internally throttled

This is a clean embedded architecture.

## 20. `config.h` Explanation

`config.h` is the central master configuration file.

It defines:

- CPU frequency
- encoder calibration
- motor speed values
- obstacle thresholds
- timing constants
- encoder pins
- motor pins
- ultrasonic pins
- Bluetooth baud settings
- LCD address
- robot modes
- navigation states
- manual command enums
- global-state extern declarations

### 20.1 Why It Matters

This file is the best single place to understand:

- what hardware is connected
- what operating values the robot uses
- what modes exist

That makes it the most important support header in the whole mobile robot project.

## 21. `motor.c` Explanation

### 21.1 File Role

This file abstracts low-level motor behavior.

The rest of the project does not need to manually toggle each pin every time.

### 21.2 Key Function

```c
void motor_drive(MotorDir dir, uint8_t s) {
    switch (dir) {
        case DIR_FWD:
            motor_raw(s, true,  s, true);
            break;
        case DIR_BWD:
            motor_raw(s, false, s, false);
            break;
        case DIR_PIVOT_L:
            motor_raw(s, false, s, true);
            break;
        case DIR_PIVOT_R:
            motor_raw(s, true,  s, false);
            break;
        ...
    }
}
```

### 21.3 Explanation

This function maps high-level movement directions into:

- left wheel speed
- left wheel direction
- right wheel speed
- right wheel direction

This is exactly what a clean motor abstraction should do.

## 22. `encoder.c` Explanation

### 22.1 File Role

This file counts wheel encoder pulses.

### 22.2 Key ISR Logic

```c
ISR(INT0_vect) { enc_l++; }
ISR(INT1_vect) { enc_r++; }
```

### 22.3 Why It Works

Every rising edge increments the corresponding wheel tick count.

The code later reads:

- left ticks
- right ticks
- average ticks

Then navigation converts ticks into:

- traveled centimeters
- rotated degrees

### 22.4 Important Design Note

The code does not track wheel direction inside the encoder ISR.

That is documented in the header.

The counters simply count pulses up, and the navigation logic uses snapshots and movement context.

That is a reasonable simplification for this project.

## 23. `ultrasonic.c` Explanation

### 23.1 File Role

This file implements a non-blocking state machine for four HC-SR04 sensors.

### 23.2 Main Idea

Instead of measuring all sensors with long busy waits, the code cycles through:

- FRONT
- BACK
- LEFT
- RIGHT

### 23.3 Internal States

```c
typedef enum { USS_IDLE, USS_TRIG, USS_WAIT_HI, USS_MEASURE, USS_DONE } USSt;
```

### 23.4 Why This Is Good

This allows:

- continuous loop execution
- reduced blocking
- reusable sensor update routine

### 23.5 Example Logic

```c
case USS_WAIT_HI:
    if (US_PINR & (1<<s->echo)) {
        t0_us = now_us();
        st = USS_MEASURE;
    } else if (timer_elapsed(ts) > 30) {
        s->dist = 999; st = USS_DONE;
    }
    break;
```

This means:

- if echo rises, start measuring pulse width
- if it takes too long, treat it as invalid and set distance to `999`

That is a robust behavior for embedded sensors.

## 24. `bluetooth.c` Explanation

### 24.1 File Role

This file handles:

- UART receive interrupt buffering
- command line assembly
- parsing of single-character and multi-character commands
- exposing parsed commands to the main loop

### 24.2 Circular Buffer

```c
#define RXSZ 32
static volatile char    rxb[RXSZ];
static volatile uint8_t rxh = 0, rxt = 0;
```

This is a receive ring buffer.

It allows interrupt-driven character storage without forcing the main loop to process each byte immediately.

### 24.3 Parser Strength

The parser supports both:

- immediate one-character commands
- structured commands with numbers and direction suffixes

Examples:

- `F`
- `M`
- `G150`
- `T90R`

### 24.4 Why This Is Good

It balances:

- simplicity
- flexibility
- embedded resource limits

## 25. `nav.c` Explanation

### 25.1 File Role

This is the central robot behavior module.

It controls:

- free roaming
- obstacle avoidance
- goal motion
- turn motion

### 25.2 Internal State Variables

The file stores:

- current nav state
- state entry timestamp
- goal active flag
- turn active flag
- goal ticks
- turn ticks
- turn direction
- encoder snapshots
- completion flags

This is exactly what a navigation state machine needs.

### 25.3 `enter()` Function

The helper function `enter(NavState s)` changes navigation state and immediately sets the motor behavior for that state.

This is a strong design because motor action is tied directly to navigation-state transition.

### 25.4 Avoidance Logic

The `avoid(...)` helper is one of the best parts of the file.

It reads:

- front blocked
- back blocked
- left blocked
- right blocked

Then it chooses:

- stopping
- reverse straight
- reverse curve left
- reverse curve right
- paused
- resume

### 25.5 Why This Is Strong

It encapsulates obstacle reaction in one function that both auto mode and goal mode can use.

That reduces duplicated logic.

## 26. `display.c` Explanation

### 26.1 File Role

This file turns internal robot state into compact LCD text.

It is not only cosmetic.

It is a debugging interface.

### 26.2 LCD Throttle

The file uses:

```c
if (timer_elapsed(last_lcd) < LCD_REFRESH_MS) return;
```

This prevents the LCD from being rewritten too quickly.

That is good because LCD updates are slow and do not need to happen every loop cycle.

### 26.3 Mode-Specific Display

The function `display_update(...)` changes output depending on:

- manual mode
- auto mode
- goal mode
- goal reached
- turning
- turn done

This is a very helpful UI design for an embedded robot.

## 27. Main Code Comparison Between the Two Projects

### 27.1 `GccApplication48`

Main logic style:

- command-driven
- servo-sequence state machine
- interrupt-assisted preemption
- traffic-light synchronized actuation

### 27.2 `GccApplication51`

Main logic style:

- task-based main loop
- multi-mode robot controller
- interrupt-assisted UART and encoders
- non-blocking sensor updates
- autonomous and semi-structured goal behavior

### 27.3 Why This Comparison Matters

The student can show that the workspace covers two different embedded architectures:

- sequence controller
- mobile robot controller

That adds depth to the graduation project.

## 28. How to Use the Embedded Code

### 28.1 `GccApplication48`

Use this project when you need:

- servo-based lane or arm control
- UART command-triggered traffic states
- emergency right and left priority modes
- servo angle display over I2C LCD

### 28.2 `GccApplication51`

Use this project when you need:

- manual Bluetooth robot control
- autonomous ultrasonic obstacle avoidance
- encoder-based movement goals
- encoder-based turns
- LCD mode and telemetry feedback

## 29. Best Practices Visible in the Code

The code already shows many good embedded practices:

- short interrupt service routines
- non-blocking main-loop progression
- hardware abstraction modules
- meaningful enums
- centralized configuration
- compact serial command protocol
- sensor data freshness flags
- display refresh throttling

## 30. Improvement Suggestions for the Code

Recommended improvements:

- rename `main-9.c` to final production filename
- add more explicit comments in some state transitions
- add watchdog reset support
- add clearer fault handling for sensor timeout cases
- add optional command checksum or packet framing for Bluetooth
- add PID or closed-loop speed control if higher accuracy is needed
- add formal calibration document for encoder constants

## 31. Final Conclusion

The embedded code in `/media/abso/project/workspace/embedded system` is well worth documenting because it contains two real embedded subsystems, not only small experiments.

The first project demonstrates:

- I2C servo control
- I2C LCD output
- UART command reception
- traffic-priority state-machine design

The second project demonstrates:

- Bluetooth command parsing
- motor PWM control
- encoder feedback
- ultrasonic round-robin sensing
- autonomous avoidance
- goal-based navigation
- embedded LCD status interface

The most important conclusion is that the main code in both projects is structured and teachable.

The student can explain:

- what each main file does
- what each module does
- how interrupts are used
- how timing is handled
- how commands flow into behavior
- how sensors and actuators are integrated

That makes this workspace a strong embedded-system component of the larger graduation project.
