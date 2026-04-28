import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


Rectangle{
    property var openMonitorPageAction: null
    property var openOverviewTargetPageAction: null
    readonly property var telemetryData: dataManager.robotTelemetry || ({})
    readonly property bool emergencyActive: telemetryData.emergencyActive === true
    anchors.fill: parent
    visible: true
    Rectangle {
        width: parent.width
        height: 80
        color: "#0a111a" // Dark space background

        RowLayout {
            anchors.fill: parent
            spacing: 25

            // --- SYSTEM HEALTH SECTION ---

            Rectangle {
                width: 200; height: 80
                color: "#1a2a3a"
                opacity: 0.8
                radius: 10
                border.color: "#334455"

                RowLayout {
                    anchors.fill: parent; anchors.margins: 10
                    Text {
                        text: "✔"
                        color: "#4CAF50"
                        font.pixelSize: 24
                    }
                    Column {
                        Text { text: "SYSTEM HEALTH"; color: "white"; font.bold: true; font.pixelSize: 14 }
                        Text { text: "All Systems Online"; color: "#aaaaaa"; font.pixelSize: 12 }
                    }
                }
            }

            // --- ACTION BUTTONS SECTION ---
            Rectangle {
                Layout.preferredWidth: 400; Layout.preferredHeight: 80
                color: "transparent"
                border.color: "#334455"
                radius: 10

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 20

                    // Overview Target Button
                    Button {
                        onClicked: {
                            if (typeof openOverviewTargetPageAction === "function")
                                openOverviewTargetPageAction()
                        }
                        contentItem: Text {
                            text: "OVERVIEW TARGET"
                            color: "white"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            implicitWidth: 160; implicitHeight: 45
                            color: "#1f78b8"
                            radius: 22
                            border.width: 2
                            border.color: "#57d7ff"
                        }
                    }

                    // Emergency Stop Button
                    Button {
                        onClicked: {
                            if (emergencyActive) {
                                dataManager.patchRobotTelemetry({
                                    emergencyActive: false,
                                    status: "Robot Active",
                                    movementState: "MOVING",
                                    routeState: "Route resumed by operator",
                                    autonomyMode: "AUTO NAV",
                                    speedKph: 8.0,
                                    etaSeconds: telemetryData.etaSeconds !== undefined ? telemetryData.etaSeconds : 95,
                                    lastUpdated: Math.floor(Date.now() / 1000),
                                    statusLiveTime: Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss")
                                })
                            } else {
                                dataManager.patchRobotTelemetry({
                                    emergencyActive: true,
                                    status: "Emergency Stop",
                                    movementState: "STOPPED",
                                    routeState: "Emergency hold by operator",
                                    autonomyMode: "MANUAL HOLD",
                                    speedKph: 0,
                                    etaSeconds: 0,
                                    lastUpdated: Math.floor(Date.now() / 1000),
                                    statusLiveTime: Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss")
                                })
                            }
                        }
                        contentItem: Text {
                            text: emergencyActive ? "ACTIVATE ROBOT" : "EMERGENCY STOP"
                            color: "white"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            implicitWidth: 160; implicitHeight: 45
                            color: emergencyActive ? "#1d8f4e" : "#e74c3c"
                            radius: 22
                            border.width: 2
                            border.color: emergencyActive ? "#67d79a" : "#ec7063"
                        }
                    }
                }
            }

            // --- JOYSTICK / STATUS CIRCLE ---
            Item {
                width: 80; height: 80

                // The blue glowing rings
                Rectangle {
                    anchors.fill: parent
                    radius: width/2
                    color: "transparent"
                    border.color: "#00d2ff"
                    border.width: 2
                    opacity: 0.6
                }

                Text {
                    anchors.centerIn: parent
                    text: "+"
                    color: "white"
                    font.pixelSize: 30
                }
            }

            // --- MANUAL CONTROL SECTION ---
            Rectangle {
                width: 150; height: 80
                color: "transparent"
                border.color: "#57d7ff"
                radius: 10

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "MONITOR\nSTATUS"
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: telemetryData.status !== undefined ? telemetryData.status : "READY"
                        color: "#7fd9e8"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (typeof openMonitorPageAction === "function")
                            openMonitorPageAction()
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            dataManager.patchRobotTelemetry({
                emergencyActive: emergencyActive,
                status: telemetryData.status !== undefined ? telemetryData.status : "READY",
                movementState: telemetryData.movementState !== undefined ? telemetryData.movementState : "STANDBY",
                lastUpdated: Math.floor(Date.now() / 1000),
                statusLiveTime: Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss")
            })
        }
    }

}
