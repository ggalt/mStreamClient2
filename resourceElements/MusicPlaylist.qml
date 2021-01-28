import QtQuick 2.15

JSONListModel {
    id: currentPlayListJSONModel
    objectName: "currentPlayListJSONModel"
    property int currentStaticIndex: 0      // index to sequential playlist
    property int currentPlayingIndex: 0     // index to playing playlist, will be the same a static when no shuffle, otherwise reflect shuffelled index
    property alias titleCount: currentPlayListJSONModel.count
    property var playListArray: []  // list of index positions in playlist
    property bool looping: false
    property bool shuffle: false
    property alias plModel: currentPlayListJSONModel.model

    signal endOfList
    signal trackChange(int idx)

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }


    function setLoop(status) {
        looping = status
    }

    function getLoop() {
        return looping
    }

    function setShuffle(status) {
        shuffle = status
    }

    function getShuffle() {
        return shuffle
    }

    function setCurrentTrack(trackNum) {
        currentStaticIndex = trackNum
        trackChange(getCurrentTrackNumber())
    }

    function getCurrentSongObject() {
        return get(getCurrentTrackNumber())
    }

    function getCurrentTrackNumber() {
        console.assert("Index past end of playlist", currentStaticIndex < titleCount)
        currentPlayingIndex = playListArray[currentStaticIndex]   // playListArray contains
        console.assert("Index does not exist", currentPlayingIndex < titleCount )
        return currentPlayingIndex
    }

    function getCurrentTrackPath() {
        myLogger.log("Encoded song file path:", encodeURIComponent(getCurrentSongObject()["filepath"]))
        return encodeURIComponent(getCurrentSongObject()["filepath"])
    }

    function getCurrentTrackMetadata() {
        return getCurrentSongObject()["metadata"]
    }

    function nextTrackAvailable() {
        myLogger.log("looping status:", looping)
        if(currentStaticIndex +1 >= titleCount) {
            if(looping) {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }

    function previousTrackAvailable() {
        if(currentStaticIndex -1 < 0) {
            if(looping) {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }

    function getNextTrack() {
        currentStaticIndex++
        if(currentStaticIndex >= titleCount) {
            currentStaticIndex = 0
            trackChange(currentStaticIndex)
            if(looping) {
                return true
            } else {
                endOfList()     // emit signal that we are at the end
                return false
            }
        }
        trackChange(currentStaticIndex)
        return true
    }

    function getPreviousTrack() {
        currentStaticIndex--
        if(currentStaticIndex < 0) {
            if(looping) {
                currentStaticIndex = titleCount-1
                trackChange(currentStaticIndex)
                return true
            } else {
                currentStaticIndex = 0
                trackChange(currentStaticIndex)
                endOfList()     // emit signal that we are at the end
                return false
            }
        }
        trackChange(currentStaticIndex)
        return true
    }

    function addSong(jsonSongObj) {
        add(jsonSongObj)
        playListArray.push(titleCount-1)    // push a reference to the added object
        myLogger.log("Song added:", jsonSongObj["filepath"])
    }

    function clearPlayList() {
        clear() // clears underlying jSon model
        currentStaticIndex = 0
        currentPlayingIndex = 0
        playListArray = []
    }
}

