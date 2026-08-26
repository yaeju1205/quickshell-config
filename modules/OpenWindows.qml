pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.services

Item {
    id: root
    property string screenName: ""

    readonly property int pillHeight: 26
    readonly property int maxWidth: 800

    readonly property var sortedToplevels: {
        const items = Hyprland.toplevels.values.filter(t => {
            if (t.monitor === null || t.monitor.name !== root.screenName)
                return false;
            if (Settings.openWindowsCurrentWorkspaceOnly && (!t.workspace || !t.workspace.active))
                return false;
            return true;
        });
        items.sort((a, b) => {
            const wsA = a.workspace ? a.workspace.id : 0;
            const wsB = b.workspace ? b.workspace.id : 0;
            if (wsA !== wsB)
                return wsA - wsB;

            const atA = a.lastIpcObject.at ?? [0, 0];
            const atB = b.lastIpcObject.at ?? [0, 0];
            if (atA[0] !== atB[0])
                return atA[0] - atB[0];

            return atA[1] - atB[1];
        });
        return items;
    }

    Layout.preferredWidth: Math.min(row.implicitWidth, maxWidth)
    Layout.preferredHeight: pillHeight
    Layout.maximumWidth: maxWidth

    Timer {
        interval: 400
        running: true
        repeat: true
        onTriggered: Hyprland.refreshToplevels()
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: row.implicitWidth
        contentHeight: root.pillHeight
        interactive: contentWidth > width
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        WheelHandler {
            target: null
            onWheel: event => {
                const maxX = Math.max(0, flick.contentWidth - flick.width);
                flick.contentX = Math.min(maxX, Math.max(0, flick.contentX - event.angleDelta.y));
            }
        }

        RowLayout {
            id: row
            height: root.pillHeight
            spacing: 6

            Repeater {
                model: root.sortedToplevels

                delegate: Item {
                    id: pill
                    required property var modelData

                    Layout.preferredHeight: root.pillHeight
                    Layout.preferredWidth: label.width + 20

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.width: 1
                        border.color: hover.containsMouse ? Theme.bg3 : "transparent"

                        Behavior on border.color {
                            ColorAnimation { duration: 120 }
                        }
                    }

                    Rectangle {
                        height: 2
                        width: parent.width
                        anchors.bottom: parent.bottom
                        color: pill.modelData.activated ? Theme.sa0 : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }
                    }

                    Text {
                        id: label
                        anchors.centerIn: parent
                        text: pill.modelData.title.length > 0 ? pill.modelData.title : "(제목 없음)"
                        elide: Text.ElideRight
                        width: Math.min(implicitWidth, 160)
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: pill.modelData.activated ? Theme.sa0 : Theme.fg1

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }
                    }

                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: pill.modelData.wayland.activate()
                    }
                }
            }
        }
    }
}
