import QtQuick
import QtQuick.Layouts
import qs.services

Rectangle {
    id: root

    Layout.preferredWidth: 28
    Layout.preferredHeight: 28
    radius: 9
    color: OverlayState.active === "launcher" ? Theme.sa0 : hover.containsMouse ? Theme.bg3 : Theme.bg2

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Text {
        anchors.centerIn: parent
        text: ""
        font.family: Theme.fontFamily
        font.pixelSize: 14
        color: OverlayState.active === "launcher" ? Theme.bg0 : Theme.fg1
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: OverlayState.toggleLauncher()
    }
}
