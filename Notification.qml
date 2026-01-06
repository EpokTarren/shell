import QtQuick
import Quickshell.Widgets
import QtQuick.Layouts

Rectangle {
    id: notification
    required property var model

    visible: model != null

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
            Layout.preferredWidth: parent.Layout.preferredWidth

            IconImage {
                source: model.appIcon ? (model.appIcon.match("://") ? "" : "image://icon/") + model.appIcon : ""
                implicitSize: 16
                visible: model.appIcon?.length > 0
            }

            Text {
                Layout.preferredWidth: model.appIcon ? (parent.width - 40) : (parent.width - 20)
                text: model.appName || null
                font.pointSize: 12
                font.bold: true
                font.family: "JetBrains Mono"
                elide: Text.ElideRight
                color: Settings.comp0
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
                    font.pointSize: 12
                    color: Settings.comp0
                    anchors.centerIn: parent
                }
            }
        }

        Text {
            visible: model.summary?.length > 0
            Layout.preferredWidth: parent.Layout.preferredWidth
            elide: Text.ElideRight

            text: model.summary || null
            textFormat: Text.StyledText
            font.pointSize: 12
            font.family: "JetBrains Mono"
            color: Settings.plain
        }

        Text {
            visible: model.body?.length > 0
            Layout.preferredWidth: parent.Layout.preferredWidth
            maximumLineCount: 2
            elide: Text.ElideRight
            wrapMode: Text.Wrap

            text: model.body || null
            textFormat: Text.StyledText
            font.pointSize: 11
            font.family: "JetBrains Mono"
            color: Settings.plain
        }

        ListView {
            visible: notification.model.actions?.length > 0
            Layout.preferredWidth: parent.Layout.preferredWidth
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

        Rectangle {
            visible: model.progress != undefined
            Layout.preferredWidth: parent.Layout.preferredWidth
            Layout.preferredHeight: 4
            Layout.topMargin: 4
            radius: 2
            color: Settings.bg2

            Rectangle {
                width: Math.round(parent.width * Math.min(1.0, model.progress))
                height: parent.height
                radius: 2
                color: Settings.comp0
            }
        }
    }
}
