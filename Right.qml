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
            color: Media.player?.isPlaying ?Settings.comp0 : Settings.comp0.replace("#", "#cc")
            font.pointSize: 11
            font.family: "JetBrains Mono"

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: true
                acceptedButtons: Qt.LeftButton

                onClicked: if (Media.text) {
                    Quickshell.clipboardText = Media.text;
                }
            }
        }
    }

    Rectangle {
        color: Settings.bg0
        Layout.preferredHeight: 32
        Layout.preferredWidth: childrenRect.width + 8

        RowLayout {
            anchors.verticalCenter: parent.verticalCenter
            layoutDirection: Qt.LeftToRight
            Layout.preferredWidth: childrenRect.width
            spacing: 4

            Tray {}

            Text {
                visible: UPower.displayDevice.isLaptopBattery && UPower.displayDevice.state !== UPowerDeviceState.Charging && !UPower.onBattery
                color: Settings.comp0
                font.pointSize: 12
                text: ""
                rightPadding: 6
            }

            Rectangle {
                color: "#00000000"
                Layout.preferredHeight: 32
                Layout.preferredWidth: 28
                visible: UPower.displayDevice.isLaptopBattery && (UPower.displayDevice.state === UPowerDeviceState.Charging || UPower.onBattery)

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
                    rightPadding: 2
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

            Text {
                property var mic: !Settings.showBarMic || Audio.micMuted ? "" : " "
                property var volume: !Settings.showBarVolume ? "" : (Audio.muted ? "󰝟" : Audio.volume == 0 ? "" : Audio.volume < 0.5 ? "" : "")

                color: Settings.comp0
                text: mic + volume
                visible: Settings.showBarVolume || (Settings.showBarMic && !Audio.micMuted)

                font.pointSize: 12
                anchors.verticalCenter: parent.verticalCenter
                rightPadding: 4
            }

            Text {
                color: Settings.comp0
                text: Audio.output?.audio?.channels.length + "ch"
                font.pointSize: 11
                anchors.verticalCenter: parent.verticalCenter
                visible: Audio.output != null && Settings.showBarChannels(Audio.output)

                MouseArea {
                    anchors.fill: parent
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: Settings.channelsCommand.length > 0
                    acceptedButtons: Qt.LeftButton
                    onClicked: channelAction.running = true
                }
            }

            Process {
                id: channelAction
                running: false
                command: Settings.channelsCommand
            }

            Text {
                property var textColor: Notifications.showAll || Notifications.all.length === 0 ? Settings.comp0.replace("#", "#80") : Settings.comp0
                color: textColor
                text: ""
                font.pointSize: 14
                leftPadding: 4
                rightPadding: 2

                Text {
                    color: Settings.comp0
                    text: ""
                    visible: Notifications.all.length > 0

                    font.pointSize: 6
                    font.bold: true
                    font.family: "JetBrains Mono"
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: -1
                    anchors.rightMargin: 0.5
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
        }
    }

    SystemClock {
        id: clock
    }
    Rectangle {
        color: Settings.comp0
        height: 32
        Layout.preferredWidth: childrenRect.width + 8

        topRightRadius: Settings.barRadius
        bottomRightRadius: Settings.barRadius
        antialiasing: Settings.barRadius > 0

        Text {
            color: Settings.bg0
            text: Qt.formatDateTime(clock.date, "「hh:mm」")
            font.pointSize: 12
            font.weight: 600
            font.family: "JetBrains Mono"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 4

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: true
                acceptedButtons: Qt.LeftButton

                onClicked: Quickshell.clipboardText = Qt.formatDateTime(clock.date, Qt.ISODate)
            }
        }
    }
}
