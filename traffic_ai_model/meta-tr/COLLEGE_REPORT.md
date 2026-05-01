# College Report: Traffic AI Yocto Layer

## 1. Introduction

This directory contains the Yocto layer skeleton for packaging the traffic AI model.

It represents the deployment metadata side of the AI service.

## 2. Directory Purpose

The purpose of this folder is to transform the AI source code into a Yocto-manageable package.

It contains:

- layer metadata
- recipe placement
- a structure compatible with Yocto layer conventions

## 3. Why This Matters

In a college project, many teams stop at source code.

This folder shows the next engineering step:

- preparing the AI system for reproducible embedded integration

That is a strong systems-engineering contribution.

## 4. Main Educational Value

Students can learn:

- what a custom layer is
- how recipes are organized
- how local application code becomes a target package
- why deployment metadata matters

## 5. Main Role In The Full Project

This folder connects:

- AI source code
- Yocto build system
- final Raspberry Pi image integration

## 6. Conclusion

This directory is small, but it represents a professional deployment mindset.

For a college report, it demonstrates maturity beyond algorithm development.

## 7. Code Example And How To Use It

Example from the AI Yocto recipe:

```bitbake
inherit externalsrc

EXTERNALSRC ?= "/media/abso/yocto/traffic_robot/traffic_ai_model/source"
EXTERNALSRC_BUILD ?= "${WORKDIR}/build"
```

How to use it:

- `externalsrc` makes Yocto build directly from a local development tree
- `EXTERNALSRC` points to the AI source folder

Practical use:

- add the layer to `BBLAYERS`
- run `bitbake traffic-ai-model`
- Yocto will package the local source directory

## 8. Detailed Walkthrough

This Yocto layer exists to answer one important deployment question:

- how does the AI source become a target package?

The recipe does that by:

- pointing to the live source tree
- installing Python files and model assets
- creating a launcher command

Important launcher idea from the recipe:

```sh
APP_DIR=/usr/share/traffic-ai-model
export TRAFFIC_AI_RUNTIME_DIR="${TRAFFIC_AI_RUNTIME_DIR:-/var/lib/traffic-ai-model}"
exec python3 ${APP_DIR}/finish.py "$@"
```

Meaning:

- source files are installed under `/usr/share`
- runtime writable data is expected under `/var/lib`
- the final command exposed to the user is `traffic-ai-model`

This is a good embedded packaging pattern because it separates:

- read-only application files
- writable runtime state
