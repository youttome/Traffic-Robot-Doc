# College Report: Yocto Directory

## 1. Introduction

This directory is the Yocto-focused area inside the project repository.

At the moment it is small, but it still matters because it marks the embedded build side of the project structure.

## 2. Purpose

The purpose of this folder is to keep Yocto-related material near the project documentation.

It helps separate:

- application folders
- AI folders
- IoT documentation
- build-side notes

## 3. Current Structure

The currently visible subdirectory is:

- `rpi`

This shows that the project intends to keep Raspberry Pi build-side structure under this area.

## 4. Academic Value

Even when small, this directory is useful in a college context because it signals:

- deployment planning
- target-platform awareness
- repository organization discipline

## 5. Role In The Full Project

This folder should be seen as the place where build-specific project-side Yocto notes and artifacts can live.

It complements the larger external build trees under:

- `/media/abso/yocto/scarthgap/rpi`
- `/media/abso/yocto/scarthgap/rpi5`

## 6. Conclusion

The `yocto` directory is a structural placeholder for build-side material and shows that the team thinks about deployment organization as part of the project.

## 7. Code Example And How To Use It

Example of the kind of build configuration this project depends on:

```conf
BBLAYERS ?= " \
  /media/abso/yocto/scarthgap/meta \
  /media/abso/yocto/scarthgap/meta-raspberrypi \
  /media/abso/yocto/scarthgap/meta-rt \
"
```

How to use it:

- `BBLAYERS` selects which Yocto metadata layers are active
- without the correct layers, board support and custom recipes will not build

## 8. Detailed Walkthrough

This directory is small, so its value is mostly structural and educational.

It reminds the reader that the project is not only:

- source code
- or documentation

It is also:

- build-system aware
- deployment aware

In practice, the real active build trees live elsewhere, but this folder still helps the repository remain organized around embedded deployment ideas.
