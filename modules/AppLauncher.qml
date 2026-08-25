pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland
import qs.services

PanelWindow {
    id: root

    visible: OverlayState.active === "launcher"

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
    WlrLayershell.namespace: "quickshell:launcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    readonly property var apps: DesktopEntries.applications.values
    property string query: ""

    readonly property var filtered: {
        const q = root.query.trim().toLowerCase();
        const list = root.apps.filter(a => !a.noDisplay && (
            q.length === 0
            || a.name.toLowerCase().includes(q)
            || (a.genericName && a.genericName.toLowerCase().includes(q))
            || (a.comment && a.comment.toLowerCase().includes(q))
        ));
        list.sort((a, b) => a.name.localeCompare(b.name));
        return list;
    }

    function launch(entry) {
        entry.execute();
        OverlayState.close();
    }

    onVisibleChanged: {
        if (visible) {
            query = "";
            searchInput.text = "";
            searchInput.forceActiveFocus();
        }
    }

    Rectangle {
        id: scrim
        anchors.fill: parent
        color: Theme.withAlpha(Theme.bg0, 0.45)

        MouseArea {
            anchors.fill: parent
            onClicked: OverlayState.close()
        }
    }

    Rectangle {
        id: card
        anchors.top: parent.top
        anchors.topMargin: Settings.barHeight + Settings.barMargin + 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: Settings.launcherWidth
        height: Settings.launcherHeight
        radius: Theme.launcherRadius
        color: Theme.withAlpha(Theme.bg1, 0.97)
        border.width: 1
        border.color: Theme.withAlpha(Theme.bg3, 0.5)

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                radius: 11
                color: Theme.bg2
                border.width: 1
                border.color: Theme.withAlpha(Theme.bg3, 0.4)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: ""
                        color: Theme.fg8
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        color: Theme.fg0
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        clip: true
                        focus: true

                        onTextChanged: root.query = text

                        Keys.onEscapePressed: OverlayState.close()
                        Keys.onReturnPressed: {
                            if (root.filtered.length > 0)
                                root.launch(root.filtered[0]);
                        }
                        Keys.onEnterPressed: {
                            if (root.filtered.length > 0)
                                root.launch(root.filtered[0]);
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            visible: searchInput.text.length === 0
                            text: "앱 검색..."
                            color: Theme.fg8
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                GridView {
                    id: grid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    cellWidth: 92
                    cellHeight: 92
                    model: root.filtered

                    delegate: Item {
                        id: cell
                        required property var modelData

                        width: grid.cellWidth
                        height: grid.cellHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 10
                            color: cellHover.containsMouse ? Theme.bg2 : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 6

                                IconImage {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 36
                                    Layout.preferredHeight: 36
                                    asynchronous: true
                                    source: Quickshell.iconPath(cell.modelData.icon, "application-x-executable")
                                }

                                Text {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignHCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    text: cell.modelData.name
                                    color: Theme.fg0
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }
                            }

                            MouseArea {
                                id: cellHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.launch(cell.modelData)
                            }
                        }
                    }
                }

                Item {
                    Layout.preferredWidth: 4
                    Layout.fillHeight: true
                    visible: grid.contentHeight > grid.height

                    Rectangle {
                        width: 4
                        radius: 2
                        color: Theme.withAlpha(Theme.bg3, 0.6)
                        y: Math.min(
                            Math.max(0, grid.contentY / Math.max(1, grid.contentHeight - grid.height)) * (parent.height - height),
                            parent.height - height
                        )
                        height: Math.min(parent.height, Math.max(24, parent.height * (grid.height / Math.max(1, grid.contentHeight))))

                        Behavior on y {
                            NumberAnimation { duration: 80 }
                        }
                    }
                }
            }
        }
    }
}
