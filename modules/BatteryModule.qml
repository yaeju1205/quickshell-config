import QtQuick
import Quickshell.Io
import Quickshell.Services.UPower
import qs.services

Item {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool hasBattery: device.isLaptopBattery || root.sysCapacity >= 0
    readonly property bool charging: device.state === UPowerDeviceState.Charging
        || device.state === UPowerDeviceState.PendingCharge

    // UPower's percentage is an estimate the daemon smooths over its history
    // and it can drift far from the real level; the kernel's raw sysfs
    // capacity is what the hardware actually reports, so prefer it and fall
    // back to UPower when sysfs is unavailable (-1).
    property real sysCapacity: -1

    readonly property real percentage: root.sysCapacity >= 0
        ? root.sysCapacity
        : (device.ready ? device.percentage : 0)

    readonly property bool low: root.percentage <= 20 && !root.charging

    visible: Settings.showBattery && root.hasBattery
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Timer {
        interval: 30000
        triggeredOnStart: true
        repeat: true
        running: true
        onTriggered: capacityProbe.running = true
    }

    Process {
        id: capacityProbe
        // every battery-class supply, whatever the kernel named it
        command: ["sh", "-c", "for d in /sys/class/power_supply/*; do [ \"$(cat \"$d/type\" 2>/dev/null)\" = Battery ] && cat \"$d/capacity\" 2>/dev/null; done | sort -rn | head -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseFloat(this.text);
                root.sysCapacity = isNaN(v) ? -1 : v;
            }
        }
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Text {
            text: {
                if (!root.device.ready && root.sysCapacity < 0)
                    return "\uf244";
                if (root.charging)
                    return "\uf0e7";
                if (root.percentage >= 90)
                    return "\uf240";
                if (root.percentage >= 70)
                    return "\uf243";
                if (root.percentage >= 45)
                    return "\uf242";
                if (root.percentage >= 20)
                    return "\uf241";
                return "\uf244";
            }
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: root.charging ? Theme.gr0 : root.low ? Theme.er0 : Theme.fg1
        }

        Text {
            text: (root.device.ready || root.sysCapacity >= 0) ? Math.round(root.percentage) + "%" : ""
            font.family: Theme.fontFamily
            font.pixelSize: 13
            color: root.low ? Theme.er0 : Theme.fg1
        }
    }
}