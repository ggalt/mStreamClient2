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

//    myDelegate: ListDelegateRect {
//        id: albumDelegate
//        objectName: "albumDelegate"
//        property variant myData: model

//        //        x: 0
//        height: 87
//        width: parent.width
//        //        anchors.top: parent.top
//        //        anchors.bottom: parent.bottom
//        //        anchors.topMargin: 1
//        //        anchors.bottomMargin: 1
//        color: "#80808080"
//        clip: true
//        hasImage: true
//        delegateLabel.text: model.name
//        delegateImage.source: mainWindow.getServerURL()+"/album-art/"+model.album_art_file+"?token="+mainWindow.getToken()

//        property string delegateDrop: "albumDelegate"
////        Drag.active: delegateMouseArea.drag.active
////        Drag.keys: [delegateDrop]
//        Drag.active: true
////        states: State {
////            when: delegateMouseArea.drag.active
////            ParentChange {
////                target: albumDelegate
////                parent: mainWindow.nowPlayingForm
////            }
////        }

//        function dropDelegate() {
//            var localPoint = Qt.point(delegateMouseArea.mouseX, delegateMouseArea.mouseY)
//            myLogger.log("Dropped On:", localPoint)
//        }

//        MouseArea {
//            id: delegateMouseArea
//            anchors.fill: parent
//            property bool wasClicked: false

//            onPressed: albumDelegate.color = "lightgrey"

//            onReleased: {
//                albumDelegate.color = "#80808080"
//                myLogger.log("mouse says:", mouse.x, mouse.y)
//                myLogger.log("Drop Area contains Drag?", listManager.dropAreaAlias.containsDrag)
//                albumDelegate.dropDelegate()
//            }

//            onClicked: {
//                albumDelegate.ListView.view.currentIndex=index
//                myLogger.log("click for:", albumDelegate.delegateLabel.text)
//                wasClicked=true
//            }

//            onPressAndHold: {
//                myLogger.log("Press and hold")
//                mainApp.updatePlaylist(albumDelegate.delegateLabel.text, "album", "add")
//            }

//            drag.target: albumDelegate
//            drag.axis: Drag.XAndYAxis
//            //            drag.maximumX: albumPage.width
//            //            drag.maximumY: albumPage.height

//            //            onExited: {
//            //                if(!wasClicked) {
//            //                    myLogger.log("exited mouse area while dragging delegate")
//            //                    mainApp.updatePlaylist(albumDelegate.delegateLabel.text, "album", "replace")
//            //                } else {
//            //                    wasClicked = false  // reset value
//            //                }
//            //            }
//        }
//    }


    myDelegate: SwipeDelegate {
        id: albumDelegate
        height: 87
        width: albumPage.width

        background: Rectangle {
            color: "transparent"
        }

        property variant myData: model
        onPressed: listDelegateRect.color = "lightgrey"
        onReleased: listDelegateRect.color = "white"

        onClicked: {
            albumDelegate.ListView.view.currentIndex=index
            myLogger.log("click for:", listDelegateRect.delegateLabel.text)
        }

        onPressAndHold: {
            myLogger.log("press and hold for replace tracks")
            mainApp.updatePlaylist(listDelegateRect.delegateLabel.text, "album", "replace")
        }

        //        swipe.onCompleted: {
        //            if( swipe.leftItem !== null ) {
        //                mainApp.updatePlaylist(listDelegateRect.delegateLabel.text, "album", "add")
        //                myLogger.log("swipe left?",swipe.leftItem.visible)
        //            } else if( swipe.rightItem !== null ) {
        //                mainApp.updatePlaylist(listDelegateRect.delegateLabel.text, "album", "replace")
        //                myLogger.log("swipe right?",swipe.rightItem.visible)
        //            }
        //            swipe.close()
        //        }

        swipe.left: Label {
            id: addLabel
            text: qsTr("Add Tracks")
            color: "white"
            verticalAlignment: Label.AlignVCenter
            padding: 12
            height: parent.height
            anchors.left: parent.left

            //            SwipeDelegate.onClicked: {
            //                myLogger.log("add tracks for", listDelegateRect.delegateLabel.text)
            //                mainApp.updatePlaylist(listDelegateRect.delegateLabel.text, "album", "add")
            //                swipe.close()
            //            }

            background: Rectangle {
                color: addLabel.SwipeDelegate.pressed ? Qt.darker("tomato", 1.1) : "tomato"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        myLogger.log("add tracks for", listDelegateRect.delegateLabel.text)
                        mainApp.updatePlaylist(listDelegateRect.delegateLabel.text, "album", "add")
                        swipe.close()
                    }
                }
            }
        }

        swipe.right: Label {
            id: replaceLabel
            text: qsTr("Replace Tracks")
            color: "white"
            verticalAlignment: Label.AlignVCenter
            padding: 12
            height: parent.height
            anchors.right: parent.right

            //            SwipeDelegate.onClicked: {
            //                myLogger.log("replace tracks", listDelegateRect.height, albumDelegate.height)
            //                mainApp.updatePlaylist(listDelegateRect.delegateLabel.text, "album", "replace")
            //                swipe.close()
            //            }

            background: Rectangle {
                color: replaceLabel.SwipeDelegate.pressed ? Qt.darker("tomato", 1.1) : "tomato"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        myLogger.log("replace tracks", listDelegateRect.height, albumDelegate.height)
                        mainApp.updatePlaylist(listDelegateRect.delegateLabel.text, "album", "replace")
                        swipe.close()
                    }
                }
            }
        }

        contentItem: ListDelegateRect {
            id: listDelegateRect
            x: 0
            width: parent.width
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 1
            anchors.bottomMargin: 1
            color: "#80808080"
            clip: true
            hasImage: true
            delegateLabel.text: model.name
            delegateImage.source: mainWindow.getServerURL()+"/album-art/"+model.album_art_file+"?token="+mainWindow.getToken()
        }

        swipe.transition: Transition {
            SmoothedAnimation { velocity: 3; easing.type: Easing.InOutCubic }
        }

    }

}
