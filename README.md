# quickshell config

A personal [Quickshell](https://quickshell.org/) desktop shell for Hyprland — a top bar, app launcher, settings panel, power/session menu, and an idle-dim overlay, styled with the [blossom.vim](https://github.com/yaeju1205/blossom.vim) palette.

## Features

- **Bar** (`modules/Bar.qml`) — a translucent top panel per screen showing:
  - App launcher button
  - Hyprland workspace pills
  - Active window title (optional)
  - Open windows list, current workspace or all (optional)
  - Clock
  - System tray
  - Volume control
  - Settings and power buttons
- **App launcher** (`modules/AppLauncher.qml`) — fuzzy-searchable overlay over desktop entries, opened on the focused monitor.
- **Settings window** (`modules/SettingsWindow.qml`) — live-editable shell preferences (bar size/radius, launcher size, toggles, idle dimming) backed by `settings.json`.
- **Power window** (`modules/PowerWindow.qml`) — session actions (lock/logout/suspend/reboot/shutdown) with confirm-to-execute.
- **Idle dim overlay** (`modules/IdleDimOverlay.qml` + `services/IdleService.qml`) — dims the screen after a configurable idle timeout, respecting inhibitors.
- **IPC control** — all overlays (launcher, settings, power) can be opened/toggled/closed from outside the shell via `quickshell ipc call`.

## Layout

```
shell.qml            Entry point: wires up the bar, overlays, and IPC handler
modules/              UI components (bar widgets, launcher, settings, power window, ...)
services/              Singletons: Settings (persisted config), Theme (colors/fonts),
                       OverlayState (which overlay is open), IdleService
scripts/launcherctl    CLI helper for driving the overlay IPC
settings.json          Persisted, user-editable shell settings (auto-written by the Settings window)
```

## Usage

Run the shell (from anywhere, since this is `~/.config/quickshell`):

```sh
quickshell
```

Control overlays from a terminal, keybind, or script:

```sh
scripts/launcherctl toggle            # app launcher (default)
scripts/launcherctl open
scripts/launcherctl toggle-settings
scripts/launcherctl toggle-power
scripts/launcherctl close
```

Or call the IPC directly:

```sh
quickshell ipc call overlay toggleLauncher
quickshell ipc call overlay toggleSettings
quickshell ipc call overlay togglePower
quickshell ipc call overlay close
```

## Configuration

Settings are persisted in [`settings.json`](settings.json) and can be edited live from the in-shell Settings window (opened via the settings button in the bar or `launcherctl toggle-settings`), or by editing the file directly — changes are picked up automatically. Available options include bar height/margin/corner radius, launcher size, which bar modules are shown, and idle-dim timeout/opacity.

## Requirements

- [Quickshell](https://quickshell.org/)
- [Hyprland](https://hyprland.org/) (workspaces, active window, and launcher/power monitor targeting use `Quickshell.Hyprland`)
- `JetBrainsMono Nerd Font` (Propo + Mono) for bar/UI text
