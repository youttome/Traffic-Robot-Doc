import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    readonly property var telemetryData: dataManager.robotTelemetry || ({})
    readonly property var systemHealthData: dataManager.systemHealth || ({})
    readonly property string liveTimeText: telemetryData.statusLiveTime !== undefined
        ? telemetryData.statusLiveTime
        : "waiting..."

    Rectangle {
        anchors.fill: parent
        color: "#081018"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 26
        spacing: 18

        Rectangle {
            Layout.fillWidth: true
            radius: 18
            color: "#0b1320"
            border.color: "#57d7ff"
            border.width: 1
            implicitHeight: 120

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 8

                Text {
                    text: "OVERVIEW TARGET"
                    color: "#8fe9ff"
                    font.pixelSize: 28
                    font.bold: true
                }

                Text {
                    text: telemetryData.targetZone !== undefined ? telemetryData.targetZone : "Sector target"
                    color: "white"
                    font.pixelSize: 20
                    font.bold: true
                }

                Text {
                    text: "Database sync: " + dataManager.databasePath + "/robot_telemetry.json"
                    color: "#a8c1d4"
                    font.pixelSize: 12
                    elide: Text.ElideLeft
                    Layout.fillWidth: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16

            Rectangle {
                Layout.preferredWidth: 360
                Layout.fillHeight: true
                radius: 18
                color: "#0b1320"
                border.color: telemetryData.emergencyActive === true ? "#ff6b6b" : "#204155"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    Text {
                        text: "ROBOT STATUS"
                        color: "#8fe9ff"
                        font.pixelSize: 18
                        font.bold: true
                    }

                    StatusLine { label: "STATUS"; value: telemetryData.status || "Patrol Active" }
                    StatusLine { label: "MODE"; value: telemetryData.autonomyMode || "AUTO NAV" }
                    StatusLine { label: "MOVE"; value: telemetryData.movementState || "MOVING" }
                    StatusLine { label: "ROUTE"; value: telemetryData.routeState || "Route armed" }
                    StatusLine { label: "CAMERA"; value: "ROS2 live stream + recording active" }
                    StatusLine { label: "LIVE"; value: root.liveTimeText }

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 14
                        color: telemetryData.emergencyActive === true ? "#331012" : "#101b26"
                        border.color: telemetryData.emergencyActive === true ? "#ff6b6b" : "#2a455d"
                        border.width: 1
                        implicitHeight: 96

                        Column {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 6

                            Text {
                                text: telemetryData.emergencyActive === true ? "EMERGENCY STOP ACTIVE" : "MISSION LINK ACTIVE"
                                color: telemetryData.emergencyActive === true ? "#ff7d7d" : "#8fe9ff"
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Text {
                                width: parent.width
                                wrapMode: Text.WordWrap
                                color: "white"
                                font.pixelSize: 12
                                text: telemetryData.emergencyActive === true
                                    ? "Robot motion is stopped, speed is forced to zero, and the emergency state is being written live to robot_telemetry.json."
                                    : "Robot state, path target, and operator telemetry are synchronized live through the monitor JSON backend."
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 18
                color: "#09131e"
                border.color: "#173043"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    Text {
                        text: "SYSTEM EXPLANATION"
                        color: "#8fe9ff"
                        font.pixelSize: 18
                        font.bold: true
                    }

                    Text {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "white"
                        font.pixelSize: 14
                        text: "This traffic robot app uses IoT and ROS2 to transfer live camera frames, mission telemetry, robot health, and control messages between the field robot and the operator dashboard."
                    }

                    Text {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#c8d7e4"
                        font.pixelSize: 13
                        text: "AI supports autonomous target detection, patrol behavior, and route decisions, while ROS2 coordinates sensors, camera transport, recording flow, navigation nodes, and robot control."
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 14

                        InfoCard {
                            title: "CPU"
                            value: (systemHealthData.cpuUsage !== undefined ? systemHealthData.cpuUsage : 0) + "%"
                        }

                        InfoCard {
                            title: "BATTERY"
                            value: (systemHealthData.battery !== undefined ? systemHealthData.battery : 0) + "%"
                        }

                        InfoCard {
                            title: "SPEED"
                            value: (telemetryData.speedKph !== undefined ? Number(telemetryData.speedKph).toFixed(1) : "0.0") + " km/h"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 16
                        color: "#101b26"
                        border.color: "#28445a"
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 8

                            Text {
                                text: "LIVE TARGET NOTES"
                                color: "#8fe9ff"
                                font.pixelSize: 15
                                font.bold: true
                            }

                            Text {
                                width: parent.width
                                wrapMode: Text.WordWrap
                                color: "white"
                                font.pixelSize: 13
                                text: "Target zone: " + (telemetryData.targetZone || "--")
                            }

                            Text {
                                width: parent.width
                                wrapMode: Text.WordWrap
                                color: "white"
                                font.pixelSize: 13
                                text: "Mission progress: " + (telemetryData.progress !== undefined ? telemetryData.progress : 0) + "%"
                            }

                            Text {
                                width: parent.width
                                wrapMode: Text.WordWrap
                                color: "#a8c1d4"
                                font.pixelSize: 12
                                text: "The JSON status is refreshed with a live timestamp while the app is running, so external tools can read the current robot state from the database folder."
                            }
                        }
                    }
                }
            }
        }
    }

    component StatusLine : Rectangle {
        property string label: ""
        property string value: ""

        Layout.fillWidth: true
        implicitHeight: 46
        radius: 12
        color: "#101b26"
        border.color: "#28445a"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Text {
                text: label
                color: "#7ca0b5"
                font.pixelSize: 11
                font.bold: true
                Layout.preferredWidth: 64
            }

            Text {
                text: value
                color: "white"
                font.pixelSize: 13
                font.bold: true
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }
    }

    component InfoCard : Rectangle {
        property string title: ""
        property string value: ""

        Layout.fillWidth: true
        implicitHeight: 88
        radius: 14
        color: "#101b26"
        border.color: "#28445a"
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 4

            Text {
                text: title
                color: "#7ca0b5"
                font.pixelSize: 11
                font.bold: true
            }

            Text {
                text: value
                color: "white"
                font.pixelSize: 16
                font.bold: true
            }
        }
    }
}
