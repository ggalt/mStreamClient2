import QtQuick 2.13

JSONListModel {
    id: currentPlayListJSONModel
    objectName: "currentPlayListJSONModel"
    property int currentIndex: 0
    property alias titleCount: currentPlayListJSONModel.count
    property var playListArray: []  // list of index positions in playlist
    property bool looping: false
    property bool shuffle: false
    property alias plModel: currentPlayListJSONModel.model

    signal endOfList
    signal trackChange

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
        currentIndex = trackNum
        trackChange(currentIndex)
    }

    function getCurrentSongObject() {
        console.assert("Index past end of playlist", currentIndex < titleCount)
        var idx = playListArray[currentIndex]   // playListArray contains
        console.assert("Index does not exist", idx < titleCount )
        return get(idx)
    }

    function getCurrentTrackNumber() {
        return playListArray[currentIndex]
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
        if(currentIndex +1 >= titleCount) {
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
        if(currentIndex -1 < 0) {
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
        myLogger.log("current index before add:", currentIndex)
        currentIndex++
        if(currentIndex >= titleCount) {
            if(looping) {
                currentIndex = 0
            } else {
                endOfList()     // emit signal that we are at the end
            }
        }
        myLogger.log("current index after add:", currentIndex)
        return getCurrentTrackPath()     // return path of next track
    }

    function getPreviousTrack() {
        currentIndex--
        if(currentIndex < 0) {
            if(looping) {
                currentIndex = titleCount-1
            } else {
                currentIndex = 0
            }
        }
        return getCurrentTrackPath()     // return path of previous track
    }

    function addSong(jsonSongObj) {
        add(jsonSongObj)
        playListArray.push(titleCount-1)    // push a reference to the added object
        myLogger.log("Song added:", jsonSongObj["filepath"])
    }

    function clearPlayList() {
        clear() // clears underlying jSon model
        playListArray = []
    }
}

