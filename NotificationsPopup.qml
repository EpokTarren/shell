import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    anchor.window: bar
    anchor.rect.x: bar.width - width - 8
    anchor.rect.y: bar.height + 16
    implicitWidth: 400
    color: "transparent"
    visible: {
        if (Notifications.display.length == 0 && Notifications.showSpecial == null)
            return false;
        Hyprland.refreshToplevels();
        return !Hyprland.activeToplevel?.lastIpcObject.fullscreen;
    }
    implicitHeight: notificationDisplay.height

    ListView {
        id: notificationDisplay
        implicitWidth: parent.width
        implicitHeight: 1440
        height: Math.min(Math.max(128, 16 + contentHeight), bar.screen?.height - 128)

        verticalLayoutDirection: ListView.TopToBottom
        orientation: ListView.Vertical
        spacing: 8

        ScrollBar.vertical: ScrollBar {
            contentItem: Rectangle {
                implicitWidth: 6
                color: Settings.comp0.replace("#", "#80")
                radius: 3
                antialiasing: true
            }
            policy: parent.contentHeight > parent.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        }

        model: Notifications.special != null ? [Notifications.special].concat(Notifications.display) : Notifications.display
        delegate: Notification {}
    }
}
