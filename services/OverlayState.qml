pragma Singleton

import QtQuick

QtObject {
    id: root

    // "" | "launcher" | "settings" | "power"
    property string active: ""

    function toggleLauncher() {
        root.active = root.active === "launcher" ? "" : "launcher";
    }

    function toggleSettings() {
        root.active = root.active === "settings" ? "" : "settings";
    }

    function togglePower() {
        root.active = root.active === "power" ? "" : "power";
    }

    function close() {
        root.active = "";
    }
}
