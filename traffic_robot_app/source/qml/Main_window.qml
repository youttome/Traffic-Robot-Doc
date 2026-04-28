import QtQuick
import QtQuick.Layouts
Rectangle {
    id: main
    property var openMonitorPageAction: null
    property var openOverviewTargetPageAction: null
    anchors.fill: parent
    color: "#03060a"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // 🔵 Top
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "transparent"
            Top_Bar {
                anchors.fill: parent
                missionTime: topBarData.missionTime
                latency: topBarData.latency
                signalStrength: topBarData.signalStrength
            }
        }

        // 🟢 Middle
        Rectangle {
            color: "#081018"
            radius: 18
            border.color: "#142432"
            border.width: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Rectangle {
                    color: "#0b1320"
                    radius: 18
                    border.color: "#1e3347"
                    border.width: 1
                    width: 340
                    Layout.preferredWidth: 340
                    Layout.fillHeight: true

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        height: 40
                        radius: 12
                        color: "#101a28"
                        border.color: "#29435b"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "ROBOT STATUS CORE"
                            color: "#7fe7ff"
                            font.pixelSize: 14
                            font.bold: true
                            font.letterSpacing: 1.2
                        }
                    }

                    Left_Bar {
                        id: left
                        anchors.fill: parent
                        anchors.margins: 8
                        anchors.topMargin: 52
                    }
                }

                Rectangle {
                    color: "#09131e"
                    radius: 18
                    border.color: "#173043"
                    border.width: 1
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    MapView {
                        anchors.fill: parent
                        anchors.margins: 6
                    }
                }
            }
        }

        // 🔵 Bottom
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            Bottom_Bar {
                openMonitorPageAction: main.openMonitorPageAction
                openOverviewTargetPageAction: main.openOverviewTargetPageAction
            }
        }
    }
}
