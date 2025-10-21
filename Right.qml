import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io

RowLayout {
    id: sysinfo
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right
    layoutDirection: Qt.LeftToRight
    spacing: 0

    property var bar

    Rectangle {
        color: Settings.bg0.replace("#", "#80")
        height: 32
        Layout.preferredWidth: childrenRect.width + 16
        visible: Media.text

        Text {
            anchors.centerIn: parent
            width: Math.min(implicitWidth, bar.width * 0.4 - 16)
            elide: Text.ElideRight

            text: Media.text
            color: Settings.comp0
            font.pointSize: 11
            font.family: "JetBrains Mono"
        }
    }

    Tray {}

    Rectangle {
        color: Settings.bg0
        height: 32
        width: 36
        visible: UPower.displayDevice.isLaptopBattery && !UPower.onBattery && UPower.displayDevice.percentage > 0.99

        Text {
            anchors.centerIn: parent
            color: Settings.comp0
            font.pointSize: 12
            text: ""
        }
    }

    Rectangle {
        color: Settings.bg0
        height: 32
        width: 36
        visible: UPower.displayDevice.isLaptopBattery && (UPower.displayDevice.percentage <= 0.99 || UPower.onBattery)

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2

            color: UPower.onBattery ? Settings.comp0 : Settings.comp0.replace("#", "#cc")
            font.pointSize: 10
            text: ["", "", "", "", ""][Math.floor(UPower.displayDevice.percentage * 4.45)]
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            visible: !UPower.onBattery

            color: Settings.comp0
            font.pointSize: 8
            text: ""
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 3
            font.weight: 600
            font.family: "JetBrains Mono"

            color: Settings.comp0
            font.pointSize: 8
            text: Math.floor(UPower.displayDevice.percentage * 100) + "%"
        }
    }

    Rectangle {
        color: Settings.bg0
        height: 32
        Layout.preferredWidth: childrenRect.width + 9
        visible: Settings.showBarVolume || (Settings.showBarMic && !Audio.micMuted)

        property var mic: !Settings.showBarMic || Audio.micMuted ? "" : " "
        property var volume: !Settings.showBarVolume ? "" : (Audio.muted ? "󰝟" : Audio.volume == 0 ? "" : Audio.volume < 0.5 ? "" : "")

        Text {
            color: Settings.comp0
            text: parent.mic + parent.volume

            font.pointSize: 12
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 2
        }
    }

    Rectangle {
        color: Settings.bg0
        height: 32
        Layout.preferredWidth: 28

        property var textColor: Notifications.showAll || Notifications.all.length === 0 ? Settings.comp0.replace("#", "#80") : Settings.comp0

        Text {
            color: parent.textColor
            text: ""

            font.pointSize: 14
            anchors.centerIn: parent
        }

        Text {
            color: Settings.comp0
            text: ""
            visible: Notifications.all.length > 0

            font.pointSize: 6
            font.bold: true
            font.family: "JetBrains Mono"
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 3
            anchors.rightMargin: 2
        }

        MouseArea {
            anchors.fill: parent

            enabled: Notifications.all.length > 0
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            cursorShape: Notifications.all.length == 0 ? undefined : Qt.PointingHandCursor

            onClicked: event => {
                Notifications.ipc.toggleAll();
                event.accepted = true;
            }
        }
    }

    SystemClock {
        id: clock
    }
    Rectangle {
        color: Settings.comp0
        height: 32
        Layout.preferredWidth: childrenRect.width + 14

        topRightRadius: 10
        bottomRightRadius: 10
        antialiasing: true

        Text {
            color: Settings.bg0
            text: Qt.formatDateTime(clock.date, "「hh:mm」")
            font.pointSize: 12
            font.weight: 600
            font.family: "JetBrains Mono"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8.5
        }
    }
}
