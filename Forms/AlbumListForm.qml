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

    myDelegate: DraggableListDelegate {
        id: albumDelegate
        objectName: "albumDelegate"
        property variant myData: model

        height: 87
        width: albumPage.width
        clip: true
        hasImage: true
        actionCommand: "album"
        actionItem: model.name
        delegateLabel.text: model.name
        delegateImage.source: mainWindow.getServerURL()+"/album-art/"+model.album_art_file+"?token="+mainWindow.getToken()
        textPointSize:  mainWindow.getTextPointSize()

        delegateMouseArea.onClicked: {
            ListView.view.currentIndex=index
            myLogger.log("click for:", actionItem)
            mainApp.requestAlbumSongs(actionItem)
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
