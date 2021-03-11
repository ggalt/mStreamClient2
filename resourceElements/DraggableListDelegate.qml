import QtQuick 2.15
import QtQuick.Controls 2.15
import "../resourceElements"

Rectangle {
    id: _draggableListDelegate
    objectName: "draggableListDelegateRect"

    property alias delegateLabel: _delegateLabel
    property alias delegateImage: _delegateImage
    property alias source: _delegateImage.source
    property alias textPointSize: _delegateLabel.font.pointSize
    property alias delegateMouseArea: _delegateMouseArea
    property bool hasImage: false
    property string actionItem
    property string actionCommand
    property color delegateBackgroundColor: "#66808080"
    property color delegatePressedColor: "lightgrey"

    color: "transparent"      // transparent background
    //    color: "#80808080"    // 50% transparent grey background

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    Rectangle {
        id: _delegateRect
        color: delegateBackgroundColor
        anchors.fill: parent
        anchors.margins: 1
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


    ///////////////////////////////////////////////////////////////////////////////
    //// DRAG ELEMENTS
    ///////////////////////////////////////////////////////////////////////////////

    property alias dragActive: _delegateMouseArea.drag.active
    property bool overDropZone: false
    property int originalY: y
    property int originalX: x


    function enterDropZone() {
        overDropZone=true
    }

    function exitDropZone() {
        overDropZone=false
    }

    function dropSuccess() {
        if(overDropZone) {
            myLogger.log("Drop Success command:", actionItem, actionCommand, "add")
            mainApp.updatePlaylist(actionItem, actionCommand, "add")
        }
    }

    // See https://stackoverflow.com/questions/24532317/new-drag-and-drop-mechanism-does-not-work-as-expected-in-qt-quick-qt-5-3
    // explains why Drag and Drop sucks in QML and provides the solution used here.

    // This can be used to get event info for drag starts and
    // stops instead of onDragStarted/onDragFinished, since
    // those will never be called if we don't use Drag.active
    onDragActiveChanged: {
        if (dragActive) {
            Drag.active = true
            print("drag started")
            originalX = x
            originalY = y
            _draggableListDelegate.state="DRAG"
            //            Drag.start();
        } else {
            Drag.active = false
            print("drag finished")
            if(!overDropZone) {
                console.log("Not Dropped in Drop Zone")
                _draggableListDelegate.state="FAILURE"
            } else {
                _draggableListDelegate.state="SUCCESS"
            }

            Drag.drop();
        }
    }

    Drag.dragType: Drag.Automatic
//    Drag.active: _delegateMouseArea.drag.active       //this causes a binding loop on "active" so we set it manuall in "onDragActiveChanged" above

    ///////////////////////////////////////////////////////////////////////////////
    //// MOUSEAREA ELEMENTS
    ///////////////////////////////////////////////////////////////////////////////

    MouseArea {
        id: _delegateMouseArea
        anchors.fill: parent

        drag.target: _draggableListDelegate
        drag.axis: Drag.XAxis
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: {
            _delegateRect.color = delegatePressedColor
            _delegateRect.grabToImage(function(result) {
                myLogger.log("result URL:", result.url)
                parent.Drag.imageSource = result.url
            })
        }
        onReleased: {
            _delegateRect.color = delegateBackgroundColor
        }

        onPressAndHold: {
            myLogger.log("Press and hold")
            if(mouse.button === Qt.RightButton) {
                mainApp.updatePlaylist(actionItem, actionCommand, "add")
            } else {
                mainApp.updatePlaylist(_draggableListDelegate.actionItem, actionCommand, "replace")
            }
        }
    }
    states: [
        State {
            name: "SUCCESS"
            PropertyChanges {
                target: _draggableListDelegate
                scale: 0.0
            }
        },
        State {
            name: "FAILURE"
            PropertyChanges {
                target: _draggableListDelegate
                x: originalX
                y: originalY
            }
        },
        State {
            name: "DRAG"
            PropertyChanges {
                target: _draggableListDelegate
                opacity: 0.6
            }
        },
        State {
            name: "INACTIVE"
            PropertyChanges {
                target: _draggableListDelegate
                opacity: 1.0
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "SUCCESS"

            NumberAnimation {
                target: _draggableListDelegate
                property: "scale"
                duration: 200
                easing.type: Easing.InOutQuad
            }
        },
        Transition {
            from: "*"
            to: "FAILURE"

            NumberAnimation {
                target: _draggableListDelegate
                properties: "x,y"
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    ]

}
