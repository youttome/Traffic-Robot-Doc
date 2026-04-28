# Yocto `meta-tr` Integration Guide For Traffic AI Model

This guide explains how to integrate the Python traffic AI service into the provided Yocto layer folder:

`traffic_ai_model/meta-tr`

To avoid collision with the separate Qt app starter layer, this AI bundle uses the unique Yocto layer collection name:

`meta-tr-traffic-ai`

## 1. What Was Added

This bundle now includes:

- `meta-tr/conf/layer.conf`
- `meta-tr/README.md`
- `meta-tr/recipes-traffic/traffic-ai-model/traffic-ai-model.bb`

The recipe is written as a development-oriented first pass and expects the staged source at:

`/media/abso/yocto/traffic_robot/traffic_ai_model/source`

## 2. Why This Approach

The current request was to place the AI model work directly inside the Yocto project tree. For that reason, the recipe uses `externalsrc`, which is a good fit for active local development.

The service is not yet converted into a standard Python package with `setup.py` or `pyproject.toml`, so the first-pass recipe installs the source bundle directly and launches `finish.py`.

## 3. Required Yocto Layers

At minimum, the build should already include:

- `meta`
- `meta-poky`
- your BSP layers
- this new `meta-tr`

Additional Python or ML layers may still be needed depending on how you choose to package:

- OpenCV
- NumPy
- Pillow
- PaddleOCR stack
- Ultralytics / PyTorch runtime support

Those dependencies are highly distro-specific, so the starter recipe keeps the package metadata intentionally conservative.

## 4. Add `meta-tr` To `BBLAYERS`

In your Yocto build directory:

```bash
bitbake-layers add-layer /media/abso/yocto/traffic_robot/traffic_ai_model/meta-tr
```

If you edit `conf/bblayers.conf` manually, add:

```conf
BBLAYERS += " /media/abso/yocto/traffic_robot/traffic_ai_model/meta-tr "
```

## 5. Source Snapshot Expectations

The staged `source/` folder already contains:

- `finish.py`
- `detectors/`
- `ocr/`
- `tracker/`
- `utils/`
- `models/`
- emergency detector ONNX weight
- `requirements*.txt`
- existing readme files

The snapshot intentionally omits:

- `.git`
- `.vscode`
- `__pycache__`
- live `exports/`
- live `uploads/`

## 6. Runtime Output Path

One packaging issue was addressed in the staged snapshot.

The original service wrote `exports/` and `uploads/` next to `finish.py`. That is not appropriate for a read-only installed location on an embedded image.

The staged `finish.py` now supports:

- `TRAFFIC_AI_RUNTIME_DIR`
- `TRAFFIC_AI_EXPORT_DIR`
- `TRAFFIC_AI_UPLOAD_DIR`

The sample launcher sets:

`TRAFFIC_AI_RUNTIME_DIR=/var/lib/traffic-ai-model`

## 7. Build The Recipe

To build only the application package:

```bash
bitbake traffic-ai-model
```

To include it in an image, add:

```conf
IMAGE_INSTALL:append = " traffic-ai-model"
```

Then build your image recipe.

## 8. What The Recipe Does

The included recipe:

- uses `externalsrc` with the staged local source
- skips compile/configure because the app is a Python runtime tree
- installs the runtime source into `/usr/share/traffic-ai-model`
- creates `/var/lib/traffic-ai-model`
- adds a helper launcher named `traffic-ai-model`

That launcher means you can start the service on target with a command such as:

```bash
traffic-ai-model --sources 0 1
```

## 9. Likely Follow-Up Work

The first build will likely still need adjustments for the exact Yocto distro and board.

Most likely follow-ups are:

- add final package dependencies for Python CV/ML libraries
- decide whether models remain bundled or move to a separate package
- create a systemd service if the AI should auto-start
- validate camera permissions and `/dev/video*` access on target
- validate writable storage capacity for snapshots and reports

## 10. Recommended Production Upgrade Path

The included recipe is good for local development, but a production path should eventually:

1. move the AI service to its own Git repository or release tarball
2. replace `externalsrc` with a fixed `SRC_URI`
3. pin the exact revision or release artifact
4. formalize Python dependency packaging
5. consider splitting large model assets into their own package or image feature

## 11. Operational Notes

- The service expects exactly two sources.
- `cam0` maps to `ROAD_1`.
- `cam1` maps to `ROAD_2`.
- The external traffic-light logic must use the same `SIGNAL_REFERENCE_EPOCH` as the AI service.
- The main controller integration file remains `exports/emergency_request.txt`.
