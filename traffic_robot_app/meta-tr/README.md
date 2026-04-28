# `meta-tr` Layer

This is a starter Yocto layer for packaging the Traffic Robot Qt/QML operator dashboard.

## Contents

- `conf/layer.conf`
  Layer registration and recipe discovery.

- `recipes-traffic/traffic-robot-app/traffic-robot-app.bb`
  First-pass application recipe for the dashboard.

## Intended Source Location

The current recipe expects the source tree at:

`/media/abso/yocto/traffic_robot/traffic_robot_app/source`

That is a development-friendly layout using `externalsrc`.

## Main Usage

Add the layer:

```bash
bitbake-layers add-layer /media/abso/yocto/traffic_robot/traffic_robot_app/meta-tr
```

Build the package:

```bash
bitbake traffic-robot-app
```

Install it into an image:

```conf
IMAGE_INSTALL:append = " traffic-robot-app"
```

## Notes

- This layer is a first-pass integration skeleton, not a final production release layer.
- For a release build, replace the local-source `externalsrc` flow with a reproducible Git or tarball source.
