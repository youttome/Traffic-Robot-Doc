# College Report: Traffic AI Model Directory

## 1. Introduction

This directory contains the AI traffic-monitoring part of the project.

Its purpose is to detect:

- vehicles
- traffic violations
- emergency vehicles
- license plates
- road-open requests for emergency priority

## 2. Directory Purpose

The `traffic_ai_model` directory is the smart-intersection intelligence side of the project.

It is different from the robot follow-me ROS stack.

Its job is not mainly robot movement.

Its main job is traffic analysis from two camera streams.

## 3. Main Files

- `README.md`
- `PROJECT_REPORT.md`
- `NODE_REFERENCE.md`
- `FILE_REFERENCE.md`
- `TASKS.md`
- `YOCTO_META_TR_GUIDE.md`
- `meta-tr/`
- `source/`

## 4. Main Runtime Idea

The AI model expects exactly two sources.

It maps:

- `cam0` to one road
- `cam1` to another road

It then performs:

- detection
- tracking
- speed estimation
- red-light logic
- OCR on important cases
- emergency-vehicle handling

## 5. Main Strengths

- focused two-camera design
- selective OCR instead of wasteful OCR on every frame
- emergency request arbitration across both camera threads
- structured runtime outputs
- good separation between model logic and Yocto packaging notes

## 6. Main Runtime Outputs

The AI service generates:

- CSV traffic reports
- session summaries
- plate logs
- emergency snapshots
- emergency road-open request file

The most important integration file is:

- `exports/emergency_request.txt`

## 7. Academic Importance

This folder is valuable for a college submission because it shows:

- practical computer vision pipeline design
- use of object detection and OCR together
- event-driven data extraction
- multi-camera reasoning
- safety and emergency-oriented system behavior

## 8. Engineering Value

The AI model is not just a proof of concept.

It already reflects real embedded design decisions:

- reduce compute cost
- avoid unnecessary OCR
- isolate controller handoff through a simple file interface
- use a shared signal reference epoch

## 9. Deployment Value

This directory is also important because it already includes:

- a staged source snapshot
- a Yocto layer skeleton
- recipe guidance
- runtime path notes

That makes it easier to move from development to deployment.

## 10. Educational Lessons

Students studying this folder can learn:

- how to break AI logic into stages
- how to connect detection, tracking, and OCR
- how to design outputs for downstream systems
- how to prepare AI software for embedded packaging

## 11. Relationship To Other Folders

This directory connects to:

- `iot` through future bridges and monitoring
- `configuration` through Yocto package integration
- `traffic_robot_app` through future UI-facing data paths

## 12. Conclusion

The `traffic_ai_model` folder is the analytic intelligence engine of the project.

For a college report, it strongly supports the claim that the system includes real AI engineering and not just interface design.

## 13. Code Example And How To Use It

Example from [finish.py](/media/abso/yocto/traffic_robot/traffic_ai_model/source/finish.py):

```python
RUNTIME_DIR = os.path.abspath(os.getenv("TRAFFIC_AI_RUNTIME_DIR", BASE_DIR))
UPLOAD_DIR = os.path.abspath(os.getenv("TRAFFIC_AI_UPLOAD_DIR", os.path.join(RUNTIME_DIR, "uploads")))
EXPORT_DIR = os.path.abspath(os.getenv("TRAFFIC_AI_EXPORT_DIR", os.path.join(RUNTIME_DIR, "exports")))
EMERGENCY_REQUEST_FILE = os.path.join(EXPORT_DIR, "emergency_request.txt")
```

How to use it:

- set `TRAFFIC_AI_RUNTIME_DIR` if you want the service outputs outside the source tree
- use `TRAFFIC_AI_EXPORT_DIR` to control where emergency and report files are written

Practical run example:

```bash
export TRAFFIC_AI_RUNTIME_DIR=/tmp/traffic-ai-runtime
python3 finish.py --sources 0 1
```

## 14. Detailed Walkthrough

The AI model directory contains both documentation and staged runtime packaging, so a reader should think of it in two parts:

Part 1:

- documentation and reports
- these explain the system and packaging strategy

Part 2:

- source and recipe references
- these show how the service actually runs and how it reaches the target image

Important design idea:

- the AI service is not only an object detector
- it is an event-producing system

It performs:

- detection
- tracking
- timing logic
- OCR
- emergency logic
- report generation

The best way to use this directory is:

1. read the report
2. inspect `source/finish.py`
3. inspect the recipe under `meta-tr`
4. run the service with two sources
5. inspect generated outputs under the runtime export path
