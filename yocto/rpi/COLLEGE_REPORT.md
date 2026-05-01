# College Report: Yocto RPi Subdirectory

## 1. Introduction

This subdirectory represents the Raspberry Pi-specific area under the project-side Yocto folder.

## 2. Purpose

Its purpose is to provide a clear place for:

- Raspberry Pi build notes
- image-specific project records
- future RPi-side Yocto integration material

## 3. Relationship To The Main Build Trees

This subdirectory should be understood together with the active external Yocto build directories:

- `/media/abso/yocto/scarthgap/rpi`
- `/media/abso/yocto/scarthgap/rpi5`

The external trees contain the actual build configuration and outputs.

This project-side folder is a documentation and organization anchor.

## 4. Academic Usefulness

From a college report point of view, this subdirectory shows that the repository is organized with deployment in mind, not only with source code in mind.

## 5. Conclusion

Even though it is currently small, this subdirectory supports the overall structure of the embedded Linux side of the project.

## 6. Code Example And How To Use It

Example of Raspberry Pi image customization:

```conf
MACHINE ??= "rpi-extra"
IMAGE_INSTALL:append = " ros-base turtlesim"
IMAGE_INSTALL:append = " i2c-tools"
```

How to use it:

- `MACHINE` selects the board configuration
- `IMAGE_INSTALL:append` adds packages into the final image

Practical meaning:

- this is the level where a project image becomes customized for Raspberry Pi deployment

## 7. Detailed Walkthrough

This subdirectory currently acts more like a project-side placeholder than a full source folder.

That still has value.

It can become the place for:

- RPi-specific deployment notes
- image manifests
- target validation logs
- test summaries after flashing images

For a student team, this kind of structure helps keep platform-side information separate from application logic.
