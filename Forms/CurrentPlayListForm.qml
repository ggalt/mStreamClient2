import QtQuick 2.15
import QtQuick.Controls 2.15
import "../resourceElements"

ScrollingListView {
    id: currentPlaylistForm
    objectName: "currentPlaylistForm"

    property color delegateBackground: "#80808080"
    property color delegatePressed: "lightgrey"

    myHighLight: highlight
    myhighlightRangeMode: ListView.NoHighlightRange

    highlightFollowsCurrentItem: true

    function changeTrackIndex( idx ) {
        currentPlaylistForm.myCurrentIndex = idx
        myLogger.log("New Track number:", idx, "current playlist index:", currentPlaylistForm.myCurrentIndex)
    }

    myModel: currentPlayList.plModel

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    myDelegate: SwipeDelegate {
        id: playlistDelegate
        height: 87
        width: currentPlaylistForm.width
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

//            SwipeDelegate.onClicked: {
//                myLogger.log("remove track", listDelegateRect.height, playlistDelegate.height)
//                swipe.close()
//            }

            background: Rectangle {
                color: removeLabel.SwipeDelegate.pressed ? Qt.darker("tomato", 1.1) : "tomato"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        myLogger.log("remove track", listDelegateRect.height, playlistDelegate.height)
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
            delegateLabel.text: model.metadata.track+" - "+model.metadata.title
            delegateImage.source: model.metadata["album-art"]!==null ? mainWindow.getServerURL()+"/album-art/"+model.metadata["album-art"]+"?token="+mainWindow.getToken() : "../images/music_default2.png"
            textPointSize:  mainWindow.getTextPointSize()
        }
    }

    Component {
        id: highlight
        Rectangle {
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#4d808000"
                }

                GradientStop {
                    position: 0.5
                    color: "#66ffff00"
                }

                GradientStop {
                    position: 1
                    color: "#4d808000"
                }
            }
            border.width: 2
            border.color: "yellow"
            y: currentPlaylistForm.myCurrentItem.y
            Behavior on y {
                SpringAnimation {
                    spring: 3
                    damping: 0.2
                }
            }
        }
    }

    Component.onCompleted: {
        currentPlayList.trackChange.connect(changeTrackIndex)
    }
}



