pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import "monitor"

Window {
    id: root
    visible: true
    width: Screen.width
    height: Screen.height
    title: "TRAFFIC ROBOT MONITORING"
    color: "#04070c"
    visibility: Qt.platform.os == "android" ? Window.FullScreen : Window.Windowed

    Material.accent: "#57d7ff"

    function openMonitorPage() {
        stackView.push(page2)
    }

    function openOverviewTargetPage() {
        stackView.push(page3)
    }

    FontLoader {
        id: customFont
        source: "monofonto.otf"
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: page1

        pushEnter: Transition {
            NumberAnimation {
                property: "x"
                from: stackView.width
                to: 0
                duration: 140
                easing.type: Easing.InOutQuad
            }
        }

        pushExit: Transition {
            NumberAnimation {
                property: "x"
                from: 0
                to: -stackView.width / 3
                duration: 140
                easing.type: Easing.InOutQuad
            }
        }

        popEnter: Transition {
            NumberAnimation {
                property: "x"
                from: -stackView.width / 3
                to: 0
                duration: 140
                easing.type: Easing.InOutQuad
            }
        }

        popExit: Transition {
            NumberAnimation {
                property: "x"
                from: 0
                to: stackView.width
                duration: 140
                easing.type: Easing.InOutQuad
            }
        }
    }

    Component {
        id: page1

        Page {
            Rectangle {
                id: mainWindow
                anchors.fill: parent
                color: "#04070c"
                property real performance_value: systemMonitor.performanceValue
                property int battery_value: systemMonitor.batteryValue

                Main_window {
                    anchors.fill: parent
                    openMonitorPageAction: root.openMonitorPage
                    openOverviewTargetPageAction: root.openOverviewTargetPage
                }
            }
        }
    }

    Component {
        id: page2

        Page {
            Rectangle {
                anchors.fill: parent
                color: "#081018"

                Monitor_window {
                    anchors.fill: parent
                }
            }
        }
    }

    Component {
        id: page3

        Page {
            Rectangle {
                anchors.fill: parent
                color: "#081018"

                OverviewTargetPage {
                    anchors.fill: parent
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 20
                    width: 120
                    height: 52
                    radius: 14
                    color: "#cc0b1220"
                    border.color: "#57d7ff"
                    border.width: 1

                    Button {
                        anchors.fill: parent
                        anchors.margins: 6
                        text: "HOME"
                        font.bold: true
                        onClicked: stackView.pop()
                    }
                }
            }
        }
    }

}
