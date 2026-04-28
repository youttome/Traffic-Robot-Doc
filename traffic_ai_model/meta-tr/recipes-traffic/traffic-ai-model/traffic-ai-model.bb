SUMMARY = "Traffic AI model multi-camera monitoring service"
DESCRIPTION = "Python traffic-monitoring service with YOLO vehicle, plate, and emergency detection plus OCR and central road-open signaling."
HOMEPAGE = "local"
LICENSE = "CLOSED"

inherit externalsrc

RDEPENDS:${PN} += " \
    bash \
    python3-core \
    python3-modules \
"

EXTERNALSRC ?= "/media/abso/yocto/traffic_robot/traffic_ai_model/source"
EXTERNALSRC_BUILD ?= "${WORKDIR}/build"

S = "${EXTERNALSRC}"
B = "${EXTERNALSRC_BUILD}"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${datadir}/traffic-ai-model
    install -d ${D}${datadir}/traffic-ai-model/detectors
    install -d ${D}${datadir}/traffic-ai-model/ocr
    install -d ${D}${datadir}/traffic-ai-model/tracker
    install -d ${D}${datadir}/traffic-ai-model/utils
    install -d ${D}${datadir}/traffic-ai-model/models
    install -d ${D}${datadir}/traffic-ai-model/runs/detect/runs/emergency_detector/weights

    install -m 0644 ${S}/finish.py ${D}${datadir}/traffic-ai-model/
    install -m 0644 ${S}/README.md ${D}${datadir}/traffic-ai-model/
    install -m 0644 ${S}/README.txt ${D}${datadir}/traffic-ai-model/
    install -m 0644 ${S}/requirements.txt ${D}${datadir}/traffic-ai-model/
    install -m 0644 ${S}/requirements-rpi.txt ${D}${datadir}/traffic-ai-model/

    cp -R --no-preserve=ownership,mode ${S}/detectors/* ${D}${datadir}/traffic-ai-model/detectors/
    cp -R --no-preserve=ownership,mode ${S}/ocr/* ${D}${datadir}/traffic-ai-model/ocr/
    cp -R --no-preserve=ownership,mode ${S}/tracker/* ${D}${datadir}/traffic-ai-model/tracker/
    cp -R --no-preserve=ownership,mode ${S}/utils/* ${D}${datadir}/traffic-ai-model/utils/
    cp -R --no-preserve=ownership,mode ${S}/models/* ${D}${datadir}/traffic-ai-model/models/
    install -m 0644 ${S}/runs/detect/runs/emergency_detector/weights/best.onnx \
        ${D}${datadir}/traffic-ai-model/runs/detect/runs/emergency_detector/weights/best.onnx

    install -d ${D}${bindir}
    install -d ${D}/var/lib/traffic-ai-model

    cat <<'EOF' > ${D}${bindir}/traffic-ai-model
#!/bin/sh
APP_DIR=/usr/share/traffic-ai-model
export TRAFFIC_AI_RUNTIME_DIR="${TRAFFIC_AI_RUNTIME_DIR:-/var/lib/traffic-ai-model}"
exec python3 ${APP_DIR}/finish.py "$@"
EOF

    chmod 0755 ${D}${bindir}/traffic-ai-model
}

FILES:${PN} += " \
    ${bindir}/traffic-ai-model \
    ${datadir}/traffic-ai-model \
    /var/lib/traffic-ai-model \
"
