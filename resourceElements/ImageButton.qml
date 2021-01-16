import QtQuick 2.13
import QtQuick.Controls 2.13

Button {

    property alias buttonImage: btnImage.source

    onPressed: btnShade.opacity=0.30
    onReleased: btnShade.opacity=0

    Image {
        id: btnImage
        anchors.fill: parent
        Rectangle {
            id: btnShade
            anchors.fill: parent
            opacity: 0
            color: "grey"
        }
    }
}
