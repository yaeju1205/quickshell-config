import QtQuick
import QtQuick.Layouts
import qs.services

RowLayout {
    id: root
    spacing: 6

    property int value: 0
    property int minimum: 0
    property int maximum: 999
    property int step: 1

    signal valueEdited(int value)

    function setValue(v) {
        const clamped = Math.max(root.minimum, Math.min(root.maximum, v));
        if (clamped !== root.value)
            root.valueEdited(clamped);
    }

    Rectangle {
        Layout.preferredWidth: 22
        Layout.preferredHeight: 22
        radius: 7
        color: minusHover.containsMouse ? Theme.bg3 : Theme.bg2

        Text {
            anchors.centerIn: parent
            text: "-"
            color: Theme.fg0
            font.family: Theme.fontFamily
            font.pixelSize: 13
        }

        MouseArea {
            id: minusHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.setValue(root.value - root.step)
        }
    }

    Text {
        Layout.preferredWidth: 34
        horizontalAlignment: Text.AlignHCenter
        text: root.value
        color: Theme.fg0
        font.family: Theme.fontFamily
        font.pixelSize: 13
    }

    Rectangle {
        Layout.preferredWidth: 22
        Layout.preferredHeight: 22
        radius: 7
        color: plusHover.containsMouse ? Theme.bg3 : Theme.bg2

        Text {
            anchors.centerIn: parent
            text: "+"
            color: Theme.fg0
            font.family: Theme.fontFamily
            font.pixelSize: 13
        }

        MouseArea {
            id: plusHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.setValue(root.value + root.step)
        }
    }
}
