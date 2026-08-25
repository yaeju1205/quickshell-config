pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import qs.services
import "modules"

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {
            required property ShellScreen modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        IdleDimOverlay {}
    }

    AppLauncher {}
    SettingsWindow {}
    PowerWindow {}

    IpcHandler {
        target: "overlay"

        function openLauncher(): void {
            OverlayState.active = "launcher";
        }

        function toggleLauncher(): void {
            OverlayState.toggleLauncher();
        }

        function openSettings(): void {
            OverlayState.active = "settings";
        }

        function toggleSettings(): void {
            OverlayState.toggleSettings();
        }

        function openPower(): void {
            OverlayState.active = "power";
        }

        function togglePower(): void {
            OverlayState.togglePower();
        }

        function close(): void {
            OverlayState.close();
        }
    }
}
