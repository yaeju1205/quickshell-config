import QtQuick
import QtQuick.Layouts
import qs.services

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 12

    property string label: ""

    Text {
        Layout.fillWidth: true
        text: root.label
        color: Theme.fg1
        font.family: Theme.fontFamily
        font.pixelSize: 13
    }
}
