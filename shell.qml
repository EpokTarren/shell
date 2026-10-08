import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland
import Quickshell.Hyprland

Variants {
    model: Quickshell.screens
    delegate: Component {
        PanelWindow {
            id: bar
            color: "transparent"

            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            margins {
                top: Settings.gap
                left: Settings.gap
                right: Settings.gap
            }

            implicitHeight: 32

            Rectangle {
                color: Settings.bg0.replace("#", "#cc")
                anchors.fill: parent
                anchors.leftMargin: 32
                anchors.rightMargin: 32
            }

            Left {
                id: left
                bar: bar
            }

            Text {
                color: Settings.plain
                text: ToplevelManager.activeToplevel?.title.replace(new RegExp("\\s+.\\s+" + ToplevelManager.activeToplevel.appId.replace(/-\w+?$/i, suffix => "(" + suffix + ")?"), "i"), '') || ""
                visible: ToplevelManager.activeToplevel?.activated || false
                elide: Text.ElideRight
                font.pointSize: 11
                font.family: "JetBrains Mono"

                anchors.left: left.right
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, bar.width * 0.5 - left.width - 16)
                leftPadding: 8

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: true
                    acceptedButtons: Qt.LeftButton

                    onClicked: {
                        if (ToplevelManager.activeToplevel?.activated)
                            Quickshell.clipboardText = ToplevelManager.activeToplevel.title;
                    }
                }
            }

            Rectangle {
                color: Settings.bg0.replace("#", "#80")
                height: 32
                visible: Media.text
                anchors.right: right.left
                width: mediaText.width

                Text {
                    id: mediaText
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, bar.width * 0.5 - right.width - 16)
                    elide: Text.ElideRight
                    leftPadding: 8
                    rightPadding: 8

                    text: Media.text
                    color: Media.player?.isPlaying ? Settings.comp0 : Settings.comp0.replace("#", "#cc")
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

            Right {
                id: right
                bar: bar
            }

            NotificationsPopup {}
        }
    }
}
