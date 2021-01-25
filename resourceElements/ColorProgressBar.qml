import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: _progressBar
    objectName: "progressBar"

    property real currentValue

    property alias backgroundColor: backgroundRect.color
    property alias backgroundGradient: backgroundRect.gradient
    property alias backgroundOpacity: backgroundRect.opacity
    property alias backgroundBorder: backgroundRect.border
    property alias backgroundRadius: backgroundRect.radius

    property alias progressColor: progressRect.color
    property alias progressGradient: progressRect.gradient
    property alias progressOpacity: progressRect.opacity
    property alias progressBorder: progressRect.border
    property alias progressRadius: progressRect.radius

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    onCurrentValueChanged: {
        progressRect.width = currentValue * backgroundRect.width
    }

    Rectangle {
        id: backgroundRect
        anchors.fill: parent

        Rectangle {
            id: progressRect
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
    }

}
