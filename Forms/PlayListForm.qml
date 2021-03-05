import QtQuick 2.15
import QtQuick.Controls 2.15
import "../resourceElements"

ScrollingListView {
    id: playListPage
    objectName: "playListPage"

    formName: "PlayList"
    myModel: playListJSONModel.model
    highlightLetter: myCurrentItem.myData.name[0]
    clip: false

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    myDelegate: DraggableListDelegate {
        id: playlistDelegate
        objectName: "playlistDelegate"
        property variant myData: model

        height: 50
        width: playListPage.width
        clip: true
        hasImage: false
        actionCommand: "load"
        actionItem: model.name
        delegateLabel.text: model.name
        textPointSize:  mainWindow.getTextPointSize()

        delegateMouseArea.onClicked: {
            ListView.view.currentIndex=index
            myLogger.log("click for:", actionItem)
            mainApp.requestPlayListSongs(actionItem)
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
