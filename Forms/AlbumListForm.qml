import QtQuick 2.15
import QtQuick.Controls 2.15
import "../resourceElements"

ScrollingListView {
    id: albumPage
    objectName: "albumPage"

    formName: "Album List"
    myModel: albumListJSONModel.model
    highlightLetter: myCurrentItem.myData.name[0]
    clip: false

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    myDelegate: ListDelegateRect {
        id: albumDelegate
        objectName: "albumDelegate"
        property variant myData: model

        height: 87
        width: parent.width
        //        anchors.top: parent.top
        //        anchors.bottom: parent.bottom
        //        anchors.topMargin: 1
        //        anchors.bottomMargin: 1
        color: "#80808080"
        clip: true
        hasImage: true
        delegateLabel.text: model.name
        delegateImage.source: mainWindow.getServerURL()+"/album-art/"+model.album_art_file+"?token="+mainWindow.getToken()
        textPointSize:  mainWindow.getTextPointSize()

        ///////////////////////////////////////////////////////////////////////////////
        //// DRAG ELEMENTS
        ///////////////////////////////////////////////////////////////////////////////

        property string delegateDrop: "albumDelegate"
        property bool dragActive: delegateMouseArea.drag.active
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
                mainApp.updatePlaylist(albumDelegate.delegateLabel.text, "album", "add")
            }
        }

        // See https://stackoverflow.com/questions/24532317/new-drag-and-drop-mechanism-does-not-work-as-expected-in-qt-quick-qt-5-3
        // explains why Drag and Drop sucks in QML and provides the solution used here.

        // This can be used to get event info for drag starts and
        // stops instead of onDragStarted/onDragFinished, since
        // those will never be called if we don't use Drag.active
        onDragActiveChanged: {
            if (dragActive) {
                print("drag started")
                originalX = x
                originalY = y
                albumDelegate.state="DRAG"
                Drag.start();
            } else {
                print("drag finished")
                if(!overDropZone) {
                    console.log("Not Dropped in Drop Zone")
                    albumDelegate.state="FAILURE"
                } else {
                    albumDelegate.state="SUCCESS"
                }

                Drag.drop();
            }
        }

        Drag.dragType: Drag.Automatic
        Drag.imageSource: albumDelegate.source

        ///////////////////////////////////////////////////////////////////////////////
        //// MOUSEAREA ELEMENTS
        ///////////////////////////////////////////////////////////////////////////////

        MouseArea {
            id: delegateMouseArea
            anchors.fill: parent

            drag.target: albumDelegate

            onPressed: albumDelegate.color = "lightgrey"
            onReleased: {
                albumDelegate.color = "#80808080"
            }

            onClicked: {
                albumDelegate.ListView.view.currentIndex=index
                myLogger.log("click for:", albumDelegate.delegateLabel.text)
            }

            onPressAndHold: {
                myLogger.log("Press and hold")
                mainApp.updatePlaylist(albumDelegate.delegateLabel.text, "album", "replace")
            }

        }
        states: [
            State {
                name: "SUCCESS"
                PropertyChanges {
                    target: albumDelegate
                    scale: 0.0
                }
            },
            State {
                name: "FAILURE"
                PropertyChanges {
                    target: albumDelegate
                    x: originalX
                    y: originalY
                }
            },
            State {
                name: "DRAG"
                PropertyChanges {
                    target: albumDelegate
                    opacity: 0.6
                }
            },
            State {
                name: "INACTIVE"
                PropertyChanges {
                    target: albumDelegate
                    opacity: 1.0
                }
            }
        ]

        transitions: [
            Transition {
                from: "*"
                to: "SUCCESS"

                NumberAnimation {
                    target: albumDelegate
                    property: "scale"
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            },
            Transition {
                from: "*"
                to: "FAILURE"

                NumberAnimation {
                    target: albumDelegate
                    properties: "x,y"
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        ]

    }


//    myDelegate: SwipeDelegate {
//        id: albumDelegate
//        height: 87
//        width: albumPage.width

//        background: Rectangle {
//            color: "transparent"
//        }

//        property variant myData: model
//        onPressed: listDelegateRect.color = "lightgrey"
//        onReleased: listDelegateRect.color = "white"

//        onClicked: {
//            albumDelegate.ListView.view.currentIndex=index
//            myLogger.log("click for:", listDelegateRect.delegateLabel.text)
//        }

//        onPressAndHold: {
//            myLogger.log("press and hold for replace tracks")
//            mainApp.updatePlaylist(listDelegateRect.delegateLabel.text, "album", "replace")
//        }

//        //        swipe.onCompleted: {
//        //            if( swipe.leftItem !== null ) {
//        //                mainApp.updatePlaylist(listDelegateRect.delegateLabel.text, "album", "add")
//        //                myLogger.log("swipe left?",swipe.leftItem.visible)
//        //            } else if( swipe.rightItem !== null ) {
//        //                mainApp.updatePlaylist(listDelegateRect.delegateLabel.text, "album", "replace")
//        //                myLogger.log("swipe right?",swipe.rightItem.visible)
//        //            }
//        //            swipe.close()
//        //        }

//        swipe.left: Label {
//            id: addLabel
//            text: qsTr("Add Tracks")
//            color: "white"
//            verticalAlignment: Label.AlignVCenter
//            padding: 12
//            height: parent.height
//            anchors.left: parent.left

//            //            SwipeDelegate.onClicked: {
//            //                myLogger.log("add tracks for", listDelegateRect.delegateLabel.text)
//            //                mainApp.updatePlaylist(listDelegateRect.delegateLabel.text, "album", "add")
//            //                swipe.close()
//            //            }

//            background: Rectangle {
//                color: addLabel.SwipeDelegate.pressed ? Qt.darker("tomato", 1.1) : "tomato"
//                MouseArea {
//                    anchors.fill: parent
//                    onClicked: {
//                        myLogger.log("add tracks for", listDelegateRect.delegateLabel.text)
//                        mainApp.updatePlaylist(listDelegateRect.delegateLabel.text, "album", "add")
//                        swipe.close()
//                    }
//                }
//            }
//        }

//        swipe.right: Label {
//            id: replaceLabel
//            text: qsTr("Replace Tracks")
//            color: "white"
//            verticalAlignment: Label.AlignVCenter
//            padding: 12
//            height: parent.height
//            anchors.right: parent.right

//            //            SwipeDelegate.onClicked: {
//            //                myLogger.log("replace tracks", listDelegateRect.height, albumDelegate.height)
//            //                mainApp.updatePlaylist(listDelegateRect.delegateLabel.text, "album", "replace")
//            //                swipe.close()
//            //            }

//            background: Rectangle {
//                color: replaceLabel.SwipeDelegate.pressed ? Qt.darker("tomato", 1.1) : "tomato"
//                MouseArea {
//                    anchors.fill: parent
//                    onClicked: {
//                        myLogger.log("replace tracks", listDelegateRect.height, albumDelegate.height)
//                        mainApp.updatePlaylist(listDelegateRect.delegateLabel.text, "album", "replace")
//                        swipe.close()
//                    }
//                }
//            }
//        }

//        contentItem: ListDelegateRect {
//            id: listDelegateRect
//            x: 0
//            width: parent.width
//            anchors.top: parent.top
//            anchors.bottom: parent.bottom
//            anchors.topMargin: 1
//            anchors.bottomMargin: 1
//            color: "#80808080"
//            clip: true
//            hasImage: true
//            delegateLabel.text: model.name
//            delegateImage.source: mainWindow.getServerURL()+"/album-art/"+model.album_art_file+"?token="+mainWindow.getToken()
//        }

//        swipe.transition: Transition {
//            SmoothedAnimation { velocity: 3; easing.type: Easing.InOutCubic }
//        }

//    }

}
