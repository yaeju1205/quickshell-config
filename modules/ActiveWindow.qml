import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.services

Text {
    id: root

    Layout.maximumWidth: 320
    Layout.preferredWidth: Math.min(implicitWidth, 320)

    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "바탕화면"
    color: Theme.fg1
    font.family: Theme.fontFamily
    font.pixelSize: 13
}
