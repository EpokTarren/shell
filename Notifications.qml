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
    property var showSpecial: null
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
        id: mediaTimer
        interval: 50
        running: notifications.showSpecial >= 2
        repeat: true
        onTriggered: mediaNotification()
    }

    function specialNotification(notification): void {
        notifications.expiring = notifications.expiring.filter(n => n.id != -1);
        notification.id = -1;
        notifications.showSpecial = 1;
        notifications.expiring.push({
            id: -1,
            active: null,
            expiration: +new Date + 7500
        });
        notifications.special = notification;
    }

    function mediaNotification(): void {
        const media = showSpecial === 3;
        const volume = (Audio.muted ? "󰝟  " : "  ") + Math.round(Audio.volume * 100) + "%";

        if (!Media.title || !Media.player) {
            notifications.special = {
                appName: volume,
                progress: Audio.volume,
                id: -1
            };
            return;
        }

        const playPause = Media.player.playing ? "" : "";
        const name = Media.player.identity + " (" + playPause + ")";
        const appName = Settings.showBarVolume || !media ? name + " " + volume : name;

        let progress = "";
        if (Media.player.length) {
            const pMins = Math.floor(Media.player.position / 60);
            const pSecs = Math.floor(Media.player.position % 60).toString().padStart(2, '0');
            const tMins = Math.floor(Media.player.length / 60);
            const tSecs = Math.floor(Media.player.length % 60).toString().padStart(2, '0');
            progress = pMins + ":" + pSecs + " / " + tMins + ":" + tSecs + " ";
        }

        notifications.special = {
            appIcon: Media.player.metadata?.["mpris:artUrl"],
            appName: appName,
            summary: Media.title,
            body: Media.artist ? "<i>%1</i> | ".arg(Media.artist) + progress : progress,
            progress: media ? (Media.player.length ? Math.min(1.0, Media.player.position / Media.player.length) : null) : Audio.volume,
            id: -1
        };
    }

    IpcHandler {
        id: notificationIpc
        target: "notifications"

        function specialNotification(notification: string): void {
            return notifications.specialNotification(JSON.parse(notification));
        }

        function mediaNotification(media: bool): void {
            notifications.expiring = notifications.expiring.filter(n => n.id != -1);
            notifications.showSpecial = media ? 3 : 2;
            notifications.mediaNotification();
            notifications.expiring.push({
                id: -1,
                active: null,
                expiration: +new Date + 7500
            });
        }

        function dismissAll(): void {
            notifications.all = [];
            notifications.active = [];
            server.trackedNotifications.values.forEach(v => v.dismiss());
            notifications.showAll = false;
            notifications.special = null;
            notifications.showSpecial = null;
        }

        function hideAll(): void {
            notifications.active = [];
            notifications.showAll = false;
        }

        function dismissTop(): void {
            if (notifications.showSpecial != null)
                notificationIpc.remove(-1);
            else if (notifications.display.length > 0)
                notificationIpc.dismiss(notifications.display[0].id);
        }

        function dismiss(id: int): void {
            notificationIpc.remove(id);
            server.trackedNotifications.values.forEach(n => {
                if (n?.id == id)
                    n.dismiss();
            });

            if (notifications.all.length === 0)
                notifications.showAll = false;
        }

        function remove(id: int): void {
            if (id == -1) {
                notifications.showSpecial = null;
                notifications.special = null;
            }

            notifications.all = notifications.all.filter(n => n.id != id);
            notifications.active = notifications.active.filter(n => n.id != id);
            notifications.expiring = notifications.expiring.filter(n => n.id != id);
        }

        function hide(id: int): void {
            notifications.active = notifications.active.filter(n => n.id !== id);
        }

        function toggleAll(): void {
            notifications.showAll = notifications.all.length > 0 && !notifications.showAll;
        }

        function action(): void {
            let id = notifications.display[0]?.id;
            if (id != null)
                notificationIpc.menuActionOn(id);
        }

        function menuActionOn(id: int): void {
            let notification = notifications.all.find(n => n.id == id);
            if (!notification?.actions)
                return;

            notificationAction.stdinEnabled = true;
            notificationAction.running = true;
            notificationAction.actions = notification.actions.map(a => a.text).join("\n");
            notificationAction.notification = id;
        }

        function actionOn(id: int, action: string): void {
            let notification = notifications.all.find(n => n.id == id);
            if (!notification?.actions)
                return;

            notification.actions.find(a => a.text.trim() == action)?.invoke();
        }
    }

    Process {
        id: notificationAction
        property int notification: 0
        property string actions: ""

        running: false
        command: Settings.menuCommand
        onRunningChanged: {
            write(actions);
            notificationAction.stdinEnabled = false;
        }

        stdout: StdioCollector {
            onStreamFinished: () => {
                notificationIpc.actionOn(notificationAction.notification, this.text.trim());
            }
        }
    }
}
