import QtQuick
import QtQuick.Layouts
import QtLocation
import QtPositioning

Rectangle {
    id: root

    property color accentColor: "#5fc9d9"
    property color successColor: "#2ecc71"
    property color warningColor: "#f39c12"
    property color dangerColor: "#ff6b6b"
    readonly property var uiData: dataManager.monitorUi || ({})
    readonly property var mapUi: uiData.map || ({})
    readonly property var telemetryData: dataManager.robotTelemetry || ({})
    readonly property int eventCount: dataManager.trafficViolations ? dataManager.trafficViolations.length : 0
    readonly property var systemHealthData: dataManager.systemHealth || ({})
    readonly property real latValue: telemetryData.lat !== undefined ? Number(telemetryData.lat) : 30.60291
    readonly property real lonValue: telemetryData.lon !== undefined ? Number(telemetryData.lon) : 32.30487
    readonly property real zoomValue: telemetryData.zoom !== undefined
        ? Number(telemetryData.zoom)
        : (mapUi.zoomLevel !== undefined ? Number(mapUi.zoomLevel) : 16)
    readonly property real speedValue: telemetryData.speedKph !== undefined ? Number(telemetryData.speedKph) : 0
    readonly property real headingValue: telemetryData.headingDeg !== undefined ? Number(telemetryData.headingDeg) : 0
    readonly property int etaValue: telemetryData.etaSeconds !== undefined ? Number(telemetryData.etaSeconds) : 0
    readonly property int progressValue: telemetryData.progress !== undefined ? Number(telemetryData.progress) : 0
    readonly property int distanceValue: telemetryData.distanceMeters !== undefined ? Number(telemetryData.distanceMeters) : 0
    readonly property int confidenceValue: telemetryData.confidence !== undefined ? Number(telemetryData.confidence) : 0
    readonly property string updatedText: telemetryData.lastUpdated !== undefined
        ? Qt.formatDateTime(new Date(Number(telemetryData.lastUpdated) * 1000), "hh:mm:ss")
        : "--:--:--"
    readonly property var alertList: telemetryData.alerts || []
    readonly property var trailCoordinates: {
        var trail = telemetryData.trail || []
        var coordinates = []
        for (var i = 0; i < trail.length; ++i) {
            var point = trail[i]
            if (point && point.lat !== undefined && point.lon !== undefined)
                coordinates.push(QtPositioning.coordinate(Number(point.lat), Number(point.lon)))
        }
        if (coordinates.length === 0)
            coordinates.push(QtPositioning.coordinate(latValue, lonValue))
        return coordinates
    }

    color: "#091019"
    border.color: "#1f2d35"
    border.width: 1
    radius: 10

    Plugin {
        id: mapPlugin
        name: "osm"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: mapUi.title || "LIVE STREET MAP"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }

                Text {
                    text: telemetryData.routeState || mapUi.subtitle || "Intersection overview and route intelligence"
                    color: "#7a8d9e"
                    font.pixelSize: 10
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                radius: 8
                color: "#0f1822"
                border.color: telemetryData.movementState === "MOVING" ? root.successColor : root.warningColor
                border.width: 1
                Layout.preferredWidth: 100
                Layout.preferredHeight: 28

                Text {
                    anchors.centerIn: parent
                    text: telemetryData.movementState || "STANDBY"
                    color: parent.border.color
                    font.pixelSize: 10
                    font.bold: true
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            border.color: "#16212b"
            border.width: 1
            clip: true

            Map {
                id: map
                anchors.fill: parent
                plugin: mapPlugin
                zoomLevel: root.zoomValue
                center: QtPositioning.coordinate(root.latValue, root.lonValue)
                activeMapType: supportedMapTypes.length > 0 ? supportedMapTypes[0] : null


                MapPolyline {
                    id: pathLine
                    line.width: 6
                    line.color: trafficLevel === 0 ? "#39ff14"
                                : trafficLevel === 1 ? "#ffff00"
                                : "#ff0000"
                    opacity: 0.7
                    path: []
                }


                MapCircle {
                    center: QtPositioning.coordinate(root.latValue, root.lonValue)
                    radius: 60
                    color: "#33ff5555"
                    border.color: "#ff4d4d"
                    border.width: 2
                }

                MapQuickItem {
                    coordinate: QtPositioning.coordinate(root.latValue, root.lonValue)
                    anchorPoint.x: icon.width / 2
                    anchorPoint.y: icon.height / 2

                    sourceItem: Rectangle {
                        id: icon
                        width: 26
                        height: 26
                        radius: 13
                        color: "#e74c3c"
                        border.color: "white"
                        border.width: 2

                        Rectangle {
                            anchors.centerIn: parent
                            width: 10
                            height: 16
                            radius: 3
                            color: "white"
                            rotation: root.headingValue
                        }
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: 10
                radius: 6
                color: "#a0000000"
                border.color: "#27404f"
                border.width: 1
                width: 200
                height: 70

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 2

                    Text {
                        text: mapUi.telemetryTitle || telemetryData.label || "ROBOT TELEMETRY"
                        color: "white"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    Text {
                        text: "LAT " + root.latValue.toFixed(5) + "  |  LON " + root.lonValue.toFixed(5)
                        color: "#7fd9e8"
                        font.pixelSize: 10
                    }

                    Text {
                        text: (telemetryData.targetZone || "Sector target")
                            + "  |  CPU " + (root.systemHealthData.cpuUsage !== undefined ? root.systemHealthData.cpuUsage : 0) + "%"
                        color: "#d8e6f2"
                        font.pixelSize: 10
                        width: parent.width
                        elide: Text.ElideRight
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 4
            columnSpacing: 8
            rowSpacing: 8

            MetricChip { label: mapUi.speedLabel || "SPEED"; value: root.speedValue.toFixed(1) + " km/h" }
            MetricChip { label: mapUi.headingLabel || "HEADING"; value: (telemetryData.headingLabel || "N") + " / " + Math.round(root.headingValue) + " deg" }
            MetricChip { label: mapUi.etaLabel || "ETA"; value: root.etaValue + " s" }
            MetricChip { label: mapUi.distanceLabel || "DIST"; value: root.distanceValue + " m" }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 96
            radius: 8
            color: "#0d141d"
            border.color: "#21303c"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: mapUi.statusTitle || "ROBOT STATUS"
                            color: root.accentColor
                            font.pixelSize: 11
                            font.bold: true
                        }

                        Text {
                            text: (telemetryData.status || "PATROL ACTIVE") + "  |  " + (telemetryData.autonomyMode || "AUTO NAV")
                            color: "white"
                            font.pixelSize: 12
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    Text {
                        text: "SYNC " + root.updatedText
                        color: "#7a8d9e"
                        font.pixelSize: 10
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 7
                    radius: 4
                    color: "#122231"

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, root.progressValue / 100))
                        height: parent.height
                        radius: 4
                        color: root.confidenceValue >= 85 ? root.successColor : root.warningColor
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: (mapUi.progressLabel || "MISSION PROGRESS") + ": " + root.progressValue + "%"
                        color: "white"
                        font.pixelSize: 11
                    }

                    Text {
                        text: "CONF " + root.confidenceValue + "%"
                        color: root.confidenceValue >= 85 ? root.successColor : root.warningColor
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                Text {
                    text: (mapUi.targetLabel || "TARGET") + ": " + (telemetryData.targetZone || "--")
                    color: "#a9c1d3"
                    font.pixelSize: 11
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: root.alertList.length > 0 ? root.alertList : [mapUi.defaultAlert || "Battery nominal"]

                delegate: Rectangle {
                    required property var modelData

                    radius: 10
                    color: "#132332"
                    border.color: "#27404f"
                    border.width: 1
                    height: 28
                    width: Math.min(root.width - 20, tagText.implicitWidth + 22)

                    Text {
                        id: tagText
                        anchors.centerIn: parent
                        text: modelData
                        color: "white"
                        font.pixelSize: 10
                    }
                }
            }
        }
    }

    component MetricChip : Rectangle {
        property string label: ""
        property string value: ""

        Layout.fillWidth: true
        implicitHeight: 52
        radius: 8
        color: "#0d141d"
        border.color: "#21303c"
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 2

            Text {
                text: label
                color: "#7a8d9e"
                font.pixelSize: 9
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: value
                color: "white"
                font.pixelSize: 11
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
