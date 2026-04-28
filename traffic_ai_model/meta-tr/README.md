# `meta-tr` Layer For Traffic AI Model

This is a starter Yocto layer for packaging the Python traffic AI service.

Layer collection name:

`meta-tr-traffic-ai`

## Contents

- `conf/layer.conf`
  Layer registration and recipe discovery.

- `recipes-traffic/traffic-ai-model/traffic-ai-model.bb`
  First-pass application recipe for the traffic AI service.

## Intended Source Location

The current recipe expects the source tree at:

`/media/abso/yocto/traffic_robot/traffic_ai_model/source`

That is a development-friendly layout using `externalsrc`.

## Main Usage

Add the layer:

```bash
bitbake-layers add-layer /media/abso/yocto/traffic_robot/traffic_ai_model/meta-tr
```

Build the package:

```bash
bitbake traffic-ai-model
```

Install it into an image:

```conf
IMAGE_INSTALL:append = " traffic-ai-model"
```

## Notes

- This is a first-pass integration skeleton, not a final production release layer.
- Final Python ML dependency packaging will depend on the exact Yocto distro and target BSP.
