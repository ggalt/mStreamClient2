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
        if(shuffle)
            knuthShuffle()
        else
            unShuffle()
    }

    function getShuffle() {
        return shuffle
    }


    function knuthShuffle() {
        var rand, temp, i;

        for( i = playListArray.length-1; i > 0; i-- ) {
            rand = Math.floor((i + 1) * Math.random());//get random between zero and i (inclusive)
            temp = playListArray[rand];//swap i and the zero-indexed number
            playListArray[rand] = playListArray[i];
            playListArray[i] = temp;
        }
        myLogger.log("Shuffled array is:", playListArray)
    }

    function unShuffle() {
        var i;
        for(i=0; i < titleCount; i++)
            playListArray[i]=i
        myLogger.log("Unshuffled array is:", playListArray)
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
        myLogger.log("Current Static Index Is:", currentStaticIndex, "Current Playing Index is:", currentPlayingIndex)
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
        myLogger.log("Next Track -- Current Static Index is:", currentStaticIndex)
        if(currentStaticIndex >= titleCount) {
            currentStaticIndex = 0
            isPlaying = false
            trackChange(getCurrentTrackNumber())
            if(looping) {
                isPlaying = true
                return true
            } else {
                endOfList()     // emit signal that we are at the end
                return false
            }
        }
        trackChange(getCurrentTrackNumber())
        return true
    }

    function getPreviousTrack() {
        currentStaticIndex--
        myLogger.log("Previous Track -- Current Static Index is:", currentStaticIndex)
        if(currentStaticIndex < 0) {
            if(looping) {
                currentStaticIndex = titleCount-1
                trackChange(getCurrentTrackNumber())
                return true
            } else {
                currentStaticIndex = 0
                trackChange(getCurrentTrackNumber())
                endOfList()     // emit signal that we are at the end
                return false
            }
        }
        trackChange(getCurrentTrackNumber())
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

