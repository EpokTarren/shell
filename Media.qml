pragma Singleton
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: mpris
    readonly property MprisPlayer player: Mpris.players.values.find(player => player.isPlaying) || mpris.player || Mpris.players.values[0]
    readonly property string artist: player?.trackArtist || null
    readonly property string title: player?.trackTitle || null
    readonly property bool isBrowser: Settings.knownBrowsers.find(browser => player?.dbusName.includes(browser)) !== undefined
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
}
