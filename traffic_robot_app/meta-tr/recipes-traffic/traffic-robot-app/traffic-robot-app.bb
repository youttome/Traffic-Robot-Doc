SUMMARY = "Traffic robot Qt6/QML monitoring dashboard"
DESCRIPTION = "Qt 6 + QML operator dashboard with JSON-backed telemetry and optional ROS 2 stream integration."
HOMEPAGE = "local"
LICENSE = "CLOSED"

inherit qt6-cmake pkgconfig externalsrc

DEPENDS += "qtbase qtdeclarative qtlocation qtpositioning qt5compat opencv"

EXTERNALSRC ?= "/media/abso/yocto/traffic_robot/traffic_robot_app/source"
EXTERNALSRC_BUILD ?= "${WORKDIR}/build"

S = "${EXTERNALSRC}"
B = "${EXTERNALSRC_BUILD}"

OECMAKE_GENERATOR = "Ninja"

do_install:append() {
    install -d ${D}${bindir}
    install -d ${D}/var/lib/traffic-robot-app

    cat <<'EOF' > ${D}${bindir}/traffic-robot-app
#!/bin/sh
export MONITOR_APP_DB_PATH="${MONITOR_APP_DB_PATH:-/var/lib/traffic-robot-app}"
exec /usr/bin/appCircleBarsUI "$@"
EOF

    chmod 0755 ${D}${bindir}/traffic-robot-app
}

FILES:${PN} += " \
    ${bindir}/traffic-robot-app \
    /var/lib/traffic-robot-app \
"
