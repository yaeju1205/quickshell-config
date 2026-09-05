pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.services

Item {
    id: root
    property string screenName: ""

    readonly property int pillHeight: 26
    readonly property int maxWidth: 800

    // Quickshell 은 closewindow 이벤트로만 toplevel 을 제거하고, refreshToplevels()
    // 응답에서 사라진 항목은 정리하지 않는다. 그래서 창을 닫는 순간에 j/clients
    // 요청이 떠 있었다면 이미 죽은 주소가 다시 목록에 추가되어 영영 남는다.
    // 닫힌 주소를 직접 기억해 두고 걸러낸다.
    property var closedAddresses: []
    readonly property int closedAddressLimit: 64

    // wayland 핸들이 사라져도 변경 알림이 오지 않으므로, 주기 갱신 때 목록을 다시
    // 계산하도록 바인딩이 의존할 값을 하나 둔다.
    property int refreshTick: 0

    function markClosed(address) {
        if (!address)
            return;
        const next = root.closedAddresses.filter(a => a !== address);
        next.push(address);
        while (next.length > root.closedAddressLimit)
            next.shift();
        root.closedAddresses = next;
    }

    function markOpened(address) {
        if (!address || !root.closedAddresses.includes(address))
            return;
        root.closedAddresses = root.closedAddresses.filter(a => a !== address);
    }

    readonly property var sortedToplevels: {
        const closed = root.closedAddresses;
        void root.refreshTick;
        const items = Hyprland.toplevels.values.filter(t => {
            if (closed.includes(t.address))
                return false;
            // 이미 닫힌 창은 wayland 핸들이 파괴되어 null 이 된다.
            if (t.wayland === null)
                return false;
            if (t.monitor === null || t.monitor.name !== root.screenName)
                return false;
            if (Settings.openWindowsCurrentWorkspaceOnly && (!t.workspace || !t.workspace.active))
                return false;
            return true;
        });
        items.sort((a, b) => {
            const wsA = a.workspace ? a.workspace.id : 0;
            const wsB = b.workspace ? b.workspace.id : 0;
            if (wsA !== wsB)
                return wsA - wsB;

            const atA = a.lastIpcObject.at ?? [0, 0];
            const atB = b.lastIpcObject.at ?? [0, 0];
            if (atA[0] !== atB[0])
                return atA[0] - atB[0];

            return atA[1] - atB[1];
        });
        return items;
    }

    Layout.preferredWidth: Math.min(row.implicitWidth, maxWidth)
    Layout.preferredHeight: pillHeight
    Layout.maximumWidth: maxWidth

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "closewindow") {
                root.markClosed(event.data.trim());
            } else if (event.name === "openwindow") {
                root.markOpened(event.parse(4)[0]);
            }
            refreshDebounce.restart();
        }
    }

    // 이벤트 직후 위치(at) 정보를 다시 받아 정렬을 갱신한다.
    Timer {
        id: refreshDebounce
        interval: 60
        repeat: false
        onTriggered: {
            Hyprland.refreshToplevels();
            root.refreshTick++;
        }
    }

    Timer {
        interval: 400
        running: true
        repeat: true
        onTriggered: {
            Hyprland.refreshToplevels();
            root.refreshTick++;
        }
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: row.implicitWidth
        contentHeight: root.pillHeight
        interactive: contentWidth > width
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        WheelHandler {
            target: null
            onWheel: event => {
                const maxX = Math.max(0, flick.contentWidth - flick.width);
                flick.contentX = Math.min(maxX, Math.max(0, flick.contentX - event.angleDelta.y));
            }
        }

        RowLayout {
            id: row
            height: root.pillHeight
            spacing: 6

            Repeater {
                model: root.sortedToplevels

                delegate: Item {
                    id: pill
                    required property var modelData

                    Layout.preferredHeight: root.pillHeight
                    Layout.preferredWidth: label.width + 20

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.width: 1
                        border.color: hover.containsMouse ? Theme.bg3 : "transparent"

                        Behavior on border.color {
                            ColorAnimation { duration: 120 }
                        }
                    }

                    Rectangle {
                        height: 2
                        width: parent.width
                        anchors.bottom: parent.bottom
                        color: pill.modelData.activated ? Theme.sa0 : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }
                    }

                    Text {
                        id: label
                        anchors.centerIn: parent
                        text: pill.modelData.title.length > 0 ? pill.modelData.title : "(제목 없음)"
                        elide: Text.ElideRight
                        width: Math.min(implicitWidth, 160)
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: pill.modelData.activated ? Theme.sa0 : Theme.fg1

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }
                    }

                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (pill.modelData.wayland)
                                pill.modelData.wayland.activate();
                        }
                    }
                }
            }
        }
    }
}
