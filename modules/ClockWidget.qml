import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services

RowLayout {
    id: root
    spacing: 8

    readonly property var weekdays: ["일", "월", "화", "수", "목", "금", "토"]

    Text {
        text: Qt.formatDate(clock.date, "yyyy.MM.dd") + " (" + root.weekdays[clock.date.getDay()] + ")"
        color: Theme.fg1
        font.family: Theme.fontFamily
        font.pixelSize: 13
    }

    Rectangle {
        Layout.preferredWidth: 3
        Layout.preferredHeight: 3
        radius: 1.5
        color: Theme.sa0
    }

    Text {
        text: Qt.formatTime(clock.date, "hh:mm")
        color: Theme.fg0
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.bold: true
    }

    SystemClock {
        id: clock
        enabled: true
        precision: SystemClock.Minutes
    }
}
