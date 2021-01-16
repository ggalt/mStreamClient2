import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.13
import QtQml 2.13
import Qt.labs.settings 1.1
import QtMultimedia 5.12
import QtQuick.Layouts 1.12
import "../resourceElements"
import "../images"

Item {
    id: item1
    objectName: "nowPlayingForm"

    width: 400
    height: 400

    property int toolTipDelay: 1000
    property alias mediaPlayer: _mediaPlayer
    property alias progressBar: _progressBar

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }
    VolumeControl {
        id: volumeControl
        width: 40
        height: 40
        anchors.right: parent.right
        anchors.top: parent.top
        inactiveHeight: 50
        activeHeight: parent.height - controlFrame.height
        anchors.topMargin: 0
        volume: mediaPlayer.volume
        onVolumeChanged: {
            mediaPlayer.volume = volume
        }
//        Component.onCompleted:volumeSlider.setVolume(volume)
    }

    Image {
        id: coverImage
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: controlFrame.top
        smooth: true
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        source: "../images/ms-icon-600x600.png"
        z: volumeControl.z -1   // make sure we are behind the volumeControl

//        onStatusChanged: {
//          if (status == Image.Ready) {
//             myLogger.log('Loaded: sourceSize ==', paintedWidth, width, height);
//          }
//        }

        ColorProgressBar {
            id: _progressBar
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.paintedWidth
            anchors.bottom: parent.bottom
            backgroundColor: "#33ffffff"
            progressOpacity: 1
            progressColor: "#80ffffff"
            backgroundOpacity: 1
            height: parent.height /20
            currentValue: mediaPlayer.position / mediaPlayer.duration
        }
    }

    Frame {
        id: controlFrame
        height: (2 * parent.height ) / 10       // 20% of Form height
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        HoverButton {
            id: btnRewind

            anchors.top: parent.top
            anchors.left: parent.left
            width: (parent.width / 6) > parent.height ? parent.height : parent.width / 6
            height: width
            shadowRadius: 8
            shadowVertOffset: 4
            shadowHorzOffset: 4
            hasLabel: false
            imageSource: "../images/reverse.png"

            hoverEnabled: true
            ToolTip.visible: containsMouse
            ToolTip.delay: toolTipDelay
            ToolTip.text: qsTr("Previous")

            onClicked: {
                myLogger.log("width:", btnRewind.width)
                ToolTip.hide()
            }
        }

        ToggleButton {
            id: btnPlayOrPause

            anchors.top: parent.top
            anchors.left: btnRewind.right
            width: btnRewind.width
            height: width
            shadowRadius: 8
            shadowVertOffset: 4
            shadowHorzOffset: 4
            hasLabel: false
            imageSource: "../images/pause.png"
            untoggledSource: "../images/pause.png"
            toggledSource: "../images/play.png"
            hasToggledSource: true

            hoverEnabled: true
            ToolTip.visible: containsMouse
            ToolTip.delay: toolTipDelay
            ToolTip.text: checked ? qsTr("Play") : qsTr("Pause")

            onClicked: {
                myLogger.log("Play/Pause pressed.  Currently checked is:", checked)
                if( checked ) {
                    _mediaPlayer.play()
                    isPlaying = true
                } else {
                    _mediaPlayer.pause()
                    isPlaying = false
                }

                ToolTip.hide()
            }
        }

        HoverButton {
            id: btnForward

            anchors.top: parent.top
            anchors.left: btnPlayOrPause.right
            width: btnRewind.width
            height: width
            shadowRadius: 8
            shadowVertOffset: 4
            shadowHorzOffset: 4
            hasLabel: false
            imageSource: "../images/forward.png"

            hoverEnabled: true
            ToolTip.visible: containsMouse
            ToolTip.delay: toolTipDelay
            ToolTip.text: qsTr("Next")

            onClicked: {
                ToolTip.hide()
                mediaPlayer.startNextTrack()
            }
        }

        Rectangle {
            id: spacer

            anchors.top: parent.top
            anchors.left: btnForward.right
            width: btnRewind.width
            height: width
            opacity: 0.0
        }

        ToggleButton {
            id: btnLoop

            anchors.top: parent.top
            anchors.left: spacer.right
            width: btnRewind.width
            height: width
            shadowRadius: 8
            shadowVertOffset: 4
            shadowHorzOffset: 4
            hasLabel: false
            imageSource: "../images/loop_orig.png"

            hoverEnabled: true
            ToolTip.visible: containsMouse
            ToolTip.delay: toolTipDelay
            ToolTip.text: checked ? qsTr("No Loop") : qsTr("Loop")

            onClicked: {
                ToolTip.hide()
            }
        }

        ToggleButton {
            id: btnShuffle

            anchors.top: parent.top
            anchors.left: btnLoop.right
            width: btnRewind.width
            height: width
            shadowRadius: 8
            shadowVertOffset: 4
            shadowHorzOffset: 4
            hasLabel: false
            imageSource: "../images/shuffle_new.png"

            hoverEnabled: true
            ToolTip.visible: containsMouse
            ToolTip.delay: toolTipDelay
            ToolTip.text: checked ? qsTr("No Shuffle") : qsTr("Shuffle")

            onClicked: {
                ToolTip.hide()
            }
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////
    //////MediaPlayer
    ///////////////////////////////////////////////////////////////////////////////////////

    MediaPlayer {
        id: _mediaPlayer
        audioRole: MediaPlayer.MusicRole

        autoPlay: true

        function endOfPlaylist() {
            myLogger.log("Playlist ended and received by player");
            startNextTrack()
        }

        function startPlaylist() {
            currentPlayList.setCurrentTrack(0)  // make sure we are at the beginning
            // setting new track with setCurrentTrack will call "startNewTrack()" below
        }

        function startNewTrack() {
            myLogger.log(appWindow.currentPlayList.getCurrentTrackNumber(), "track path:",appWindow.serverURL+"/media/"+appWindow.currentPlayList.getCurrentTrackPath()+"?token="+appWindow.myToken)
            _mediaPlayer.source = appWindow.serverURL+"/media/"+appWindow.currentPlayList.getCurrentTrackPath()+"?token="+appWindow.myToken
            if( !btnPlayOrPause.checked )
                btnPlayOrPause.checked=true    // trigger a "click" of the pause/play toggle button
            displaySongInfo()
            //            _mediaPlayer.play()
        }

        function startNextTrack() {
            if(currentPlayList.nextTrackAvailable()) {
                _mediaPlayer.source = appWindow.serverURL+"/media/"+appWindow.currentPlayList.getNextTrack()+"?token="+appWindow.myToken
                myLogger.log(appWindow.currentPlayList.getCurrentTrackNumber(), "track path:",appWindow.serverURL+"/media/"+appWindow.currentPlayList.getCurrentTrackPath()+"?token="+appWindow.myToken)
                _mediaPlayer.play()
                displaySongInfo()
            } else {
                isPlaying=false;
                _mediaPlayer.stop()
            }
        }

        function startPreviousTrack() {
            _mediaPlayer.source = appWindow.serverURL+"/media/"+appWindow.currentPlayList.getPreviousTrack()+"?token="+appWindow.myToken
            myLogger.log(appWindow.currentPlayList.getCurrentTrackNumber(), "track path:",appWindow.serverURL+"/media/"+appWindow.currentPlayList.getCurrentTrackPath()+"?token="+appWindow.myToken)
            _mediaPlayer.play()
            displaySongInfo()
        }

        function displaySongInfo() {
            if(isPlaying) {
                appWindow.toolBarLabel.scrollText = "Artist:"+currentPlayList.getCurrentSongObject().metadata["artist"] + " / "+
                        "Album:"+currentPlayList.getCurrentSongObject().metadata["album"] + " / "+
                        "Title:"+currentPlayList.getCurrentSongObject().metadata["title"];
                coverImage.source = serverURL+"/album-art/"+currentPlayList.getCurrentSongObject().metadata["album-art"]+"?token="+myToken
                //                currentSong(currentPlayList.currentIndex)
            }
        }

        function getStatus() {
            if(status === 0)
                return "Status 0, No idea what this means"
            else if(status === MediaPlayer.NoMedia)
                return "NoMedia - no media has been set."
            else if(status === MediaPlayer.Loading)
                return "Loading - the media is currently being loaded."
            else if(status === MediaPlayer.Loaded)
                return "Loaded - the media has been loaded."
            else if(status === MediaPlayer.Buffering)
                return "Buffering - the media is buffering data."
            else if(status === MediaPlayer.Stalled)
                return "Stalled - playback has been interrupted while the media is buffering data."
            else if(status === MediaPlayer.Buffered)
                return "Buffered - the media has buffered data."
            else if(status === MediaPlayer.EndOfMedia)
                return "EndOfMedia - the media has played to the end."
            else if(status === MediaPlayer.InvalidMedia)
                return "InvalidMedia - the media cannot be played."
            else if(status === MediaPlayer.UnknownStatus)
                return "UnknownStatus - the status of the media is unknown."
            else
                return "really unknown status!! HELP!!"
        }

        onStatusChanged: {
            myLogger.log("Player Status:", getStatus())
            if( status === MediaPlayer.EndOfMedia ) {
                _mediaPlayer.startNextTrack()
            }
        }

        onPlaybackStateChanged: {
            myLogger.log("onPlaybackStateChanged", playbackState)
            if( playbackState === MediaPlayer.PlayingState ) {
                displaySongInfo()
            } else if( playbackState === MediaPlayer.PausedState ) {
                myLogger.log("Paused State")
            } else if( playbackState === MediaPlayer.StoppedState ) {
                myLogger.log("Stopped State")
            }
        }

        Component.onCompleted: {
            currentPlayList.endOfList.connect(endOfPlaylist);
            currentPlayList.trackChange.connect(startNewTrack)
            displaySongInfo()
        }

    }

}