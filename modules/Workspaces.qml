pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.services

RowLayout {
    id: root
    property string screenName: ""
    spacing: 6

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            id: pill
            required property var modelData

            visible: modelData.monitor !== null && modelData.monitor.name === root.screenName

            Layout.preferredWidth: 26
            Layout.preferredHeight: 26
            radius: 8
            color: modelData.active ? Theme.sa0
                 : modelData.urgent ? Theme.er0
                 : hover.containsMouse ? Theme.bg3
                 : Theme.bg2

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            Text {
                anchors.centerIn: parent
                text: pill.modelData.id
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: pill.modelData.active
                color: pill.modelData.active ? Theme.bg0 : Theme.fg1
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: pill.modelData.activate()
            }
        }
    }
}
