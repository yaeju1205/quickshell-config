pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs.services

// Custom-rendered context menu for a system tray item's DBusMenu.
// Recursively spawns nested TrayMenu popups for submenus on hover,
// each anchored to the row that opened it so the Wayland popup chain
// stays valid.
PopupWindow {
    id: root

    required property var menuHandle
    required property Item anchorItem
    property var topMenu: null

    property bool hoveredRow: false
    property int openSubmenuIndex: -1
    property Item pendingSubmenuAnchor: null
    property var pendingSubmenuHandle: null
    readonly property bool hoveredAnywhere: root.hoveredRow || (submenuLoader.item ? submenuLoader.item.hoveredAnywhere : false)

    readonly property int shadowMargin: 10
    readonly property int menuWidth: 226

    color: "transparent"
    visible: false
    grabFocus: true

    implicitWidth: root.menuWidth + root.shadowMargin * 2
    implicitHeight: list.implicitHeight + 16 + root.shadowMargin * 2

    anchor {
        item: root.anchorItem
        edges: Edges.Bottom | Edges.Right
        gravity: Edges.Bottom | Edges.Left
        adjustment: PopupAdjustment.Slide
    }

    function open() {
        root.visible = true;
    }

    function closeAll() {
        closeSubmenu();
        root.visible = false;
    }

    function closeSubmenu() {
        if (submenuLoader.item)
            submenuLoader.item.closeAll();
        submenuLoader.active = false;
        root.openSubmenuIndex = -1;
    }

    function openSubmenu(index, anchorItm, handle) {
        if (root.openSubmenuIndex === index)
            return;
        closeSubmenu();
        root.openSubmenuIndex = index;
        root.pendingSubmenuAnchor = anchorItm;
        root.pendingSubmenuHandle = handle;
        submenuLoader.active = true;
    }

    Timer {
        id: submenuCloseTimer
        interval: 220
        onTriggered: {
            if (!root.hoveredRow && !(submenuLoader.item && submenuLoader.item.hoveredAnywhere))
                root.closeSubmenu();
        }
    }

    QsMenuOpener {
        id: opener
        menu: root.menuHandle
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: root.shadowMargin
        radius: 12
        color: Theme.withAlpha(Theme.bg1, 0.96)
        border.width: 1
        border.color: Theme.withAlpha(Theme.bg3, 0.5)

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.5)
            shadowBlur: 0.5
            shadowVerticalOffset: 4
            shadowHorizontalOffset: 0
            autoPaddingEnabled: true
        }

        ColumnLayout {
            id: list
            anchors.fill: parent
            anchors.margins: 8
            spacing: 1

            Repeater {
                model: opener.children

                delegate: Item {
                    id: rowRoot
                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    Layout.preferredHeight: rowRoot.modelData.isSeparator ? 9 : 28

                    Rectangle {
                        visible: rowRoot.modelData.isSeparator
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: 1
                        color: Theme.withAlpha(Theme.bg3, 0.5)
                    }

                    Rectangle {
                        id: rowBg
                        visible: !rowRoot.modelData.isSeparator
                        anchors.fill: parent
                        radius: 7
                        color: rowHover.containsMouse && rowRoot.modelData.enabled ? Theme.sa0 : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: 90 }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

                            Text {
                                Layout.preferredWidth: 14
                                horizontalAlignment: Text.AlignHCenter
                                text: rowRoot.modelData.buttonType === QsMenuButtonType.CheckBox ? (rowRoot.modelData.checkState === Qt.Checked ? "✓" : "") : rowRoot.modelData.buttonType === QsMenuButtonType.RadioButton ? (rowRoot.modelData.checkState === Qt.Checked ? "●" : "") : ""
                                color: rowHover.containsMouse && rowRoot.modelData.enabled ? Theme.bg0 : Theme.fg1
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                            }

                            IconImage {
                                visible: rowRoot.modelData.icon !== ""
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                asynchronous: true
                                source: rowRoot.modelData.icon
                            }

                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: rowRoot.modelData.text
                                color: !rowRoot.modelData.enabled ? Theme.fg8 : rowHover.containsMouse ? Theme.bg0 : Theme.fg0
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                            }

                            Text {
                                visible: rowRoot.modelData.hasChildren
                                text: "›"
                                color: rowHover.containsMouse ? Theme.bg0 : Theme.fg8
                                font.family: Theme.fontFamily
                                font.pixelSize: 15
                            }
                        }

                        MouseArea {
                            id: rowHover
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: rowRoot.modelData.enabled
                            cursorShape: Qt.PointingHandCursor

                            onEntered: {
                                root.hoveredRow = true;
                                submenuCloseTimer.stop();
                                if (rowRoot.modelData.hasChildren)
                                    root.openSubmenu(rowRoot.index, rowBg, rowRoot.modelData);
                                else if (root.openSubmenuIndex !== -1)
                                    root.closeSubmenu();
                            }
                            onExited: {
                                root.hoveredRow = false;
                                submenuCloseTimer.restart();
                            }
                            onClicked: {
                                if (rowRoot.modelData.hasChildren)
                                    return;
                                rowRoot.modelData.triggered();
                                (root.topMenu ? root.topMenu : root).closeAll();
                            }
                        }
                    }
                }
            }
        }
    }

    Loader {
        id: submenuLoader
        active: false

        onActiveChanged: {
            if (active) {
                setSource(Qt.resolvedUrl("TrayMenu.qml"), {
                    anchorItem: root.pendingSubmenuAnchor,
                    menuHandle: root.pendingSubmenuHandle,
                    topMenu: root.topMenu ? root.topMenu : root,
                    visible: true
                });
            } else {
                source = "";
            }
        }
    }
}
