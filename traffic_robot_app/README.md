# Traffic Robot App Documentation Bundle

This folder is a documentation and integration bundle for the Qt 6 + QML traffic robot dashboard currently developed in:

`/home/abso/left/circlebarsui`

It was prepared on `2026-04-27` and placed in the requested Yocto workspace at:

`/media/abso/yocto/traffic_robot/traffic_robot_app`

## What Is In This Folder

- `PROJECT_REPORT.md`
  Full technical report for the QML application, including architecture, runtime flow, strengths, and risks.

- `FILE_REFERENCE.md`
  File-by-file reference for the maintained source files and the important generated/local files seen in the current workspace.

- `TASKS.md`
  Development roadmap and packaging checklist for this app.

- `YOCTO_META_TR_GUIDE.md`
  Guide for integrating the app into a `meta-tr` Yocto layer.

- `meta-tr/`
  A starter layer skeleton with a first-pass application recipe.

- `source/`
  A clean source snapshot copied from the active workspace for Yocto-side development with `externalsrc`.

## Project Summary

The application is a monitoring and control dashboard for a traffic robot / smart intersection system. It combines:

- a Qt Quick operator interface
- a JSON-backed local data store with live reload
- optional ROS 2 topic subscriptions for cameras and AI summary text
- OpenCV-based image handling
- Qt Location map views for robot telemetry

## Main Runtime Pieces

- `main.cpp`
  Creates the application, connects the backend objects, and loads the `CircleBarsUI` QML module.

- `datamanager.*`
  Owns the live JSON database and file watching behavior.

- `rosstreammanager.*`
  Owns optional ROS 2 camera and AI topic subscriptions.

- `systemmonitor.*`
  Reads CPU usage and battery status from Linux.

- `qml/`
  Contains the main dashboard pages and reusable QML components.

- `qml/monitor/`
  Contains the operator monitor page, camera cards, map card, AI panel, and traffic panel.

## Important Notes Before Yocto Packaging

- The app currently uses an absolute default database path:
  `/media/abso/project/database/monitor_app`

- The launcher created in the sample Yocto recipe changes the runtime default to:
  `/var/lib/traffic-robot-app`

- The app uses QML imports such as `QtQuick.Controls`, `QtLocation`, `QtPositioning`, `QtQuick.Effects`, and `QtQuick.Shapes`, so the target image must include the matching Qt 6 runtime modules.

- The current source tree contains local/generated artifacts in the development workspace. The source snapshot for Yocto should exclude build products and editor files.

## Suggested Next Step

1. Copy or sync the clean app sources into `source/`.
2. Add `meta-tr` to `BBLAYERS`.
3. Make sure `meta-qt6` is already available.
4. Build `traffic-robot-app` with BitBake.
5. Validate runtime QML imports on the target image.
