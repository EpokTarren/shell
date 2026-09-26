pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
    id: mpris

    function update() {
        const old = Mpris.players.values.find(player => player.dbusName == playerName);
        if (old?.isPlaying) {
            mpris.player = old;
            return;
        }

        const next = Mpris.players.values.find(player => player.isPlaying);
        if (next) {
            mpris.player = next;
        } else if (old) {
            mpris.player = old;
        } else {
            mpris.player = Mpris.players.values[0];
        }
    }

    function bindPlayer(player) {
        player.postTrackChanged.connect(mpris.update);
        player.isPlayingChanged.connect(mpris.update);
    }

    property var player: update()
    readonly property string artist: player?.trackArtist || null
    readonly property string title: player?.trackTitle || null
    readonly property var playerName: player?.dbusName
    readonly property bool isBrowser: Settings.knownBrowsers.find(browser => playerName?.includes(browser)) !== undefined

    // Bind the relevant player events.
    readonly property var __bind: Mpris.players.values.forEach(bindPlayer)

    readonly property string text: {
        if (!player || !title)
            return "";

        if (!artist)
            return title;

        // Filter out appending artist names to media titles which contain them.
        if (isBrowser) {
            const lowerTitle = title.toLowerCase().normalize("NFC");
            const name = artist.toLowerCase().normalize("NFC");
            // Split name into likely seprate or duplicated names.
            const names = [name, ...name.split(/\s*Ch.|\/\s*/gi)].map(name => name.trim()).filter(Boolean);
            const isTitle = names.find(name => name === lowerTitle);
            const containsName = !isTitle && names.find(name => lowerTitle.includes(name));

            if (containsName)
                return title;
        }

        return title + " - " + artist;
    }

    IpcHandler {
        id: mediaIpc
        target: "media"

        function playerName(): string {
            return mpris.player?.dbusName || "";
        }
    }
}
