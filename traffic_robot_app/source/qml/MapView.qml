import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtLocation
import QtPositioning

Item {
    id: root

    width: 1400
    height: 900

    property bool nightMode: true
    property color neonBlue: "#00eaff"
    property color neonOrange: "#ff8c00"
    property color neonPurple: "#bc13fe"
    readonly property var systemHealthData: dataManager.systemHealth || ({})
    readonly property var telemetryData: dataManager.robotTelemetry || ({})
    readonly property int violationCount: dataManager.trafficViolations ? dataManager.trafficViolations.length : 0
    readonly property int trafficLevel: violationCount > 5 ? 2 : (violationCount > 2 ? 1 : 0)
    readonly property real latValue: telemetryData.lat !== undefined ? Number(telemetryData.lat) : 30.60291
    readonly property real lonValue: telemetryData.lon !== undefined ? Number(telemetryData.lon) : 32.30487
    readonly property real zoomValue: telemetryData.zoom !== undefined ? Number(telemetryData.zoom) : 17
    readonly property real headingValue: telemetryData.headingDeg !== undefined ? Number(telemetryData.headingDeg) : 0
    readonly property real speedValue: telemetryData.speedKph !== undefined ? Number(telemetryData.speedKph) : 0
    readonly property int etaValue: telemetryData.etaSeconds !== undefined ? Number(telemetryData.etaSeconds) : 0
    readonly property int progressValue: telemetryData.progress !== undefined ? Number(telemetryData.progress) : 0
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

    Rectangle {
        anchors.fill: parent
        color: "#0a0a0a"
    }

    Plugin {
        id: mapPlugin
        name: "osm"
    }

    Map {
        id: mainMap
        anchors.fill: parent
        plugin: mapPlugin
        zoomLevel: root.zoomValue
        activeMapType: mainMap.supportedMapTypes.length > 0
            ? mainMap.supportedMapTypes[0]
            : null

        center: QtPositioning.coordinate(root.latValue, root.lonValue)

        MapPolyline {
            id: pathLine
            line.width: 6
            line.color: trafficLevel === 0 ? "#39ff14"
                        : trafficLevel === 1 ? "#ffff00"
                        : "#ff0000"
            opacity: 0.7
            path: []
        }

        MapQuickItem {
            id: robotMarker
            coordinate: mainMap.center
            anchorPoint.x: sourceItem.width / 2
            anchorPoint.y: sourceItem.height / 2

            sourceItem: Item {
                width: 100; height: 100

                Rectangle {
                    anchors.centerIn: parent
                    width: 60; height: 60
                    radius: 30
                    color: "transparent"
                    border.color: "red"
                    border.width: 2

                    PropertyAnimation on scale {
                        from: 1.0; to: 1.8
                        duration: 1500
                        loops: Animation.Infinite
                    }
                    PropertyAnimation on opacity {
                        from: 1.0; to: 0.0
                        duration: 1500
                        loops: Animation.Infinite
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 40; height: 40
                    radius: 20
                    color: "#ccff0000"

                    Text {
                        anchors.centerIn: parent
                        text: "🤖"
                        font.pixelSize: 24
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 12
        width: 292
        height: 96
        radius: 16
        color: "#d9111822"
        border.color: telemetryData.movementState === "MOVING" ? "#39ff14" : neonOrange
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 6

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: telemetryData.status || "ROBOT ACTIVE"
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Rectangle {
                    radius: 10
                    color: telemetryData.movementState === "MOVING" ? "#17351f" : "#382610"
                    border.color: telemetryData.movementState === "MOVING" ? "#39ff14" : neonOrange
                    border.width: 1
                    implicitWidth: 92
                    implicitHeight: 28

                    Text {
                        anchors.centerIn: parent
                        text: telemetryData.movementState || "STANDBY"
                        color: parent.border.color
                        font.pixelSize: 10
                        font.bold: true
                    }
                }
            }

            Text {
                text: (telemetryData.targetZone || "Sector route") + "  |  " + (telemetryData.routeState || "Awaiting route")
                color: "#8db9d4"
                font.pixelSize: 11
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                TelemetryStat { label: "SPD"; value: root.speedValue.toFixed(1) + " km/h" }
                TelemetryStat { label: "HDG"; value: (telemetryData.headingLabel || "N") + " / " + Math.round(root.headingValue) + " deg" }
                TelemetryStat { label: "ETA"; value: root.etaValue + " s" }
            }
        }
    }

    Rectangle {
        id: cameraInset
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 12

        width: 320
        height: 190
        radius: 12
        color: "#0f141a"

        border.color: "#39ff14"
        border.width: 1.5

        clip: true

        layer.enabled: true
        layer.smooth: true

        Image {
            id: cam
            anchors.fill: parent

            fillMode: Image.PreserveAspectCrop
            smooth: true
            cache: false
            source: "image://camera/frame"
        }

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.15
        }

        Text {
            text: "LIVE"
            color: "#39ff14"
            font.pixelSize: 12
            font.bold: true

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 8
        }

        Rectangle {
            width: 8
            height: 8
            radius: 4
            color: "red"

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 8

            anchors.leftMargin: 40
        }

        Text {
            id: fpsText
            text: cam.status === Image.Error ? "OFFLINE" : "LIVE FEED"
            color: "#cccccc"
            font.pixelSize: 10

            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 6
        }

        Timer {
            interval: 250
            running: true
            repeat: true

            onTriggered: {
                cam.source = "image://camera/frame?" + Date.now()
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 10
        width: 270
        height: 176
        color: "#cc000000"
        border.color: neonBlue
        border.width: 1
        radius: 15

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 5

            Text {
                text: "ROBOT TELEMETRY"
                color: neonBlue
                font.bold: true
                font.pixelSize: 16
            }

            Rectangle {
                height: 1
                Layout.fillWidth: true
                color: neonBlue
                opacity: 0.5
            }

            Text {
                text: "LAT: " + root.latValue.toFixed(6)
                color: "white"
                font.family: "Monospace"
            }

            Text {
                text: "LON: " + root.lonValue.toFixed(6)
                color: "white"
                font.family: "Monospace"
            }

            Text {
                text: "MODE: " + (telemetryData.autonomyMode || "AUTO")
                color: "white"
                font.family: "Monospace"
            }

            Text {
                text: "TARGET: " + (telemetryData.targetZone || "--")
                color: "white"
                font.family: "Monospace"
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.fillWidth: true
                height: 8
                radius: 4
                color: "#102130"

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, root.progressValue / 100))
                    height: parent.height
                    radius: 4
                    color: root.trafficLevel === 2 ? "#ff6b6b" : "#39ff14"
                }
            }

            Text {
                text: "MISSION: " + root.progressValue + "%  |  BAT " + (systemHealthData.battery !== undefined ? systemHealthData.battery : 0) + "%"
                color: root.trafficLevel === 2 ? "#ff6b6b" : "#39ff14"
                font.pixelSize: 12
            }
        }
    }

    component TelemetryStat : Rectangle {
        property string label: ""
        property string value: ""

        Layout.fillWidth: true
        implicitHeight: 40
        radius: 10
        color: "#101b26"
        border.color: "#204155"
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 1

            Text {
                text: label
                color: "#6f93aa"
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
