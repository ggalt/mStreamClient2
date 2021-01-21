import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml 2.13
import Qt.labs.settings 1.1
import QtMultimedia 5.12
import "resourceElements"

ApplicationWindow {
    id: appWindow
    objectName: "appWindow"

    visible: true
    width: 800
    height: 480
    color: "#c8c8c8"
    title: qsTr("mStreamClient")

    /////////////////////////////////////////////////////////////////////////////////
    /// Visible Items
    /////////////////////////////////////////////////////////////////////////////////

    header: ToolBar {
        id: toolBar
        contentHeight: toolButton.implicitHeight
        property int textPointSize: 20

        ToolButton {
            id: toolButton
            text: mainWindow.listStackView.depth <=1 ? "\u2630" : "\u21A9"
            font.pointSize: toolBar.textPointSize

            function refreshText() {
                text=mainWindow.listStackView.depth <=1 ? "\u2630" : "\u21A9"
            }

            onClicked: {
                if (mainWindow.listStackView.depth > 1) {
                    myLogger.log("listStackView depth before:", mainWindow.listStackView.depth)
                    var item = mainWindow.listStackView.pop()
                    appWindow.poppedItems.push(item.objectName)
                    myLogger.log("listStackView depth after:", mainWindow.listStackView.depth)
                    myLogger.log("form name:", item.objectName)
                    console.log("poppedItems:", appWindow.poppedItems)

                    if(mainWindow.listStackView.depth === 1)
                        mainWindow.state="ListChooserWindow"

//                    if(nowPlayingTimer.running)
//                        nowPlayingTimer.restart()
//                    else
//                        nowPlayingTimer.start()
                } else {
                    // enter setup
                    myLogger.log("listStackView depth:", mainWindow.listStackView.depth)
                    myLogger.log("listStackView empty:", mainWindow.listStackView.empty)
                    myLogger.log("listStackView at:", mainWindow.listStackView.currentItem.objectName)
                }
                refreshText()
            }
        }

        ScrollingTextWindow {
            id: _toolBarLabel
            anchors.left: toolButton.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: _nowPlayingNavButton.left
            scrollFontPointSize: toolBar.textPointSize
            scrollText: "mStream Client"
        }

        ToolButton {
            id: _nowPlayingNavButton
            anchors.right: parent.right
            height: parent.height
            width: hasPlayListLoaded && mainWindow.listStackView.currentItem.objectName !== "playlistForm"? height : 0
            text: "\u21AA"
            font.pointSize: toolBar.textPointSize
        }

    }

//    Timer {
//        id: _nowPlayingTimer
//        interval: 5000
//        running: false
//        onTriggered: {
//            myLogger.log("return to Now Playing", mainWindow.listStackView.depth, mainWindow.listStackView.index, currentPlayList.count)
//            console.log("poppedItems before push:", appWindow.poppedItems)
//            mainWindow.setMainWindowState("NowPlaying")
//            while( appWindow.poppedItems.length > 0 ) {
//                var item = appWindow.poppedItems.pop()
//                myLogger.log("popped item:", item)
//                if(item === "playlistForm") {
//                    mainWindow.listStackView.push( "qrc:/Forms/PlayListForm.qml" )
//                } else if(item === "albumPage") {
//                    mainWindow.listStackView.push( "qrc:/Forms/AlbumListForm.qml" )
//                } else if(item === "artistPage") {
//                    mainWindow.listStackView.push( "qrc:/Forms/ArtistListForm.qml" )
//                } else if(item === "managedPlaylist") {
//                    myLogger.log("managedPlaylist")
//                }
//            }
//            appWindow.poppedItems = []
//        }
//    }

    MainWindow {
        id: mainWindow
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: toolBar.bottom
        Component.onCompleted: {
            if(  getSetupState() )
                sendLogin()
        }
        property alias mainApp: appWindow
        listStackView.onDepthChanged: toolButton.refreshText()     // for some reason, text refresh seems unreliable
    }

    /////////////////////////////////////////////////////////////////////////////////
    /// Data Structures
    /////////////////////////////////////////////////////////////////////////////////
    JSONListModel {
        id: artistListJSONModel
        objNm: "name"
    }

    JSONListModel {
        id: albumListJSONModel
    }

    JSONListModel {
        id: songListJSONModel
    }

    MusicPlaylist {
        id: _currentPlayList
    }

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    /////////////////////////////////////////////////////////////////////////////////
    /// Data Elements
    /////////////////////////////////////////////////////////////////////////////////

    property string myToken: ""
    property string serverURL: mainWindow.getServerURL()

    property int gettingArtists: 0
    property int gettingAlbums: 0
    property int gettingTitles: 0

    property string currentAlbumArt: ""

    property bool isPlaying: false
    property bool hasPlayListLoaded: false
    property int playlistAddAt: 0

    property int globalDebugLevel: 2        // 0 = critical, 1 = warn, 2 = all

    property var poppedItems: []

    property alias currentPlayList: _currentPlayList
    property alias toolBarLabel: _toolBarLabel
//    property alias nowPlayingTimer: _nowPlayingTimer

    /////////////////////////////////////////////////////////////////////////////////
    /// Functions
    /////////////////////////////////////////////////////////////////////////////////

    function sendLogin() {
        var xmlhttp = new XMLHttpRequest();
        var url = serverURL+"/login";
        myLogger.log("URL:", url)
        xmlhttp.open("POST", url, true);

        xmlhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        xmlhttp.setRequestHeader("datatype", "json");
        xmlhttp.onreadystatechange = function() { // Call a function when the state changes.
            if (xmlhttp.readyState === 4) {
                if (xmlhttp.status === 200) {
                    myLogger.log("ResponseText:", xmlhttp.responseText)
                    var resp = JSON.parse(xmlhttp.responseText)
                    myToken = resp.token
                } else {
                    myLogger.log("error: " + xmlhttp.status)
                }
            }
        }
        var jsString = JSON.stringify({ username: mainWindow.getUserName(), password: mainWindow.getPassWord() })

        xmlhttp.send(jsString);
    }

    /// serverCall: Generic function to call the mStream server
    function serverCall(reqPath, JSONval, callType, callback) {
        var xmlhttp = new XMLHttpRequest();
        var url = serverURL+reqPath;
        myLogger.log("Request info:", callType, url, JSONval);
        xmlhttp.open(callType, url, true);
        xmlhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        xmlhttp.setRequestHeader("datatype", "json");

        if( myToken !== '' ) {
            xmlhttp.setRequestHeader("x-access-token", myToken)
        }

        if(callback !== '') {
            xmlhttp.onreadystatechange = function(){
                if(xmlhttp.readyState === 4) {
                    if(xmlhttp.status === 200) {
                        myLogger.log("callback called")
                        callback(xmlhttp);
                    } else {
                        myLogger.log("error: " + xmlhttp.status)
                    }
                }
            };
        }

        if(JSONval !== '') {
            xmlhttp.send(JSONval);
        } else {
            xmlhttp.send()
        }
    }

    function requestArtists() {
        serverCall("/db/artists", '', "GET", artistsRequestResp)
    }

    function requestAlbums() {
        serverCall("/db/albums", '', "GET", albumRequestResp)
    }

    function requestArtistAlbums(artistName) {
        myLogger.log("Requesting albums for:", artistName)
        serverCall("/db/artists-albums", JSON.stringify({ 'artist' : artistName }), "POST", albumRequestResp)
    }

    function requestAlbumSongs(albumName) {
        myLogger.log("Requesting songs for album:", albumName)
        serverCall("/db/album-songs", JSON.stringify({ 'album' : albumName }), "POST", songRequestResp)
    }

    function artistsRequestResp(xmlhttp) {
        myLogger.log("artistRequestResp:", xmlhttp.responseText)
        artistListJSONModel.json = xmlhttp.responseText
        artistListJSONModel.query = "$.artists[*]"
        mainWindow.setMainWindowState("NowPlaying")
        mainWindow.listStackView.push( "qrc:/Forms/ArtistListForm.qml" )
    }

    function albumRequestResp(xmlhttp) {
        myLogger.log("albumRequestResp:", xmlhttp.responseText.substring(1,5000))
        albumListJSONModel.json = xmlhttp.responseText
        albumListJSONModel.query = "$.albums[*]"
        mainWindow.setMainWindowState("NowPlaying")
        mainWindow.listStackView.push( "qrc:/Forms/AlbumListForm.qml" )
    }

    function songRequestResp(xmlhttp) {
        songListJSONModel.json = xmlhttp.responseText
        stackView.push( "qrc:/SongForm.qml" )
    }

    function actionClick(action) {
//        if(nowPlayingTimer.running) {
//            nowPlayingTimer.stop()
//            appWindow.poppedItems = []
//        }

        if(action === "Artists") {
            myLogger.log("Artist Click")
            requestArtists();
        } else if (action === "Albums") {
            myLogger.log("Album Click")
            requestAlbums();
        } else if (action === "Playlists") {
            myLogger.log("Playlist Click")
        }
    }

    function updatePlaylist(m_item, typeOfItem, action) { // m_item needs to be the name of an artist, album, playlist or song
        myLogger.log("Update Playlist", m_item, typeOfItem, action)
        if(action === "replace") {
            _currentPlayList.clearMe()
            myLogger.log("_currentPlayList.count:", _currentPlayList.count)
            myLogger.log("playlist:", _currentPlayList.json)
            //            playlistAddAt = 0
        }

        if(typeOfItem === "artist") {
            playlistAddArtist(m_item)
        } else if( typeOfItem === "album") {
            playlistAddAlbum(m_item)
        } else if( typeOfItem === "playlist") {
            playlistAddPlaylist(m_item)
        } else {
            playlistAddSong(m_item)
        }
    }

    function loadToPlaylist() {
        //        myLogger.log("gettingArtists is:", gettingArtists, "gettingAlbums is:", gettingAlbums, "gettingTitles is:", gettingTitles)
        if( gettingArtists <= 0 && gettingAlbums <= 0 && gettingTitles <= 0) {
            myLogger.log("loading playlist whch has length of:", _currentPlayList.count)
            isPlaying = true
            mainWindow.listStackView.push("qrc:/Forms/PlayListForm.qml")
            mainWindow.nowPlayingForm.mediaPlayer.startPlaylist()
        }
    }

    function playlistAddSong(songObj) {   // this actually adds the songs to our playlist
        myLogger.log("playlistAddAt =", playlistAddAt)
        songObj.playListPosition = playlistAddAt++      // add the playListPosition role
        if(songObj.metadata["album-art"] === null) {
            myLogger.log("NULL IMAGE")
        }
        _currentPlayList.addSong(songObj)
        //        myLogger.log("song object:", JSON.stringify(songObj))
        //        _currentPlayList.add(songObj)
        gettingTitles--;
        loadToPlaylist();
    }

    function playlistAddAlbum(title) {  // add songs from album
        myLogger.log("album get count:", gettingAlbums)
        gettingAlbums++;
        serverCall("/db/album-songs", JSON.stringify({ 'album' : title }), "POST", playlistAddAlbumResp)
    }

    function playlistAddArtist(title) { // add albums from artist
        gettingArtists++;
        serverCall("/db/artists-albums", JSON.stringify({ 'artist' : title }), "POST", playlistAddArtistResp)
    }

    function playlistAddPlaylist(title) {

    }

    function playlistAddAlbumResp(resp) {
        var albumResp = JSON.parse(resp.responseText) // for some reason, our delegate doesn't like 'album-art'
        //        myLogger.log("playlistAddAlbumResp:", resp.responseText)
        for( var i = 0; i < albumResp.length; i++ ) {
            gettingTitles++;
            if( albumResp[i].metadata["album-art"] === null )
                albumResp[i].metadata["album-art"] = albumListJSONModel.returnObjectContaining("name",albumResp[i].metadata["album"])["album_art_file"]
            playlistAddSong(albumResp[i])
        }
        gettingAlbums--;
        //        myLogger.log("exit getting albums with count:", gettingAlbums)
        loadToPlaylist()
    }

    function playlistAddArtistResp(resp) {
        var artistResp = JSON.parse(resp.responseText)

        for( var i = 0; i < artistResp.albums.length; i++) {
            playlistAddAlbum(artistResp.albums[i].name)
        }
        gettingArtists--;
        //        myLogger.log("exit getting artists")
        loadToPlaylist()
    }

    function selectSongAtIndex(idx) {
        //        myLogger.log("selected song at index:", idx)
        _currentPlayList.setMusicPlaylistIndex(idx)
        nowPlaying.startPlay()
    }

    function setGlobalVolume(vol) {
        mainWindow.mediaVolume = vol
    }


}
