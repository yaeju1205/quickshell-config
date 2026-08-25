pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services

PanelWindow {
    id: root

    visible: OverlayState.active === "power"

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
    WlrLayershell.namespace: "quickshell:power"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    // id of the action currently awaiting a confirming second click, or ""
    property string pending: ""

    readonly property var actions: [
        { id: "lock", label: "잠금", icon: "", confirm: false, command: ["loginctl", "lock-session"] },
        { id: "idle", label: "대기", icon: "", confirm: false, command: null },
        { id: "suspend", label: "절전", icon: "", confirm: false, command: ["systemctl", "suspend"] },
        { id: "logout", label: "로그아웃", icon: "", confirm: true, command: ["hyprctl", "dispatch", "hl.dsp.exit()"] },
        { id: "reboot", label: "재부팅", icon: "", confirm: true, command: ["systemctl", "reboot"] },
        { id: "shutdown", label: "종료", icon: "", confirm: true, command: ["systemctl", "poweroff"] }
    ]

    function run(action) {
        if (action.confirm && root.pending !== action.id) {
            root.pending = action.id;
            pendingTimer.restart();
            return;
        }
        if (action.id === "idle")
            IdleService.triggerIdle();
        else
            Quickshell.execDetached(action.command);
        OverlayState.close();
    }

    onVisibleChanged: if (!visible)
        root.pending = ""

    Timer {
        id: pendingTimer
        interval: 3000
        onTriggered: root.pending = ""
    }

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
        anchors.centerIn: parent
        width: content.implicitWidth + 40
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
            anchors.centerIn: parent
            spacing: 16

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "세션 관리"
                color: Theme.fg0
                font.family: Theme.fontFamily
                font.pixelSize: 15
                font.bold: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                Repeater {
                    model: root.actions

                    delegate: Rectangle {
                        id: cell
                        required property var modelData

                        readonly property bool isPending: root.pending === modelData.id

                        Layout.preferredWidth: 76
                        Layout.preferredHeight: 76
                        radius: 12
                        color: isPending ? Theme.er0 : cellHover.containsMouse ? Theme.bg3 : Theme.bg2

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: cell.isPending ? "" : cell.modelData.icon
                                font.family: Theme.fontFamily
                                font.pixelSize: 20
                                color: cell.isPending ? Theme.bg0 : Theme.fg0
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: cell.isPending ? "확인?" : cell.modelData.label
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                color: cell.isPending ? Theme.bg0 : Theme.fg1
                            }
                        }

                        MouseArea {
                            id: cellHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.run(cell.modelData)
                        }
                    }
                }
            }
        }
    }
}
