pragma Singleton
import Quickshell
import Quickshell.Io

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
    readonly property list<string> knownBrowsers: Config.knownBrowsers ?? ["brave", "chromium", "firefox"]

    readonly property var appidReplacers: Config.appIDReplacers ?? [
        {
            matcher: /-browser$/,
            replacer: ""
        },
        {
            matcher: /^steam_app_(\d+)$/,
            replacer: (name, id) => appidResolver.names.get(id) ?? "umu"
        },
    ].concat(Config.extraAppIDReplacers ?? [])

    function replaceId(id) {
        for (const {
            matcher,
            replacer
        } of Settings.appidReplacers) {
            const updated = id.replace(matcher, replacer);
            if (updated != id)
                return updated;
        }
        return id;
    }

    Process {
        id: appidResolver
        property var names: new Map()

        running: true
        command: ["/bin/sh", "-c", "grep name ~/.steam/steam/steamapps/appmanifest_*.acf"]
        stdout: StdioCollector {
            onStreamFinished: () => {
                const names = this.text.split(/(\r?\n)+/).map(app => {
                    const match = app.trim().match(/^.*\/appmanifest_(\d+).acf:\s+"name"\s+"(.*)"$/);
                    return [match?.[1], match?.[2]];
                }).filter(([a, b]) => a && b);
                appidResolver.names = new Map(names);
            }
        }
    }
}
