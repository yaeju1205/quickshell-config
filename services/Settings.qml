pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias barMargin: adapter.barMargin
    property alias barHeight: adapter.barHeight
    property alias radius: adapter.radius
    property alias launcherWidth: adapter.launcherWidth
    property alias launcherHeight: adapter.launcherHeight
    property alias showClock: adapter.showClock
    property alias showActiveWindow: adapter.showActiveWindow
    property alias showOpenWindows: adapter.showOpenWindows
    property alias openWindowsCurrentWorkspaceOnly: adapter.openWindowsCurrentWorkspaceOnly
    property alias showTray: adapter.showTray
    property alias showVolume: adapter.showVolume
    property alias idleDimEnabled: adapter.idleDimEnabled
    property alias idleTimeoutSeconds: adapter.idleTimeoutSeconds
    property alias idleDimOpacity: adapter.idleDimOpacity

    function resetToDefaults() {
        adapter.barMargin = 10;
        adapter.barHeight = 40;
        adapter.radius = 16;
        adapter.launcherWidth = 560;
        adapter.launcherHeight = 440;
        adapter.showClock = true;
        adapter.showActiveWindow = true;
        adapter.showOpenWindows = true;
        adapter.openWindowsCurrentWorkspaceOnly = false;
        adapter.showTray = true;
        adapter.showVolume = true;
        adapter.idleDimEnabled = true;
        adapter.idleTimeoutSeconds = 180;
        adapter.idleDimOpacity = 0.85;
    }

    FileView {
        path: Quickshell.shellPath("settings.json")
        watchChanges: true
        printErrors: false

        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: adapter

            property int barMargin: 10
            property int barHeight: 40
            property int radius: 16
            property int launcherWidth: 560
            property int launcherHeight: 440
            property bool showClock: true
            property bool showActiveWindow: true
            property bool showOpenWindows: true
            property bool openWindowsCurrentWorkspaceOnly: false
            property bool showTray: true
            property bool showVolume: true
            property bool idleDimEnabled: true
            property int idleTimeoutSeconds: 180
            property real idleDimOpacity: 0.85
        }
    }
}
