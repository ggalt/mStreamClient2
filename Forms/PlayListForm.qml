import QtQuick 2.15
import QtQuick.Controls 2.15
import "../resourceElements"

ScrollingListView {
    id: playlistForm
    objectName: "playlistForm"

    property color delegateBackground: "#80808080"
    property color delegatePressed: "lightgrey"

    myModel: currentPlayList.plModel

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    myDelegate: SwipeDelegate {
        id: playlistDelegate
        height: 87
        width: playlistForm.width
        background: Rectangle {
            color: "transparent"
        }

        onPressed: listDelegateRect.color = "lightgrey"
        onReleased: listDelegateRect.color = "#80808080"

        onClicked: {
            playlistDelegate.ListView.view.currentIndex=index
            appWindow.currentPlayList.setCurrentTrack(index)
            myLogger.log("click for:", listDelegateRect.delegateLabel.text)
        }

        swipe.right: Label {
            id: removeLabel
            text: qsTr("Remove Track")
            color: "white"
            verticalAlignment: Label.AlignVCenter
            padding: 12
            height: parent.height
            anchors.right: parent.right

            SwipeDelegate.onClicked: {
                myLogger.log("remove track", listDelegateRect.height, playlistDelegate.height)
                swipe.close()
            }

            background: Rectangle {
                color: removeLabel.SwipeDelegate.pressed ? Qt.darker("tomato", 1.1) : "tomato"
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
            delegateLabel.text: model.metadata.track+" - "+model.metadata.title
            delegateImage.source: mainWindow.getServerURL()+"/album-art/"+model.metadata["album-art"]+"?token="+mainWindow.getToken()
        }
    }
}
