pragma Singleton
import Quickshell

Singleton {
    readonly property string bg0: Theme.bg0 || "#271b1f"
    readonly property string bg2: Theme.bg2 || "#3c2a2a"
    readonly property string plain: Theme.plain || "#faeceb"
    readonly property string comp0: Theme.comp0 || "#9966ff"
    readonly property string primary0: Theme.primary0 || "#ff33aa"
    readonly property string primary1: Theme.primary1 || "#ff66a6"
    readonly property string primary2: Theme.primary2 || "#ff99b3"
    readonly property string primary3: Theme.primary3 || "#ffccd0"
    readonly property bool showBarMic: Config.showBarMic ?? true
    readonly property bool showBarVolume: Config.showBarVolume ?? true
}
