import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes

Item {
    id: root

    property real scaleW: width / 400
    property real scaleH: height / 820
    property real scale: Math.min(scaleW, scaleH)

    readonly property var systemHealthData: dataManager.systemHealth || ({})
    readonly property var telemetryData: dataManager.robotTelemetry || ({})
    readonly property int batteryLevel: systemHealthData.battery !== undefined
        ? Number(systemHealthData.battery)
        : 0
    readonly property int temperature: systemHealthData.temperature !== undefined
        ? Number(systemHealthData.temperature)
        : 25
    readonly property int memoryUsage: systemHealthData.memoryUsage !== undefined
        ? Number(systemHealthData.memoryUsage)
        : 0
    readonly property int confidenceValue: telemetryData.confidence !== undefined
        ? Number(telemetryData.confidence)
        : 0
    readonly property int missionProgress: telemetryData.progress !== undefined
        ? Number(telemetryData.progress)
        : 0
    readonly property real speedValue: telemetryData.speedKph !== undefined
        ? Number(telemetryData.speedKph)
        : 0
    readonly property int etaValue: telemetryData.etaSeconds !== undefined
        ? Number(telemetryData.etaSeconds)
        : 0
    readonly property var alertList: telemetryData.alerts || []

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        HudPanel {
            borderColor: "#57d7ff"
            Layout.fillWidth: true
            Layout.preferredHeight: 210

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text: "ROBOT MISSION"
                            color: "#8fe9ff"
                            font.pixelSize: Math.max(14, 18 * root.scale)
                            font.bold: true
                            font.letterSpacing: 1.1
                        }

                        Text {
                            text: telemetryData.status !== undefined ? telemetryData.status : "Standby"
                            color: "white"
                            font.pixelSize: Math.max(16, 24 * root.scale)
                            font.bold: true
                        }
                    }

                    Rectangle {
                        radius: 10
                        color: telemetryData.movementState === "MOVING" ? "#17351f" : "#382610"
                        border.color: telemetryData.movementState === "MOVING" ? "#39ff9c" : "#ffb347"
                        border.width: 1
                        implicitWidth: 96
                        implicitHeight: 30

                        Text {
                            anchors.centerIn: parent
                            text: telemetryData.movementState !== undefined ? telemetryData.movementState : "READY"
                            color: parent.border.color
                            font.pixelSize: Math.max(10, 11 * root.scale)
                            font.bold: true
                        }
                    }
                }

                Text {
                    text: (telemetryData.targetZone !== undefined ? telemetryData.targetZone : "No target selected")
                        + "  |  "
                        + (telemetryData.routeState !== undefined ? telemetryData.routeState : "Route pending")
                    color: "#9ab4c8"
                    font.pixelSize: Math.max(10, 12 * root.scale)
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: "#122231"

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, root.missionProgress / 100))
                        height: parent.height
                        radius: 4
                        color: "#39ff9c"
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    DataChip { label: "SPEED"; value: root.speedValue.toFixed(1) + " km/h" }
                    DataChip { label: "ETA"; value: root.etaValue + " s" }
                    DataChip { label: "LINK"; value: root.confidenceValue + "%" }
                }

                Text {
                    text: "MISSION PROGRESS " + root.missionProgress + "%  |  MODE " +
                        (telemetryData.autonomyMode !== undefined ? telemetryData.autonomyMode : "AUTO")
                    color: "#dbe9f4"
                    font.pixelSize: Math.max(10, 12 * root.scale)
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: root.alertList.length > 0 ? Math.min(2, root.alertList.length) : 1

                        delegate: Rectangle {
                            required property int index

                            radius: 9
                            color: "#111f2d"
                            border.color: "#28445a"
                            border.width: 1
                            height: 28
                            width: Math.min(root.width - 60, alertText.implicitWidth + 18)

                            Text {
                                id: alertText
                                anchors.centerIn: parent
                                text: root.alertList.length > 0 ? root.alertList[index] : "Battery nominal"
                                color: "white"
                                font.pixelSize: Math.max(9, 10 * root.scale)
                            }
                        }
                    }
                }
            }
        }

        HudPanel {
            borderColor: "#ffad33"
            Layout.fillWidth: true
            Layout.preferredHeight: 130

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                ColumnLayout {
                    spacing: 5
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: "THERMAL CORE"
                        color: "white"
                        font.pixelSize: Math.max(12, 15 * root.scale)
                        font.bold: true
                    }

                    Text {
                        text: root.temperature + " degC"
                        color: "#ffad33"
                        font.pixelSize: Math.max(18, 30 * root.scale)
                        font.bold: true
                    }

                    Rectangle {
                        width: 180
                        height: 6
                        color: "#281a10"
                        radius: 3

                        Rectangle {
                            width: parent.width * Math.max(0.15, Math.min(1, root.temperature / 100))
                            height: parent.height
                            color: "#ffad33"
                            radius: 3
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                ColumnLayout {
                    spacing: 4
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: "ENGINE LOAD"
                        color: "#ffddb0"
                        font.pixelSize: Math.max(10, 11 * root.scale)
                        font.bold: true
                    }

                    Text {
                        text: "CPU " + (systemHealthData.cpuUsage !== undefined ? systemHealthData.cpuUsage : 0) + "%"
                        color: "white"
                        font.pixelSize: Math.max(12, 13 * root.scale)
                    }

                    Text {
                        text: "MEM " + root.memoryUsage + "%"
                        color: "white"
                        font.pixelSize: Math.max(12, 13 * root.scale)
                    }
                }
            }
        }

        HudPanel {
            borderColor: "#33ccff"
            Layout.fillWidth: true
            Layout.preferredHeight: 175

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 14

                Item {
                    Layout.alignment: Qt.AlignVCenter
                    width: 110
                    height: 110

                    Shape {
                        anchors.fill: parent

                        ShapePath {
                            strokeColor: "#173247"
                            strokeWidth: 10
                            fillColor: "transparent"

                            PathAngleArc {
                                centerX: width / 2
                                centerY: height / 2
                                radiusX: 42
                                radiusY: 42
                                startAngle: 0
                                sweepAngle: 360
                            }
                        }

                        ShapePath {
                            strokeColor: "#4dff4d"
                            strokeWidth: 10
                            fillColor: "transparent"

                            PathAngleArc {
                                centerX: width / 2
                                centerY: height / 2
                                radiusX: 42
                                radiusY: 42
                                startAngle: -90
                                sweepAngle: 360 * Math.max(0, Math.min(1, root.batteryLevel / 100))
                            }
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.batteryLevel + "%"
                            color: "#4dff4d"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "BATTERY"
                            color: "#7fe7ff"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8

                    Text {
                        text: "MISSION LINK"
                        color: "white"
                        font.pixelSize: Math.max(14, 18 * root.scale)
                        font.bold: true
                    }

                    StatusRow { label: "Signal"; value: telemetryData.signalQuality !== undefined ? telemetryData.signalQuality : "Stable" }
                    StatusRow { label: "Mission"; value: telemetryData.missionTime !== undefined ? telemetryData.missionTime : "--:--:--" }
                    StatusRow { label: "Heading"; value: telemetryData.headingLabel !== undefined ? telemetryData.headingLabel : "N" }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: "#102130"

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(1, root.confidenceValue / 100))
                            height: parent.height
                            radius: 3
                            color: "#33ccff"
                        }
                    }

                    Text {
                        text: "LINK CONFIDENCE " + root.confidenceValue + "%"
                        color: "#8fdfff"
                        font.pixelSize: Math.max(10, 11 * root.scale)
                    }
                }
            }
        }

        HudPanel {
            borderColor: "#4dff4d"
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22 * root.scale
                spacing: 12 * root.scale

                Text {
                    text: "SYSTEM HEALTH"
                    color: "white"
                    font.pixelSize: 22 * root.scale
                    font.bold: true
                }

                HealthLine { label: "STABLE" }
                HealthLine { label: "CPU " + (systemHealthData.cpuUsage !== undefined ? systemHealthData.cpuUsage : 0) + "%" }
                HealthLine { label: "MEMORY " + root.memoryUsage + "%" }
                HealthLine { label: "NETWORK " + (systemHealthData.network !== undefined ? systemHealthData.network : "--") }
                HealthLine { label: "TARGET " + (telemetryData.targetZone !== undefined ? telemetryData.targetZone : "--") }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 20 * root.scale

                width: 45 * root.scale
                height: 22 * root.scale
                color: "transparent"
                border.color: "#4dff4d"
                border.width: 2 * root.scale
                radius: 3 * root.scale

                Rectangle {
                    x: 4 * root.scale
                    y: 4 * root.scale
                    width: 25 * root.scale
                    height: 14 * root.scale
                    color: "#4dff4d"
                }
            }
        }
    }

    component HudPanel : Rectangle {
        property color borderColor: "white"

        color: "#32383f"
        border.color: borderColor
        border.width: 2 * root.scale
        radius: 15 * root.scale

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: borderColor
            shadowBlur: 0.4
        }
    }

    component HealthLine : RowLayout {
        property string label: ""
        spacing: 10 * root.scale

        Text {
            text: "✓"
            color: "#4dff4d"
            font.pixelSize: 18 * root.scale
            font.bold: true
        }

        Text {
            text: label
            color: "#4dff4d"
            font.pixelSize: 16 * root.scale
            Layout.fillWidth: true
        }
    }

    component DataChip : Rectangle {
        property string label: ""
        property string value: ""

        Layout.fillWidth: true
        implicitHeight: 42
        radius: 10
        color: "#111d2a"
        border.color: "#27445c"
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 2

            Text {
                text: label
                color: "#7da3be"
                font.pixelSize: Math.max(8, 9 * root.scale)
                font.bold: true
            }

            Text {
                text: value
                color: "white"
                font.pixelSize: Math.max(10, 11 * root.scale)
                font.bold: true
            }
        }
    }

    component StatusRow : RowLayout {
        property string label: ""
        property string value: ""
        spacing: 8

        Text {
            text: label.toUpperCase()
            color: "#7da3be"
            font.pixelSize: Math.max(9, 10 * root.scale)
            font.bold: true
        }

        Item { Layout.fillWidth: true }

        Text {
            text: value
            color: "white"
            font.pixelSize: Math.max(10, 11 * root.scale)
            font.bold: true
        }
    }
}
