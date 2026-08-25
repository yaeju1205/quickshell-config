import QtQuick
import Quickshell.Services.Pipewire
import qs.services

Item {
    id: root

    property var sink: Pipewire.defaultAudioSink
    property bool muted: sink && sink.audio ? sink.audio.muted : false
    property real volume: sink && sink.audio ? sink.audio.volume : 0

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Text {
            text: root.muted ? "" : ""
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: root.muted ? Theme.er0 : Theme.fg1
        }

        Text {
            text: Math.round(root.volume * 100) + "%"
            font.family: Theme.fontFamily
            font.pixelSize: 13
            color: Theme.fg1
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.sink && root.sink.audio)
                root.sink.audio.muted = !root.sink.audio.muted;
        }
        onWheel: wheel => {
            if (!root.sink || !root.sink.audio)
                return;
            const step = 0.05;
            const delta = wheel.angleDelta.y > 0 ? step : -step;
            root.sink.audio.volume = Math.min(1, Math.max(0, root.sink.audio.volume + delta));
        }
    }
}
