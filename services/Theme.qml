pragma Singleton

import QtQuick
import Quickshell

// blossom.vim palette — https://github.com/yaeju1205/blossom.vim
Singleton {
    // -- surfaces -----------------------------------------------------
    readonly property color bg0: "#070707" // background
    readonly property color bg1: "#252425" // raised surface (bar, floats)
    readonly property color bg2: "#2D2B2D" // hover / selected
    readonly property color bg3: "#5E585E" // muted / idle pill
    readonly property color vs0: "#3D393D" // visual selection
    readonly property color vs1: "#211F21" // subtle / recessed

    // -- text -----------------------------------------------------------
    readonly property color fg0: "#C7B7BA" // primary text
    readonly property color fg1: "#A6989B" // secondary text
    readonly property color fg8: "#95888B" // faint text
    readonly property color fg9: "#96869A" // function-ish accent text

    // -- semantic ---------------------------------------------------------
    readonly property color er0: "#A56661" // error / red
    readonly property color yl0: "#957F5F" // warn / yellow
    readonly property color gr0: "#6C8778" // ok / green
    readonly property color gb0: "#7B76A5" // info / blue
    readonly property color gb1: "#6D6692"

    readonly property color gp0: "#807785"
    readonly property color gp1: "#8F8190"

    // -- blossom accents ------------------------------------------------
    readonly property color sa0: "#B28D9E" // signature pink — primary accent
    readonly property color sa1: "#9F7082" // deep rose
    readonly property color sa2: "#7F5E6A"

    readonly property color sr0: "#AB7DAB" // blossom magenta — secondary accent
    readonly property color sr1: "#936793"

    readonly property color pi0: "#887A87" // keyword / hint
    readonly property color pi1: "#6B5E6A"

    readonly property color accent: sa0

    // -- fonts ------------------------------------------------------------
    readonly property string fontFamily: "JetBrainsMono Nerd Font Propo"
    readonly property string fontFamilyMono: "JetBrainsMono Nerd Font Mono"

    // -- launcher metrics -----------------------------------------------
    // width/height are user-configurable, see qs.services Settings
    readonly property int launcherRadius: 18

    function withAlpha(c: color, a: real): color {
        return Qt.rgba(c.r, c.g, c.b, a);
    }
}
