import QtQuick
import qs.services

Rectangle {
    id: root

    property bool checked: false
    signal toggled()

    width: 38
    height: 21
    radius: 11
    color: root.checked ? Theme.sa0 : Theme.bg3

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Rectangle {
        width: 15
        height: 15
        radius: 8
        color: Theme.bg0
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? root.width - width - 3 : 3

        Behavior on x {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
