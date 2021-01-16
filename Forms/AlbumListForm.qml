import QtQuick 2.13
import QtQuick.Controls 2.13
import "../resourceElements"

ScrollingListView {
    id: albumPage
    objectName: "albumPage"

    formName: "Album List"
    myModel: albumListJSONModel.model
    highlightLetter: myCurrentItem.myData.name[0]

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

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
        }

        swipe.left: Label {
            id: addLabel
            text: qsTr("Add Tracks")
            color: "white"
            verticalAlignment: Label.AlignVCenter
            padding: 12
            height: parent.height
            anchors.left: parent.left

            SwipeDelegate.onClicked: {
                myLogger.log("add tracks for", listDelegateRect.delegateLabel.text)
                mainApp.updatePlaylist(listDelegateRect.delegateLabel.text, "album", "add")
                swipe.close()
            }

            background: Rectangle {
                color: addLabel.SwipeDelegate.pressed ? Qt.darker("tomato", 1.1) : "tomato"
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

            SwipeDelegate.onClicked: {
                myLogger.log("replace tracks", listDelegateRect.height, albumDelegate.height)
                mainApp.updatePlaylist(albumLabel.text, "album", "replace")
                swipe.close()
            }

            background: Rectangle {
                color: replaceLabel.SwipeDelegate.pressed ? Qt.darker("tomato", 1.1) : "tomato"
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

    }

}
