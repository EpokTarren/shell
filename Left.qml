import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

RowLayout {
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left

    layoutDirection: Qt.LeftToRight
    spacing: 0

    property var bar

    Rectangle {
        color: Settings.primary0

        property var offset: Settings.barRadius * 0.5

        height: 32
        Layout.preferredWidth: (secondTally.empty ? 24 : 44) + offset

        topLeftRadius: Settings.barRadius
        bottomLeftRadius: Settings.barRadius
        antialiasing: Settings.barRadius > 0

        WorkspaceTally {
            displayEmpty: true

            start: 1
            height: 16
            width: 16

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: (4 + parent.offset)
        }

        WorkspaceTally {
            id: secondTally

            start: 6
            height: 16
            width: 16

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 4
        }
    }

    Rectangle {
        color: Settings.bg0
        height: 32
        Layout.preferredWidth: childrenRect.width + 16

        Text {
            color: ToplevelManager.activeToplevel?.activated ? Settings.primary1 : Settings.primary1.replace("#", "#cc")
            text: ToplevelManager.activeToplevel?.activated ? Settings.replaceId(ToplevelManager.activeToplevel.appId) : "「  %1  」".arg(["", "一", "二", "三", "四", "五", "六", "七", "八", "九", "零"][Hyprland.focusedWorkspace?.id] || Hyprland.focusedWorkspace?.id)

            font.pointSize: 12
            font.family: ToplevelManager.activeToplevel?.activated ? "JetBrains Mono" : "Noto Sans CJK JP"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 8
        }
    }

    Rectangle {
        visible: !thirdTally.empty || !fourthTally.empty
        color: Settings.primary0

        height: 32
        Layout.preferredWidth: fourthTally.empty ? 24 : 44

        WorkspaceTally {
            id: thirdTally
            displayEmpty: true

            start: 11
            height: 16
            width: 16

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 4
        }

        WorkspaceTally {
            id: fourthTally

            start: 16
            height: 16
            width: 16

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 4
        }
    }

    Text {
        color: Settings.plain
        text: ToplevelManager.activeToplevel?.title.replace(new RegExp("\\s+.\\s+" + ToplevelManager.activeToplevel.appId.replace(/-\w+?$/i, suffix => "(" + suffix + ")?"), "i"), '') || ""
        visible: ToplevelManager.activeToplevel?.activated || false
        Layout.preferredWidth: bar.width * 0.4
        elide: Text.ElideRight

        font.pointSize: 11
        font.family: "JetBrains Mono"
        leftPadding: 8
    }
}
