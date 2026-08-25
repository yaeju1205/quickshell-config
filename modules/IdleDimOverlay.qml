pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

PanelWindow {
    id: root

    required property ShellScreen modelData
    screen: modelData

    visible: IdleService.active

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    // -1 ignores other layer-shell surfaces' exclusive zones (e.g. Bar's),
    // otherwise this full-screen overlay gets shrunk to exclude the bar area.
    exclusiveZone: -1
    aboveWindows: true
    focusable: false

    // Fully click/keyboard-through: dimming must never block real input,
    // since real input is exactly what should end the idle state.
    mask: Region {}

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:idledim"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        anchors.fill: parent
        color: Theme.bg0
        opacity: IdleService.isIdle ? Settings.idleDimOpacity : 0

        Behavior on opacity {
            NumberAnimation {
                // slow fade to dim, snappy restore on activity
                duration: IdleService.isIdle ? 1500 : 200
                easing.type: Easing.InOutQuad
            }
        }
    }
}
