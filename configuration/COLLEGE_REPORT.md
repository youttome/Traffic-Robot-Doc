# College Report: Configuration Directory

## 1. Introduction

This directory contains the configuration-level documentation for the Raspberry Pi 4 and Raspberry Pi 5 Yocto build environments used by the traffic robot project.

The main purpose of this folder is to explain:

- how the build is structured
- which machine files are active
- what packages are included
- what still needs to be fixed before final deployment

## 2. Directory Purpose

The `configuration` directory is the documentation side of the Yocto platform layer.

It does not contain the full build trees themselves.

Instead, it contains reports and task files that explain the build decisions.

These documents are useful for:

- students learning Yocto
- new team members
- supervisors reviewing deployment readiness
- future maintenance of Raspberry Pi images

## 3. Main Files

This directory currently includes:

- `Configuration_file`
- `RPI4_RPI5_CONFIGURATION_REPORT.md`
- `YOCTO_CONFIGURATION_TASKS.md`

## 4. Meaning Of Each File

`Configuration_file`

- an older task-oriented document
- still useful as legacy notes
- may overlap with the newer task file

`RPI4_RPI5_CONFIGURATION_REPORT.md`

- explains the current state of the two Yocto workspaces
- compares Raspberry Pi 4 and Raspberry Pi 5 settings
- highlights machine inheritance, kernel, U-Boot, and packages

`YOCTO_CONFIGURATION_TASKS.md`

- converts the report findings into action items
- tells the team what to edit
- describes which layers and packages must be added

## 5. Academic Value

From a college project perspective, this folder is important because it shows:

- platform engineering work
- reproducible system design
- cross-compilation planning
- hardware-software integration thinking

Many student projects focus only on application code.

This project goes further by documenting the operating system image level.

That is a strong engineering point.

## 6. Main Technical Findings

The current documentation shows these major findings:

- the RPi4 build uses `rpi-extra`
- the RPi5 build uses `rpi5-extra`
- both builds are based on `poky`
- both builds use `systemd`
- both builds use U-Boot
- both builds include ROS 2 Jazzy support
- the project application layers are prepared but not fully active in `BBLAYERS`

## 7. Important Design Issue

One of the most important findings in this directory is:

- `rpi-extra.conf` is documented like a Pi 5 machine
- but it actually inherits the Raspberry Pi 4 64-bit machine

This is not only a naming issue.

It can also confuse future developers and create wrong assumptions during debugging or deployment.

## 8. Role In The Full Project

The `configuration` folder supports all other parts of the project.

Without a correct Yocto configuration:

- the AI model cannot be deployed cleanly
- the Qt monitor app cannot be packaged correctly
- ROS 2 dependencies may be incomplete
- GPIO, PWM, I2C, and network behavior may be inconsistent

So this directory is the bridge between software design and target hardware deployment.

## 9. Recommended Reading Order

For a first-time reader:

1. read `RPI4_RPI5_CONFIGURATION_REPORT.md`
2. read `YOCTO_CONFIGURATION_TASKS.md`
3. compare those notes with `conf/local.conf`
4. compare them with `conf/bblayers.conf`
5. inspect `meta-rt/conf/machine/*.conf`

## 10. Recommended Student Tasks

- verify the machine inheritance manually
- compare the package differences between RPi4 and RPi5
- check whether `meta-qt6` is required for the app
- verify if the custom `meta-tr` layers are active
- test the resulting image on both boards

## 11. Conclusion

This directory is small in size but high in importance.

It provides the documentation that turns the project from a collection of source folders into a planned embedded Linux system.

For a college report, this folder demonstrates:

- deployment thinking
- embedded systems planning
- documentation discipline
- awareness of real hardware constraints

## 12. Code Example And How To Use It

Example from the active Yocto configuration:

```conf
MACHINE ??= "rpi-extra"
INIT_MANAGER = "systemd"
IMAGE_INSTALL:append = " ros-base turtlesim"
RPI_EXTRA_CONFIG:append = "\
dtoverlay=pwm-2chan\n\
dtparam=audio=off\n\
"
```

How to use it:

- `MACHINE` selects the target machine configuration
- `INIT_MANAGER` selects the init system
- `IMAGE_INSTALL:append` adds packages to the image
- `RPI_EXTRA_CONFIG:append` adds Raspberry Pi boot-time settings

Practical use:

- edit these values in `conf/local.conf`
- rebuild the image with `bitbake`
- flash and test the resulting image on the target board

## 13. Detailed Walkthrough

The configuration side is best understood as three connected layers.

First layer:

- `local.conf`
- this is where image content and local build behavior are changed

Second layer:

- `bblayers.conf`
- this controls which metadata layers are active in the build

Third layer:

- custom machine files in `meta-rt/conf/machine`
- these define board-specific behavior such as U-Boot, I2C, SPI, PWM, and UART

Example machine snippet:

```conf
RPI_USE_U_BOOT = "1"
UBOOT_MACHINE = "rpi_arm64_config"
ENABLE_UART = "1"
ENABLE_I2C = "1"
ENABLE_SPI_BUS = "1"
ENABLE_PWM = "1"
```

Meaning:

- U-Boot is enabled for boot flow
- UART is available for serial communication and debugging
- I2C and SPI are enabled for external devices and sensors
- PWM is enabled for motor, servo, or signal uses

This is useful in the project because both the robot side and the traffic side depend on hardware interface support, not only user-space applications.
