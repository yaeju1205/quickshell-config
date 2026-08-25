import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 0
        left: 0
        right: 0
    }

    implicitHeight: Settings.barHeight
    aboveWindows: true
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: Settings.radius
        color: Theme.withAlpha(Theme.bg1, 0.88)
        border.width: 1
        border.color: Theme.withAlpha(Theme.bg3, 0.4)

        Item {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            RowLayout {
                anchors.fill: parent
                spacing: 12

                RowLayout {
                    id: leftGroup
                    spacing: 12

                    LauncherButton {}

                    Workspaces {
                        screenName: root.screen ? root.screen.name : ""
                    }

                    ActiveWindow {
                        visible: Settings.showActiveWindow
                    }

                    OpenWindows {
                        screenName: root.screen ? root.screen.name : ""
                        visible: Settings.showOpenWindows
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                ClockWidget {
                    visible: Settings.showClock
                }

                RowLayout {
                    spacing: 14

                    TrayModule {
                        visible: Settings.showTray
                    }

                    VolumeModule {
                        visible: Settings.showVolume
                    }

                    SettingsButton {}

                    PowerButton {}
                }
            }
        }
    }
}
