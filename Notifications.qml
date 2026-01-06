pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: notifications

    property list<var> all: []
    property list<var> active: []
    property list<var> expiring: []
    property list<var> display: showAll ? all : active
    property bool showAll: false
    property var special: null
    readonly property var ipc: notificationIpc

    NotificationServer {
        id: server
        imageSupported: false
        actionsSupported: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        onNotification: notification => {
            notification.tracked = true;
            notificationIpc.remove(notification.id);

            const notif = {
                actions: notification.actions,
                appIcon: notification.appIcon,
                appName: notification.appName,
                summary: notification.summary,
                body: notification.body,
                progress: notification.hints.value && notification.hints.value / 100,
                id: notification.id
            };

            notifications.all.push(notif);
            if (!notification.lastGeneration || notification.urgency == NotificationUrgency.Critical) {
                notifications.active.push(notif);
                if (notification.urgency != NotificationUrgency.Critical)
                    notifications.expiring.push({
                        id: notification.id,
                        active: +new Date + 10_000,
                        expiration: null
                    });
            }

            notification.closed.connect(_ => notificationIpc.remove(notif.id));

            if (notification.expireTimeout > 0)
                notifications.expiring.push({
                    id: notification.id,
                    active: null,
                    expiration: +new Date + 1000 * notification.expireTimeout
                });
        }
    }

    Timer {
        interval: 1000
        running: notifications.expiring.length
        repeat: true
        onTriggered: {
            const time = +new Date();
            notifications.expiring.forEach(n => {
                if (n.expiration && time > n.expiration) {
                    notificationIpc.dismiss(n.id);
                    n.expiration = null;
                }

                if (n.active && time > n.active) {
                    notificationIpc.hide(n.id);
                    n.active = null;
                }
            });

            notifications.expiring = notifications.expiring.filter(n => n.expiration > 0 || n.active > 0);
        }
    }

    Timer {
        id: specialTimer
        interval: 7500
        running: false
        repeat: false
        onTriggered: notifications.special = null
    }

    function specialNotification(notification): void {
        specialTimer.running = false;
        specialTimer.running = true;
        notification.id = -1;
        notifications.special = notification;
    }

    IpcHandler {
        id: notificationIpc
        target: "notifications"

        function specialNotification(notification: string): void {
            return notifications.specialNotification(JSON.parse(notification));
        }

        function mediaNotification(media: bool): void {
            const volume = (Audio.muted ? "󰝟  " : "  ") + Math.round(Audio.volume * 100) + "%";

            if (!Media.title)
                return notifications.specialNotification({
                    appName: volume,
                    progress: Audio.volume,
                    id: -1
                });

            const playPause = Media.player.playing ? "" : "";
            const name = Media.player?.identity + " (" + playPause + ") " + volume;

            let progress = "";
            if (Media.player?.length) {
                const pMins = Math.floor(Media.player.position / 60);
                const pSecs = Math.floor(Media.player.position % 60).toString().padStart(2, '0');
                const tMins = Math.floor(Media.player.length / 60);
                const tSecs = Math.floor(Media.player.length % 60).toString().padStart(2, '0');
                progress = pMins + ":" + pSecs + " / " + tMins + ":" + tSecs + " ";
            }

            return notifications.specialNotification({
                appIcon: Media.player?.metadata?.["mpris:artUrl"],
                appName: name,
                summary: Media.title,
                body: Media.artist ? "<i>%1</i> | ".arg(Media.artist) + progress : progress,
                progress: media ? (Media.player?.length ? Media.player?.position / Media.player?.length : null) : Audio.volume,
                id: -1
            });
        }

        function dismissAll(): void {
            notifications.all = [];
            notifications.active = [];
            server.trackedNotifications.values.forEach(v => v.dismiss());
            notifications.showAll = false;
            notifications.special = null;
        }

        function hideAll(): void {
            notifications.active = [];
            notifications.showAll = false;
        }

        function dismissTop(): void {
            if (notifications.special != null)
                notifications.special = null;

            if (notifications.display.length > 0)
                dismiss(notifications.display[0].id);
        }

        function dismiss(id: int): void {
            if (id == -1)
                notifications.special = null;

            notificationIpc.remove(id);
            server.trackedNotifications.values.forEach(n => {
                if (n?.id == id)
                    n.dismiss();
            });

            if (notifications.all.length === 0)
                notifications.showAll = false;
        }

        function remove(id: int): void {
            notifications.all = notifications.all.filter(n => n.id != id);
            notifications.active = notifications.active.filter(n => n.id != id);
            notifications.expiring = notifications.expiring.filter(n => n.id != id);
        }

        function hide(id: int): void {
            notifications.active = notifications.active.filter(n => n.id !== id);
        }

        function toggleAll(id: int): void {
            notifications.showAll = notifications.all.length > 0 && !notifications.showAll;
        }
    }
}
