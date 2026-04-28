# Yocto `meta-tr` Integration Guide

This guide explains how to integrate the traffic robot Qt/QML app into a custom Yocto layer named `meta-tr`.

## 1. What Was Added

This bundle now includes:

- `meta-tr/conf/layer.conf`
- `meta-tr/README.md`
- `meta-tr/recipes-traffic/traffic-robot-app/traffic-robot-app.bb`

The recipe is written as a development-oriented first pass and expects the app source to live in:

`/media/abso/yocto/traffic_robot/traffic_robot_app/source`

## 2. Why This Approach

I used a local-source development layout because the app was explicitly requested to live inside:

`/media/abso/yocto/traffic_robot/traffic_robot_app`

For active development, Yocto's `externalsrc` class is the cleanest match for that request. The official Yocto docs describe `externalsrc` as the canonical way to include a local project, and the official Qt `meta-qt6` docs recommend `inherit qt6-cmake` for Qt applications built with CMake.

## 3. Required Yocto Layers

At minimum, the build should already include:

- `meta`
- `meta-poky`
- your BSP layers
- `meta-qt6`
- this new `meta-tr`

## 4. Add `meta-tr` To `BBLAYERS`

In your Yocto build directory:

```bash
bitbake-layers add-layer /media/abso/yocto/traffic_robot/traffic_robot_app/meta-tr
```

If you edit `conf/bblayers.conf` manually, add:

```conf
BBLAYERS += " /media/abso/yocto/traffic_robot/traffic_robot_app/meta-tr "
```

## 5. Make Sure `meta-qt6` Is Present

The recipe uses:

```bitbake
inherit qt6-cmake
```

So `meta-qt6` must already be available in the Yocto build environment.

## 6. Prepare The Source Snapshot

Place a clean copy of the app sources in:

`/media/abso/yocto/traffic_robot/traffic_robot_app/source`

Recommended contents:

- `CMakeLists.txt`
- `main.cpp`
- `camera.*`
- `datamanager.*`
- `rosstreammanager.*`
- `systemmonitor.*`
- `include/`
- `src/`
- `qml/`
- documentation you want to retain

Do not copy:

- `build/`
- `CMakeFiles/`
- `.qt/`
- `.rcc/`
- `CMakeCache.txt`
- local editor settings

## 7. Build The Recipe

To build only the application package:

```bash
bitbake traffic-robot-app
```

To include it in an image, add:

```conf
IMAGE_INSTALL:append = " traffic-robot-app"
```

Then build your image recipe.

## 8. What The Recipe Does

The recipe:

- builds the CMake project with `qt6-cmake`
- uses `externalsrc` to build from the local app snapshot
- installs the app binary produced by the upstream `CMakeLists.txt`
- adds a helper launcher script named `traffic-robot-app`
- defaults `MONITOR_APP_DB_PATH` to `/var/lib/traffic-robot-app`

That launcher means you can start the app on target with:

```bash
traffic-robot-app
```

## 9. Likely Follow-Up Fixes

The first Yocto build may still need adjustments depending on your image and BSP.

Most likely follow-ups are:

- add missing Qt runtime packages for QML imports
- verify Qt Location plugin availability
- verify OpenGL / Wayland / X11 stack on the target
- confirm whether ROS 2 is meant to be enabled in the Yocto build or left off

## 10. Recommended Production Upgrade Path

The included recipe is good for local development. For a reproducible release, the next step should be:

1. move the app to a Git repository or release tarball
2. replace the local `externalsrc` flow with a fixed `SRC_URI`
3. pin the exact revision with `SRCREV` if using Git
4. keep `meta-tr` as the owner of the packaging metadata

## 11. Known App-Level Issues To Watch In Yocto

- The current app uses a development-oriented absolute default database path in `main.cpp`.
- The source tree contains prototype files that may not belong in a minimal product image.
- Street B topic naming should be standardized before field deployment.
- Runtime QML imports must match the packages available in the target image.

## 12. Source Links

Official references used for this guide:

- Yocto layer creation and enabling:
  https://docs.yoctoproject.org/dev/dev-manual/layers.html

- Yocto `externalsrc` class:
  https://docs.yoctoproject.org/ref-manual/classes.html

- Qt `meta-qt6` application build guidance:
  https://doc.qt.io/Boot2Qt-6.8/b2qt-meta-qt6.html
