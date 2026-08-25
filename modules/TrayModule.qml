pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.services

RowLayout {
    spacing: 4

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayItem
            required property var modelData

            Layout.preferredWidth: 26
            Layout.preferredHeight: 26

            Rectangle {
                anchors.fill: parent
                radius: 8
                color: (hoverArea.containsMouse || menuLoader.active) ? Theme.bg2 : "transparent"

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }
            }

            IconImage {
                anchors.centerIn: parent
                width: 16
                height: 16
                asynchronous: true
                source: trayItem.modelData.icon
            }

            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        trayItem.modelData.activate();
                    } else if (mouse.button === Qt.RightButton) {
                        if (trayItem.modelData.hasMenu)
                            menuLoader.active = true;
                        else
                            trayItem.modelData.secondaryActivate();
                    }
                }
                onWheel: wheel => trayItem.modelData.scroll(wheel.angleDelta.y, false)
            }

            Loader {
                id: menuLoader
                active: false

                sourceComponent: TrayMenu {
                    anchorItem: trayItem
                    menuHandle: trayItem.modelData.menu
                    visible: true

                    onVisibleChanged: if (!visible)
                        menuLoader.active = false
                }
            }
        }
    }
}
