pragma Singleton
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: mpris
    SystemClock {
        id: clock
    }
    readonly property MprisPlayer player: Mpris.players.values.find(player => player.isPlaying) || mpris.player || Mpris.players.values[0]
    readonly property string artist: player?.trackArtist || null
    readonly property string title: player?.trackTitle || null
    readonly property string text: (player && title) ? (artist ? title + " - " + artist : title) : ""
}
