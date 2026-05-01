# RPi4 And RPi5 Yocto Configuration Report

## Scope

This report summarizes the current Yocto configuration for the two build workspaces:

- RPi4 build: `/media/abso/yocto/scarthgap/rpi`
- RPi5 build: `/media/abso/yocto/scarthgap/rpi5`

It focuses on:

- machine selection
- kernel and U-Boot setup
- enabled hardware interfaces
- layer stack
- important image packages
- integration status of the project applications

## 1. Shared Yocto Base

Both build directories use:

- `DISTRO = "poky"`
- `INIT_MANAGER = "systemd"`
- `PACKAGE_CLASSES = "package_deb"`
- `INHERIT += "buildhistory"`
- shared download cache:
  - `DL_DIR = /media/abso/project/shared/downloads`
- shared sstate cache:
  - `SSTATE_DIR = /home/abso/data/shared/sstate-cache`

Both builds also use the same main layer stack from `bblayers.conf`:

- `meta`
- `meta-poky`
- `meta-yocto-bsp`
- `meta-openembedded/meta-oe`
- `meta-openembedded/meta-python`
- `meta-openembedded/meta-multimedia`
- `meta-openembedded/meta-networking`
- `meta-openembedded/meta-filesystems`
- `meta-raspberrypi`
- `meta-rt`
- `meta-ros/meta-ros-common`
- `meta-ros/meta-ros2`
- `meta-ros/meta-ros2-jazzy`
- `meta-intel-realsense`
- `meta-qt5`
- `meta-virtualization`
- `/media/abso/yocto/scarthgap/rpi5/workspace`

## 2. RPi4 Build Summary

### Active build path

- `/media/abso/yocto/scarthgap/rpi`

### Active machine

- `MACHINE ??= "rpi-extra"`

### Actual machine inheritance

The custom machine file is:

- `/media/abso/yocto/scarthgap/meta-rt/conf/machine/rpi-extra.conf`

It inherits:

- `conf/machine/raspberrypi4-64.conf`

So the current `rpi` build is a Raspberry Pi 4 64-bit configuration.

### Important finding

`rpi-extra.conf` is labeled as a Raspberry Pi 5 configuration in its header comments, but it actually inherits the Raspberry Pi 4 64-bit machine. The comment and the real machine base do not match.

## 3. RPi4 Kernel And Boot

The Raspberry Pi BSP defaults select:

- kernel provider: `linux-raspberrypi`
- kernel version family: `6.6.x`

From the inherited Raspberry Pi 4 machine:

- device tree family: `bcm2711`
- boot image name: `kernel8.img`
- serial console: `ttyS0`
- arm64 kernel image type: `Image`
- boot command with U-Boot: `booti`

### RPi4 U-Boot

The custom machine enables:

- `RPI_USE_U_BOOT = "1"`
- `UBOOT_MACHINE = "rpi_arm64_config"`

This means the expected boot chain is:

1. Raspberry Pi firmware starts from the boot partition
2. `u-boot.bin` is loaded
3. U-Boot loads the kernel `Image`
4. Linux boots with `booti`

### RPi4 hardware interfaces

Enabled in the machine config:

- UART
- I2C
- SPI
- PWM

Added in `local.conf`:

```conf
RPI_EXTRA_CONFIG:append = "\
dtoverlay=pwm-2chan\n\
dtparam=audio=off\n\
"
```

So the RPi4 build explicitly requests:

- PWM two-channel overlay
- audio disabled

### RPi4 kernel module note

`rpi-extra.conf` contains:

```conf
KERNEL_MODULE_AUTOLOAD:raspberrypi5 += "i2c-dev i2c-bcm2835 spi-bcm2835"
```

Because the active build is Raspberry Pi 4 based, this override name is likely wrong for the RPi4 case and may not apply as intended.

## 4. RPi4 Image Content

Main requested packages include:

- package management:
  - `apt`
  - `dpkg`
- SSH:
  - `ssh-server-dropbear`
  - `ssh-server-openssh`
- development:
  - `gcc`
  - `g++`
  - `make`
  - `cmake`
  - `pkgconfig`
- Python and AI helpers:
  - `python3`
  - `python3-dev`
  - `python3-pip`
  - `python3-setuptools`
  - `python3-wheel`
  - `python3-numpy`
  - `python3-opencv`
  - `python3-pillow`
  - `python3-pyyaml`
  - `python3-requests`
  - `python3-gpiod`
- hardware and system tools:
  - `rpi-gpio`
  - `libgpiod`
  - `libgpiod-tools`
  - `i2c-tools`
  - `v4l-utils`
  - `htop`
  - `git`
  - `rsync`
  - `sudo`
- networking:
  - `connman`
  - `connman-tools`
  - `connman-client`
  - `connman-gnome`
  - `connman-plugin-wifi`
  - `connman-plugin-ethernet`
  - `connman-conf`
  - `networkmanager`
  - `networkmanager-nmcli`
  - `networkmanager-openconnect`
  - `wpa-supplicant`
  - `bluez5`
  - `pi-bluetooth`
  - `linux-firmware`
- ROS 2:
  - `ros-base`
  - `turtlesim`
  - `teleop-twist-keyboard`

### RPi4 networking observation

The image explicitly includes both:

- `connman`
- `networkmanager`

This can be valid, but it may also create overlapping network control if both services manage the same interfaces.

## 5. RPi5 Build Summary

### Active build path

- `/media/abso/yocto/scarthgap/rpi5`

### Active machine

- `MACHINE ??= "rpi5-extra"`

### Actual machine inheritance

The custom machine file is:

- `/media/abso/yocto/scarthgap/meta-rt/conf/machine/rpi5-extra.conf`

It inherits:

- `conf/machine/raspberrypi5.conf`

So the current `rpi5` build is correctly based on Raspberry Pi 5.

## 6. RPi5 Kernel And Boot

The Raspberry Pi BSP defaults again select:

- kernel provider: `linux-raspberrypi`
- kernel version family: `6.6.x`

From the inherited Raspberry Pi 5 machine:

- device tree family: `bcm2712`
- boot image name: `kernel_2712.img`
- serial console: `ttyAMA10`
- arm64 kernel image type: `Image`
- boot command with U-Boot: `booti`

### RPi5 U-Boot

The custom machine enables:

- `RPI_USE_U_BOOT = "1"`
- `UBOOT_MACHINE = "rpi_arm64_config"`

### RPi5 hardware interfaces

Enabled in the machine config:

- UART
- I2C
- SPI
- PWM

The Pi 5 machine file also adds:

```conf
KERNEL_MODULE_AUTOLOAD:raspberrypi5 += "i2c-dev i2c-bcm2835 spi-bcm2835"
```

This override matches the Pi 5 machine family and is consistent with the active build.

## 7. RPi5 Image Content

Main requested packages include:

- package management:
  - `apt`
  - `dpkg`
- SSH:
  - `ssh-server-dropbear`
  - `ssh-server-openssh`
- development:
  - `gcc`
  - `g++`
  - `make`
  - `cmake`
- Python and AI helpers:
  - `python3`
  - `python3-dev`
  - `python3-pip`
  - `python3-setuptools`
  - `python3-wheel`
  - `python3-numpy`
  - `python3-opencv`
  - `python3-pillow`
  - `python3-pyyaml`
  - `python3-requests`
  - `python3-gpiod`
- hardware and system tools:
  - `rpi-gpio`
  - `libgpiod`
  - `libgpiod-tools`
  - `i2c-tools`
  - `v4l-utils`
  - `htop`
  - `rsync`
  - `sudo`
- networking:
  - `connman`
  - `networkmanager`
  - `networkmanager-nmcli`
  - `pi-bluetooth`
- ROS 2:
  - `ros-base`
  - `turtlesim`
- container support:
  - `docker-compose`
  - `DISTRO_FEATURES:append = " virtualization"`

### RPi5 package differences vs RPi4

Compared with the RPi4 build, the RPi5 `local.conf` does not explicitly request:

- `linux-firmware`
- `wpa-supplicant`
- `bluez5`
- `git`
- `pkgconfig`
- `teleop-twist-keyboard`
- the same PWM boot overlay block

If those features are needed on Pi 5 too, they should be added deliberately.

## 8. Project Layer Integration Status

The project contains custom application layers here:

- `/media/abso/yocto/traffic_robot/traffic_ai_model/meta-tr`
- `/media/abso/yocto/traffic_robot/traffic_robot_app/meta-tr`

These layers provide recipes for:

- `traffic-ai-model`
- `traffic-robot-app`

However, they are not currently listed in either active `bblayers.conf`.

That means the application recipes exist, but they are not yet part of the live build configuration.

## 9. Qt Layer Status

The dashboard application recipe uses Qt 6, but the active `bblayers.conf` currently includes:

- `meta-qt5`

and does not include:

- `meta-qt6`

So the dashboard integration is not complete yet for Yocto build usage.

## 10. Main Findings

### Working and consistent parts

- both builds use `poky`
- both builds use `systemd`
- both builds use the Raspberry Pi BSP kernel family
- both builds enable U-Boot
- both builds include ROS 2 Jazzy base packages
- both builds include GPIO and camera-support user-space packages

### Gaps and risks

- `rpi-extra.conf` header text is misleading because it is actually Pi 4 based
- `KERNEL_MODULE_AUTOLOAD:raspberrypi5` inside the Pi 4 machine file is likely scoped incorrectly
- the RPi4 image mixes `connman` and `networkmanager`
- the RPi5 image is lighter than the RPi4 image in several network/debug areas
- the custom project application layers are prepared but not active
- Qt 6 layer support is still missing from the active build setup

## 11. Recommended Next Actions

1. Fix the naming and override scope in `rpi-extra.conf`.
2. Decide whether both `connman` and `networkmanager` should stay in the same image.
3. Align the RPi5 package list with RPi4 if the same feature set is required.
4. Add `meta-qt6` to `BBLAYERS`.
5. Add the two custom `meta-tr` project layers to `BBLAYERS`.
6. Add `traffic-ai-model` and `traffic-robot-app` to `IMAGE_INSTALL` if they should be built into the image.

## 12. Source Files Used

- `/media/abso/yocto/scarthgap/rpi/conf/local.conf`
- `/media/abso/yocto/scarthgap/rpi5/conf/local.conf`
- `/media/abso/yocto/scarthgap/rpi/conf/bblayers.conf`
- `/media/abso/yocto/scarthgap/rpi5/conf/bblayers.conf`
- `/media/abso/yocto/scarthgap/meta-rt/conf/machine/rpi-extra.conf`
- `/media/abso/yocto/scarthgap/meta-rt/conf/machine/rpi5-extra.conf`
- `/media/abso/yocto/traffic_robot/traffic_ai_model/meta-tr`
- `/media/abso/yocto/traffic_robot/traffic_robot_app/meta-tr`
