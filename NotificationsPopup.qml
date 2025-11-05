import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

PopupWindow {
    anchor.window: bar
    anchor.rect.x: bar.width - width - 8
    anchor.rect.y: bar.height + 16
    implicitWidth: 400
    color: "transparent"
    visible: Notifications.display.length
    implicitHeight: Math.min(16 + notificationDisplay.contentHeight, bar.screen?.height - 128)

    ListView {
        id: notificationDisplay
        implicitWidth: parent.width
        implicitHeight: 1440
        height: parent.height

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

        model: Notifications.display
        delegate: Rectangle {
            id: notification
            required property var model

            color: Settings.bg0.replace("#", "#cc")

            border.color: Settings.comp0.replace("#", "#cc")
            border.pixelAligned: false
            border.width: 2
            radius: 10
            antialiasing: true

            height: childrenRect.height + 16
            width: parent.width - 16

            ColumnLayout {
                anchors.top: parent.top
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.leftMargin: 8
                Layout.preferredWidth: parent.width - 16
                spacing: 2

                RowLayout {
                    spacing: 4
                    visible: model.appName
                    Layout.preferredWidth: parent.width

                    IconImage {
                        source: model.appIcon ? (model.appIcon.match("://") ? "" : "image://icon/") + model.appIcon : ""
                        implicitSize: 16
                        visible: model.appIcon?.length > 0
                    }

                    Text {
                        Layout.preferredWidth: model.appIcon ? (parent.width - 40) : (parent.width - 20)
                        text: model.appName
                        font.pointSize: 11
                        font.bold: true
                        font.family: "JetBrains Mono"
                        elide: Text.ElideRight
                        color: Settings.plain
                    }

                    MouseArea {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16

                        enabled: !model.isSeparator
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton
                        cursorShape: Qt.PointingHandCursor

                        onClicked: event => {
                            Notifications.ipc.dismiss(model.id);
                        }

                        Text {
                            text: ""
                            font.pointSize: 11
                            color: Settings.comp0
                        }
                    }
                }

                Text {
                    visible: model.summary
                    Layout.preferredWidth: 368
                    elide: Text.ElideRight

                    text: model.summary
                    font.pointSize: 11
                    font.family: "JetBrains Mono"
                    color: Settings.plain
                }

                Text {
                    visible: model.body
                    Layout.preferredWidth: 368
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap

                    text: model.body
                    font.pointSize: 11
                    font.family: "JetBrains Mono"
                    color: Settings.plain
                }

                ListView {
                    visible: notification.model.actions?.length
                    Layout.preferredWidth: 368
                    Layout.preferredHeight: 20
                    model: notification.model.actions
                    orientation: ListView.Horizontal
                    spacing: 8

                    delegate: Text {
                        required property var model

                        text: model.text
                        font.pointSize: 11
                        font.family: "JetBrains Mono"
                        color: mouse.containsMouse ? Settings.comp0 : Settings.comp0.replace("#", "#cc")

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            enabled: true
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: event => {
                                model.modelData.invoke();
                            }
                        }
                    }
                }
            }
        }
    }
}
