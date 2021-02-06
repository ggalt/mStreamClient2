import QtQuick 2.15
import QtQuick.Controls 2.15
import "../resourceElements"

ScrollingListView {
    id: songPage
    objectName: "songPage"

    formName: "Song List"
    myModel: songListJSONModel.model
    highlightLetter: myCurrentItem.myData.metadata.title[0]
    clip: false

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    myDelegate: DraggableListDelegate {
        id: songDelegate
        objectName: "songDelegate"
        property variant myData: model

        height: 87
        width: songPage.width
        color: "#80808080"
        clip: true
        hasImage: true
        actionCommand: "song"
        actionItem: '{"filepath":"'+model.filepath +'", "metadata":'+JSON.stringify(model.metadata)+'}'
        delegateLabel.text: model.metadata.track+" - "+model.metadata.title
        delegateImage.source: model.metadata["album-art"]!==null ? mainWindow.getServerURL()+"/album-art/"+model.metadata["album-art"]+"?token="+mainWindow.getToken() : "../images/music_default2.png"
        textPointSize:  mainWindow.getTextPointSize()

        delegateMouseArea.onClicked: {
            ListView.view.currentIndex=index
            myLogger.log("click for:", actionItem)
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
