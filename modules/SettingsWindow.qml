pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services

PanelWindow {
    id: root

    visible: OverlayState.active === "settings"

    screen: {
        const mon = Hyprland.focusedMonitor;
        const match = mon ? Quickshell.screens.find(s => s.name === mon.name) : undefined;
        return match || Quickshell.screens[0];
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    exclusiveZone: 0
    aboveWindows: true
    focusable: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:settings"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Rectangle {
        id: scrim
        anchors.fill: parent
        color: Theme.withAlpha(Theme.bg0, 0.45)
        focus: true

        Keys.onEscapePressed: OverlayState.close()

        MouseArea {
            anchors.fill: parent
            onClicked: OverlayState.close()
        }
    }

    Rectangle {
        id: card
        anchors.top: parent.top
        anchors.topMargin: Settings.barHeight + Settings.barMargin + 10
        anchors.right: parent.right
        anchors.rightMargin: 16
        width: 320
        implicitHeight: content.implicitHeight + 32
        radius: Theme.launcherRadius
        color: Theme.withAlpha(Theme.bg1, 0.97)
        border.width: 1
        border.color: Theme.withAlpha(Theme.bg3, 0.5)

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: "설정"
                color: Theme.fg0
                font.family: Theme.fontFamily
                font.pixelSize: 15
                font.bold: true
            }

            Text {
                text: "바"
                color: Theme.fg8
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }

            SettingRow {
                label: "마진"
                NumberStepper {
                    value: Settings.barMargin
                    minimum: 0
                    maximum: 40
                    onValueEdited: v => Settings.barMargin = v
                }
            }

            SettingRow {
                label: "높이"
                NumberStepper {
                    value: Settings.barHeight
                    minimum: 28
                    maximum: 72
                    onValueEdited: v => Settings.barHeight = v
                }
            }

            SettingRow {
                label: "모서리"
                NumberStepper {
                    value: Settings.radius
                    minimum: 0
                    maximum: 32
                    onValueEdited: v => Settings.radius = v
                }
            }

            Text {
                text: "런처"
                color: Theme.fg8
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }

            SettingRow {
                label: "너비"
                NumberStepper {
                    value: Settings.launcherWidth
                    minimum: 360
                    maximum: 960
                    step: 20
                    onValueEdited: v => Settings.launcherWidth = v
                }
            }

            SettingRow {
                label: "높이"
                NumberStepper {
                    value: Settings.launcherHeight
                    minimum: 280
                    maximum: 800
                    step: 20
                    onValueEdited: v => Settings.launcherHeight = v
                }
            }

            Text {
                text: "표시 모듈"
                color: Theme.fg8
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }

            SettingRow {
                label: "시계"
                ToggleSwitch {
                    checked: Settings.showClock
                    onToggled: Settings.showClock = !Settings.showClock
                }
            }

            SettingRow {
                label: "활성 창"
                ToggleSwitch {
                    checked: Settings.showActiveWindow
                    onToggled: Settings.showActiveWindow = !Settings.showActiveWindow
                }
            }

            SettingRow {
                label: "열린 창 목록"
                ToggleSwitch {
                    checked: Settings.showOpenWindows
                    onToggled: Settings.showOpenWindows = !Settings.showOpenWindows
                }
            }

            SettingRow {
                label: "트레이"
                ToggleSwitch {
                    checked: Settings.showTray
                    onToggled: Settings.showTray = !Settings.showTray
                }
            }

            SettingRow {
                label: "볼륨"
                ToggleSwitch {
                    checked: Settings.showVolume
                    onToggled: Settings.showVolume = !Settings.showVolume
                }
            }

            Text {
                text: "절전"
                color: Theme.fg8
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }

            SettingRow {
                label: "자동 디밍"
                ToggleSwitch {
                    checked: Settings.idleDimEnabled
                    onToggled: Settings.idleDimEnabled = !Settings.idleDimEnabled
                }
            }

            SettingRow {
                label: "대기 시간(초)"
                NumberStepper {
                    value: Settings.idleTimeoutSeconds
                    minimum: 15
                    maximum: 1800
                    step: 15
                    onValueEdited: v => Settings.idleTimeoutSeconds = v
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                Layout.topMargin: 4
                radius: 9
                color: resetHover.containsMouse ? Theme.bg3 : Theme.bg2

                Text {
                    anchors.centerIn: parent
                    text: "기본값으로 초기화"
                    color: Theme.fg1
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }

                MouseArea {
                    id: resetHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Settings.resetToDefaults()
                }
            }
        }
    }
}
