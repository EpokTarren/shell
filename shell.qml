import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
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
                top: 8
                left: 8
                right: 8
            }

            implicitHeight: 32

            Rectangle {
                color: Settings.bg0.replace("#", "#cc")
                anchors.fill: parent
                anchors.leftMargin: 32
                anchors.rightMargin: 32
            }

            Left {
                bar: bar
            }
            Right {
                bar: bar
            }

            NotificationsPopup {}
        }
    }
}
