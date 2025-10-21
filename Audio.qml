pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    readonly property PwNode output: Pipewire.defaultAudioSink
    readonly property var volume: output?.audio.volume
    readonly property var muted: output?.ready ? output?.audio.muted : true

    readonly property PwNode mic: Pipewire.defaultAudioSource
    readonly property var micMuted: !mic?.ready || mic?.audio?.muted !== false
    PwObjectTracker {
        objects: [output, mic]
    }
}
