# College Report: Traffic AI Source Directory

## 1. Introduction

This directory contains the staged runtime source code for the traffic AI service.

It is the code that performs the actual traffic analysis logic.

## 2. Purpose

The source folder holds:

- Python runtime code
- model wrappers
- OCR utilities
- tracking utilities
- packaged model assets

## 3. Main Important Files

- `finish.py`
- `detectors/vehicle_detector.py`
- `detectors/plate_detector.py`
- `ocr/ocr_reader.py`
- `tracker/centroid_tracker.py`
- `utils/config.py`
- `utils/pre_process.py`
- `utils/speed_estimator.py`

## 4. Main Runtime Flow

The source code implements:

- source parsing
- camera loop startup
- emergency detection
- traffic signal reasoning
- vehicle tracking
- speed estimation
- violation detection
- OCR for selected events

## 5. Academic Value

This folder is important academically because it contains the actual AI logic, not only documentation.

It lets a reader study:

- algorithm ordering
- control of runtime state
- event-driven data logging
- practical AI system decomposition

## 6. Engineering Strengths

- focused single entry point
- modular helper files
- event-driven OCR instead of always-on OCR
- explicit output handling

## 7. Conclusion

This directory is the implementation core of the traffic AI project and provides the strongest evidence of applied computer vision work in the repository.

## 8. Code Example And How To Use It

Example from [finish.py](/media/abso/yocto/traffic_robot/traffic_ai_model/source/finish.py):

```python
def build_arg_parser():
    parser = argparse.ArgumentParser(description="Multi-camera traffic monitor with OCR for Raspberry Pi")
    parser.add_argument(
        "--sources",
        nargs="+",
        required=True,
        help='Exactly two sources. Example: --sources 0 1 OR --sources "0,1"',
    )
    return parser
```

How to use it:

- the program requires exactly two input sources
- these can be camera indexes or equivalent sources supported by the runtime

Practical examples:

```bash
python3 finish.py --sources 0 1
python3 finish.py --sources "0,1"
```

## 9. Detailed Walkthrough

The source code can be understood in four main stages.

Stage 1: configuration and startup

- environment variables are loaded
- runtime paths are prepared
- shared constants are defined

Stage 2: shared system logic

- emergency request file writing
- multi-camera arbitration
- signal timing support

Example:

```python
def write_central_request_payload(road_name: str | None):
    road_code_map = {
        None: "0",
        "NONE": "0",
        "ROAD_1": "1",
        "ROAD_2": "2",
    }
```

Meaning:

- the system converts internal road names to a simple external controller value
- this keeps downstream traffic-light integration easy

Stage 3: per-camera processing

- detection
- tracking
- speed estimation
- OCR and logging

Stage 4: final service startup

- parse two sources
- create processors
- run worker threads

This structure is good for learning because it shows how a large AI file can still be divided conceptually into understandable parts.
