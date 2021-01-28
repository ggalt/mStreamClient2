import QtQuick 2.15
import QtQuick.Controls 2.15
import "../resourceElements"

ScrollingListView {
    id: artistPage
    objectName: "artistPage"

    formName: "Artist List"
    myModel: artistListJSONModel.model
    highlightLetter: myCurrentItem.myData.name[0]

    property color delegateBackground: "#80808080"
    property color delegatePressed: "lightgrey"

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    myDelegate: SwipeDelegate {
        id: artistDelegate
        height: 42
        width: artistPage.width

        background: Rectangle {
            color: "transparent"
        }

        property variant myData: model

        onPressed: listDelegateRect.color = delegatePressed
        onReleased: listDelegateRect.color = delegateBackground

        onClicked: {
            artistDelegate.ListView.view.currentIndex=index
            myLogger.log("click for:", listDelegateRect.delegateLabel.text)
            mainApp.requestArtistAlbums(listDelegateRect.delegateLabel.text)
        }

        onPressAndHold: {
            myLogger.log("press and hold for replace tracks")
        }

        swipe.left: Label {
            id: addLabel
            text: qsTr("Add Tracks")
            color: "white"
            verticalAlignment: Label.AlignVCenter
            padding: 12
            height: parent.height
            anchors.left: parent.left

//            SwipeDelegate.onClicked: {
//                myLogger.log("add tracks", listDelegateRect.height, artistDelegate.height)
//                swipe.close()
//            }

            background: Rectangle {
                color: addLabel.SwipeDelegate.pressed ? Qt.darker("tomato", 1.1) : "tomato"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        myLogger.log("add tracks", listDelegateRect.height, artistDelegate.height)
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
//                myLogger.log("replace tracks", listDelegateRect.height, artistDelegate.height)
//                swipe.close()
//            }

            background: Rectangle {
                color: replaceLabel.SwipeDelegate.pressed ? Qt.darker("tomato", 1.1) : "tomato"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        myLogger.log("replace tracks", listDelegateRect.height, artistDelegate.height)
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
            color: delegateBackground
            clip: true
            hasImage: false
            delegateLabel.text: model.name
        }

    }

}
