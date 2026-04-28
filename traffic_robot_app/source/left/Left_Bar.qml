import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes

Item {

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 12

        // ===================== TEMPERATURE =====================
        HudPanel {
            borderColor: "#ffad33"
            Layout.fillWidth: true
            Layout.preferredHeight: 180

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 20
                spacing: 20

                ColumnLayout {
                    spacing: 5
                    Layout.margins: 20
                    Layout.alignment: Qt.AlignVCenter
                    Text {
                        text: "TEMPERATURE"
                        color: "white"
                        font.pixelSize: 18
                        font.bold: true
                        font.letterSpacing: 2
                    }

                    Text {
                        text: "24.5°C"
                        color: "#ffad33"
                        font.pixelSize: 56
                        font.bold: true
                    }

                    Rectangle {
                        Layout.preferredWidth: 180
                        Layout.preferredHeight: 12
                        color: "#ffad33"
                        radius: 2
                    }

                    Rectangle {
                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 4
                        color: "#ffad33"
                        opacity: 0.4
                        radius: 2
                    }
                }

                Item { Layout.fillWidth: true }

                ArcGauge {
                    size: 110
                    strokeColor: "white"
                    centerIcon: "▲▲"
                    iconColor: "#33ccff"
                }
            }
        }

        // ===================== SENSOR =====================
                HudPanel {
                    borderColor: "#33ccff"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 25
                        spacing: 20

                        // LEFT CIRCLE (100% GAUGE)
                        Item {
                            Layout.alignment: Qt.AlignVCenter
                            width: 130
                            height: 130

                            // Double-ring effect seen in reference UI
                            Shape {
                                anchors.fill: parent
                                ShapePath {
                                    strokeColor: "#4dff4d"
                                    strokeWidth: 9 // Thicker main ring
                                    fillColor: "transparent"
                                    capStyle: ShapePath.FlatCap
                                    PathAngleArc {
                                        centerX: 65; centerY: 65; radiusX: 55; radiusY: 55
                                        startAngle: 0; sweepAngle: 360
                                    }
                                }
                                // Subtle inner decorative ring
                                ShapePath {
                                    strokeColor: "#4dff4d"
                                    strokeWidth: 2
                                    fillColor: "transparent"
                                    PathAngleArc {
                                        centerX: 65; centerY: 65; radiusX: 45; radiusY: 45
                                        startAngle: 0; sweepAngle: 360
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "100%"
                                color: "#4dff4d"
                                font.pixelSize: 28
                                font.bold: true
                                font.family: "Orbitron" // Or a similar HUD-style font
                            }
                        }

                        Item { Layout.fillWidth: true } // Spacer to push gauges to edges

                        // RIGHT GAUGE (28 ARC)
                        ColumnLayout {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 12

                            // The Arc with the specific bottom opening
                            ArcGauge {
                                Layout.alignment: Qt.AlignHCenter
                                size: 120
                                strokeColor: "white"
                                centerText: "28"
                                textColor: "#33ccff"
                                // Ensure ArcGauge component uses startAngle: 135, sweepAngle: 270
                                // to create the bottom gap seen in images
                            }

                            // Layered blue progress bars
                            Column {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 5
                                Rectangle {
                                    width: 110
                                    height: 14
                                    color: "#33ccff"
                                    radius: 1
                                }
                                Rectangle {
                                    width: 75
                                    height: 5
                                    color: "#33ccff"
                                    opacity: 0.4
                                    radius: 1
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                }
        // ===================== HEALTH =====================
        HudPanel {
            borderColor: "#4dff4d"
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 25
                spacing: 12

                Text {
                    text: "SYSTEM HEALTH"
                    color: "white"
                    font.pixelSize: 22
                    font.bold: true
                }

                HealthLine { label: "STABLE" }
                HealthLine { label: "OPTICAL ARRAY" }
                HealthLine { label: "OPTICAL ARRAY NORMAL" }
                HealthLine { label: "OPTIMAL" }
            }

            // Battery
            Rectangle {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 20

                width: 45
                height: 22
                color: "transparent"
                border.color: "#4dff4d"
                border.width: 2
                radius: 3

                Rectangle {
                    x: 4
                    y: 4
                    width: 25
                    height: 14
                    color: "#4dff4d"
                }
            }
        }
    }

    // ===================== COMPONENTS =====================

    component HudPanel : Rectangle {
        property color borderColor: "white"

        color: "#32383f"
        border.color: borderColor
        border.width: 2
        radius: 15

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: borderColor
            shadowBlur: 0.4
        }
    }

    component ArcGauge : Item {
        property int size: 100
        property color strokeColor: "white"
        property string centerText: ""
        property string centerIcon: ""
        property color textColor: "white"
        property color iconColor: "white"

        width: size
        height: size

        Shape {
            anchors.fill: parent

            ShapePath {
                strokeColor: strokeColor
                strokeWidth: 5
                fillColor: "transparent"

                PathAngleArc {
                    centerX: size / 2
                    centerY: size / 2
                    radiusX: size / 2 - 10
                    radiusY: size / 2 - 10
                    startAngle: 140
                    sweepAngle: 260
                }
            }
        }

        Repeater {
            model: 12

            Rectangle {
                width: 2
                height: 8
                color: "#33ccff"
                opacity: 0.6

                x: size / 2 - 1
                y: -10

                transformOrigin: Item.Bottom

                transform: [
                    Translate { y: size / 2 },
                    Rotation { angle: 140 + (index * 23.6) }
                ]
            }
        }

        Text {
            anchors.centerIn: parent
            text: centerText
            color: textColor
            font.pixelSize: 28
            font.bold: true
        }

        Text {
            anchors.centerIn: parent
            text: centerIcon
            color: iconColor
            font.pixelSize: 18
            visible: centerIcon !== ""
        }
    }

    component HealthLine : RowLayout {
        property string label: ""
        spacing: 10

        Text {
            text: "✓"
            color: "#4dff4d"
            font.pixelSize: 18
            font.bold: true
        }

        Text {
            text: label
            color: "#4dff4d"
            font.pixelSize: 16
            font.letterSpacing: 1
            Layout.fillWidth: true
        }
    }

}
