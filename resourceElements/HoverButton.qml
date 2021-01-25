import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12

MouseArea {
    objectName: "hoverButton"

    property alias shadowHorzOffset: shadow.horizontalOffset
    property alias shadowVertOffset: shadow.verticalOffset
    property alias shadowRadius: shadow.radius
    property alias shadowSamples: shadow.samples
    property alias shadowColor: shadow.color

    property alias imageSource: buttonImage.source

    property bool hasLabel: true
    property alias labelText: imageLabel.text
    property alias labelFont: imageLabel.font
    property alias labelColor: imageLabel.color
    property alias lableOpacity: imageLabel.opacity

    property alias backgroundColor: backgroundRect.color
    property alias backgroundOpacity: backgroundRect.opacity

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    state: "unPressedState"

    onPressed: {
        state = "pressedState"
    }
    onReleased: {
        state = "unPressedState"
    }

    function float2int (value) {
        return value | 0;
    }

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
    }

    DropShadow {
        id: shadow
        anchors.fill: buttonImage
        source: buttonImage
    }

    Image {
        id: buttonImage

        property int savedHorzOffset: 3
        property int savedVertOffset: 3

        anchors.top: parent.top
        anchors.bottom: hasLabel ? imageLabel.top : parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width

        smooth: true
        fillMode: Image.PreserveAspectFit
        asynchronous: true
//        onStatusChanged: {
//            if (status == Image.Ready) {
//                myLogger.log('Loaded: sourceSize ==', sourceSize);
//            }
//        }
    }

    Text {
        id: imageLabel
        visible: hasLabel
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    states: [
        State {
            name: "unPressedState"
            PropertyChanges {
                target: shadow
                horizontalOffset: buttonImage.savedHorzOffset
                verticalOffset: buttonImage.savedVertOffset
                scale: 1.0
            }
        },
        State {
            name: "pressedState"
            PropertyChanges {
                target: shadow
                horizontalOffset: 0
                verticalOffset: 0
                scale: 0.95
            }
        }
    ]

    Component.onCompleted: {
        buttonImage.savedHorzOffset = shadow.horizontalOffset
        buttonImage.savedVertOffset = shadow.verticalOffset
        myLogger.log(buttonImage.savedHorzOffset,buttonImage.savedVertOffset)
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:1.25;height:480;width:640}
}
##^##*/
