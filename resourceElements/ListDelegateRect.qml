import QtQuick 2.15
import QtQuick.Controls 2.15
import "../resourceElements"

Rectangle {
    id: listDelegateRect
    objectName: "listDelegateRect"

    property alias delegateLabel: _delegateLabel
    property alias delegateImage: _delegateImage
    property alias source: _delegateImage.source
    property alias textPointSize: _delegateLabel.font.pointSize
    property bool hasImage: false

    color: "transparent"      // transparent background
    //    color: "#80808080"    // 50% transparent grey background

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    Text {
        id: _delegateLabel
        anchors.left: hasImage ? _delegateImage.right : parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        height: parent.height
        font.family: "Arial"
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
    }

    Image {
        id: _delegateImage
        width: height
        height: parent.height - 4
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        horizontalAlignment: Image.AlignHCenter
        anchors.leftMargin: 5
        fillMode: Image.PreserveAspectFit
        visible: hasImage
        source: "../images/music_default2.png"
    }

}
