pragma Singleton

import Quickshell
import Quickshell.Wayland
import qs.services

Singleton {
    id: root

    // forced via the session panel: pins the monitor's timeout to zero so it
    // reports idle immediately, then clears itself on the next real input
    property bool forcedIdle: false

    readonly property bool active: Settings.idleDimEnabled || forcedIdle
    readonly property bool isIdle: monitor.isIdle

    function triggerIdle() {
        root.forcedIdle = true;
    }

    IdleMonitor {
        id: monitor
        enabled: root.active
        timeout: root.forcedIdle ? 0 : Settings.idleTimeoutSeconds
        respectInhibitors: true
        onIsIdleChanged: if (!isIdle)
            root.forcedIdle = false
    }
}
