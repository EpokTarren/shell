import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Rectangle {
    color: Settings.bg0
    height: 32
    Layout.preferredWidth: childrenRect.width + 16

    QsMenuOpener {
        id: menu
    }

    PopupWindow {
        anchor.window: bar
        anchor.rect.x: bar.width - width - 128
        anchor.rect.y: bar.height
        implicitWidth: 196
        implicitHeight: (menuListView.contentHeight ?? 0) + 16
        visible: !!menu.menu
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Settings.bg0
            antialiasing: true
            radius: 10
        }

        ListView {
            id: menuListView
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 8
            implicitWidth: parent.width
            implicitHeight: 1000

            verticalLayoutDirection: ListView.TopToBottom
            orientation: ListView.Vertical

            model: menu.children.values
            delegate: Rectangle {
                required property var model
                width: parent.width
                height: model.isSeparator ? 16 : 24
                color: !model.isSeparator && mouse.containsMouse ? Settings.bg2 : "transparent"

                Text {
                    visible: !model.isSeparator
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    width: parent.width - 16
                    text: model.text
                    font.pointSize: 11
                    font.family: "JetBrains Mono"
                    elide: Text.ElideRight
                    color: mouse.containsMouse ? Settings.comp0 : Settings.plain
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent

                    enabled: !model.isSeparator
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    cursorShape: model.isSeparator ? undefined : Qt.PointingHandCursor

                    onClicked: event => {
                        model.modelData.triggered();
                        menu.menu = null;
                    }
                }
            }
        }
    }

    ListView {
        anchors.centerIn: parent
        width: childrenRect.width
        height: 32
        spacing: 8
        layoutDirection: Qt.LeftToRight
        orientation: ListView.Horizontal

        model: SystemTray.items.values
        delegate: IconImage {
            required property var model

            anchors.verticalCenter: parent.verticalCenter
            source: model.icon
            implicitSize: 22

            MouseArea {
                anchors.fill: parent

                enabled: true
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor

                onClicked: event => {
                    if (model.onlyHasMenu || (model.hasMenu && event.button == Qt.RightButton)) {
                        if (menu.menu != model.modelData.menu)
                            menu.menu = model.modelData.menu;
                        else
                            menu.menu = null;
                    } else if (event.button == Qt.LeftButton) {
                        model.modelData.activate();
                    }

                    event.accepted = true;
                }
            }
        }
    }
}
