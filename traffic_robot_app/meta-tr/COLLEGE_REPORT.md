# College Report: Traffic Robot App Yocto Layer

## 1. Introduction

This directory contains the Yocto integration layer for the Qt traffic robot application.

It is the deployment packaging side of the monitor app.

## 2. Purpose

The purpose of this folder is to package the Qt application for embedded deployment through Yocto.

It provides:

- layer structure
- recipe placement
- integration path with the build system

## 3. Why It Matters

A monitor app is only useful on target hardware if it can be deployed cleanly.

This directory shows the project is designed with deployment in mind.

## 4. Educational Value

Students can learn:

- how Qt applications are integrated into Yocto
- why `meta-qt6` is required
- how custom recipes fit into a project layer

## 5. Relationship To Other Folders

This folder depends on:

- `traffic_robot_app/source`
- `configuration`
- active `BBLAYERS`

## 6. Conclusion

This directory is a deployment bridge between application development and embedded Linux packaging.

## 7. Code Example And How To Use It

Example from the Qt app recipe:

```bitbake
inherit qt6-cmake pkgconfig externalsrc

DEPENDS += "qtbase qtdeclarative qtlocation qtpositioning qt5compat opencv"
EXTERNALSRC ?= "/media/abso/yocto/traffic_robot/traffic_robot_app/source"
```

How to use it:

- `qt6-cmake` prepares a Qt 6 CMake build in Yocto
- `DEPENDS` lists build-time requirements
- `EXTERNALSRC` points the recipe to the live app source tree

Practical use:

- add `meta-qt6` and this custom layer to `BBLAYERS`
- run `bitbake traffic-robot-app`

## 8. Detailed Walkthrough

This recipe is the deployment bridge for the UI.

It does three important things:

1. selects Qt 6 build behavior
2. points Yocto to the live source tree
3. creates a launcher that sets the database path

Important launcher idea:

```sh
export MONITOR_APP_DB_PATH="${MONITOR_APP_DB_PATH:-/var/lib/traffic-robot-app}"
exec /usr/bin/appCircleBarsUI "$@"
```

Meaning:

- on the target, the app does not need to depend on the original development path
- it can use a target-friendly writable location

This is good practice because embedded systems should not rely on desktop development paths.
