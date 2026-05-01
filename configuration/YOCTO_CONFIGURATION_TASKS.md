# Yocto Configuration Tasks

## Purpose

This file turns the Yocto configuration review into a clear action list.

It is written for the current project layout:

- RPi4 build: `/media/abso/yocto/scarthgap/rpi`
- RPi5 build: `/media/abso/yocto/scarthgap/rpi5`

Project application layers:

- `/media/abso/yocto/traffic_robot/traffic_ai_model/meta-tr`
- `/media/abso/yocto/traffic_robot/traffic_robot_app/meta-tr`

## 1. What Must Be Fixed First

### Task 1: Correct the RPi4 custom machine file

File:

- `/media/abso/yocto/scarthgap/meta-rt/conf/machine/rpi-extra.conf`

Problem:

- the file header says Raspberry Pi 5
- the file actually inherits `raspberrypi4-64.conf`
- the autoload override is scoped to `raspberrypi5`

Action:

- rewrite the file comments so they describe Raspberry Pi 4
- change the kernel module autoload override so it matches the RPi4 machine family

Recommended content:

```conf
#@TYPE: Machine
#@NAME: Raspberry Pi 4 Extended Configuration
#@DESCRIPTION: Extended machine configuration for Raspberry Pi 4 with hardware interface support
MACHINEOVERRIDES =. "raspberrypi4-64:${MACHINE}"
require conf/machine/raspberrypi4-64.conf

DISABLE_RPI_BOOT_LOGO = "1"
DISABLE_SPLASH = "1"
RPI_USE_U_BOOT = "1"
UBOOT_MACHINE = "rpi_arm64_config"

ENABLE_UART = "1"
ENABLE_I2C = "1"
ENABLE_I2C_BUS = "1"
ENABLE_SPI_BUS = "1"
ENABLE_PWM = "1"

KERNEL_MODULE_AUTOLOAD:raspberrypi4 += "i2c-dev i2c-bcm2835 spi-bcm2835"
```

### Task 2: Keep the Pi 5 machine file aligned with Pi 5

File:

- `/media/abso/yocto/scarthgap/meta-rt/conf/machine/rpi5-extra.conf`

Keep these settings:

- `require conf/machine/raspberrypi5.conf`
- `RPI_USE_U_BOOT = "1"`
- `UBOOT_MACHINE = "rpi_arm64_config"`
- `ENABLE_UART = "1"`
- `ENABLE_I2C = "1"`
- `ENABLE_SPI_BUS = "1"`
- `ENABLE_PWM = "1"`

## 2. Layer Stack Tasks

### Task 3: Add Qt 6 support

Problem:

- the dashboard recipe uses Qt 6
- active `bblayers.conf` only includes `meta-qt5`

Files to edit:

- `/media/abso/yocto/scarthgap/rpi/conf/bblayers.conf`
- `/media/abso/yocto/scarthgap/rpi5/conf/bblayers.conf`

Add:

```conf
/media/abso/yocto/scarthgap/meta-qt6 \
```

### Task 4: Add the custom project layers

Problem:

- the recipes for the traffic app and AI model exist
- they are not currently active in the build

Files to edit:

- `/media/abso/yocto/scarthgap/rpi/conf/bblayers.conf`
- `/media/abso/yocto/scarthgap/rpi5/conf/bblayers.conf`

Add:

```conf
/media/abso/yocto/traffic_robot/traffic_ai_model/meta-tr \
/media/abso/yocto/traffic_robot/traffic_robot_app/meta-tr \
```

Recommended layer additions:

```conf
  /media/abso/yocto/scarthgap/meta-qt6 \
  /media/abso/yocto/traffic_robot/traffic_ai_model/meta-tr \
  /media/abso/yocto/traffic_robot/traffic_robot_app/meta-tr \
```

## 3. Image Content Tasks

### Task 5: Add the project packages to the image

Files to edit:

- `/media/abso/yocto/scarthgap/rpi/conf/local.conf`
- `/media/abso/yocto/scarthgap/rpi5/conf/local.conf`

Add:

```conf
IMAGE_INSTALL:append = " traffic-ai-model traffic-robot-app"
```

### Task 6: Decide the network stack policy

Current situation:

- RPi4 explicitly includes both `connman` and `networkmanager`
- RPi5 also includes both managers, but with a different package set around them

Choose one of these approaches:

1. Keep both managers and validate runtime behavior carefully.
2. Standardize on `connman`.
3. Standardize on `networkmanager`.

Recommended if stability matters:

- choose one primary network manager per image

### Task 7: Align the RPi5 image with the RPi4 image if needed

If Pi 5 must support the same feature set as Pi 4, add these to:

- `/media/abso/yocto/scarthgap/rpi5/conf/local.conf`

Recommended additions:

```conf
DISTRO_FEATURES:append = " connman"
PACKAGECONFIG:append:pn-connman = " wifi bluetooth"

IMAGE_INSTALL:append = " \
    git \
    pkgconfig \
    teleop-twist-keyboard \
    wpa-supplicant \
    bluez5 \
    linux-firmware \
"

RPI_EXTRA_CONFIG:append = "\
dtoverlay=pwm-2chan\n\
dtparam=audio=off\n\
"
```

Use this only if the Pi 5 target really needs the same runtime profile.

## 4. Build And Validation Tasks

### Task 8: Check the final layer list

For RPi4:

```bash
cd /media/abso/yocto/scarthgap
source oe-init-build-env /media/abso/yocto/scarthgap/rpi
bitbake-layers show-layers
```

For RPi5:

```bash
cd /media/abso/yocto/scarthgap
source oe-init-build-env /media/abso/yocto/scarthgap/rpi5
bitbake-layers show-layers
```

Verify that the output includes:

- `meta-qt6`
- `traffic_ai_model/meta-tr`
- `traffic_robot_app/meta-tr`

### Task 9: Build the image

After the layer and config changes, build the target image:

```bash
bitbake <image-recipe-name>
```

If you are unsure of the image recipe name:

```bash
bitbake-layers show-recipes | rg "image"
```

### Task 10: Validate on target hardware

Minimum runtime checks:

- confirm the system boots through U-Boot
- confirm the expected kernel starts
- confirm I2C devices appear under `/dev/i2c-*`
- confirm SPI-related modules are present if needed
- confirm PWM overlay is active if expected
- confirm `traffic-ai-model` exists in `PATH`
- confirm `traffic-robot-app` exists in `PATH`
- confirm the Qt application launches without missing QML import errors

## 5. Recommended Work Order

Use this order to reduce confusion:

1. fix `rpi-extra.conf`
2. add `meta-qt6`
3. add both custom `meta-tr` layers
4. add `traffic-ai-model` and `traffic-robot-app` to `IMAGE_INSTALL`
5. decide the networking policy
6. align the Pi 5 package list if required
7. build RPi4
8. build RPi5
9. validate on hardware

## 6. Short Summary

The most important missing items today are:

- a corrected RPi4 machine description
- proper module autoload scope for RPi4
- `meta-qt6` in `BBLAYERS`
- custom `meta-tr` application layers in `BBLAYERS`
- application packages added to `IMAGE_INSTALL`

Once those are done, the Yocto setup will be much closer to a complete project image for both RPi4 and RPi5.
