import QtQuick
import QtQuick.Shapes
import Quickshell.Hyprland
import Quickshell.Wayland

Item {
    required property var start
    implicitWidth: 10
    implicitHeight: 10
    transform: [
        Scale {
            xScale: width / 10
            yScale: height / 10
        }
    ]

    readonly property var paths: ["M 0.5 0 L 9.5 0 L 9.5 1 L 0.5 1 L 0.5 0", "M 4.5 0.5 L 5.5 0.5 L 5.5 9.5 L 4.5 9.5 L 4.5 0.5", "M 4.5 5 L 8.5 5 L 8.5 6 L 4.5 6 L 4.5 5", "M 2 2.5 L 3 2.5 L 3 9.5 L 2 9.5 L 2 2.5", "M 0 9 L 10 9 L 10 10 L 0 10 L 0 9",]

    readonly property var inactivePaths: Hyprland.workspaces.values.filter(ws => ws.id >= start && ws.id < start + 5 && !ws.active && !ws.urgent).map(ws => paths[ws.id - start]).join(" ")

    readonly property var urgentPaths: Hyprland.workspaces.values.filter(ws => ws.id >= start && ws.id < start + 5 && !ws.active && ws.urgent).map(ws => paths[ws.id - start]).join(" ")

    Shape {
        objectName: "tally"

        ShapePath {
            strokeColor: "transparent"
            fillColor: Settings.primary2
            fillRule: ShapePath.WindingFill
            PathSvg {
                path: inactivePaths
            }
        }

        Timer {
            id: timer
            property bool bright: false

            running: urgentPaths.length
            repeat: true
            interval: 1000
            onTriggered: bright = !bright
        }

        ShapePath {
            strokeColor: "transparent"
            fillColor: timer.bright ? Settings.primary3 : Settings.primary2
            fillRule: ShapePath.WindingFill
            PathSvg {
                path: urgentPaths
            }
        }

        ShapePath {
            strokeColor: "transparent"
            fillColor: ToplevelManager.activeToplevel?.activated ? Settings.plain : Settings.primary2
            fillRule: ShapePath.WindingFill
            PathSvg {
                path: paths[Hyprland.focusedWorkspace?.id - start] || ""
            }
        }
    }
}
