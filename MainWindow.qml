import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQml 2.15
import Qt.labs.settings 1.1
import QtMultimedia 5.12
import QtQuick.Layouts 1.12
import "."
import "./resourceElements"
import "./Forms"

Item {
    id: mainWindow
    objectName: "mainWindow"

    property alias listStackView: listManager
    property alias nowPlayingForm: _nowPlayingForm

    state: "initializing"

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    Image {
        id: loadingImage
        anchors.fill: parent
        source: "images/ms-icon-600x600.png"
        fillMode: Image.PreserveAspectFit
    }

    ListChooser {
        id: listChooser
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 0
                color: "#ffffff"
            }

            GradientStop {
                position: 1
                color: "#7cda3f"
            }
        }
    }

    Frame {
        id: navFrame
        visible: false
        anchors.fill: parent

        Rectangle {
            id: listManagerRect
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            //            color: "blue"
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#ffffff"
                }

                GradientStop {
                    position: 1
                    color: "#9ff9ae"
                }
            }
            width: parent.width / 2
            StackView {
                id: listManager
                anchors.fill: parent
                visible: true
                clip: true      // false if we want drag and drop
                initialItem: Rectangle {
//                    anchors.fill: parent
                }
            }
        }

        // DropArea not currently working, but isn't really in the way
        DropArea {
            id: dropArea

            property string delegateDrop

            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: listManagerRect.right
            z: listManagerRect.z-1

            onContainsDragChanged: console.log("DRAG")

//            keys: [delegateDrop]
            onDropped: {
                console.log("DROP!!")
                console.log("DROP!!", drop.source.objectName, drop.source.delegateLabel.text)
            }
            NowPlayingForm {
                id: _nowPlayingForm
                anchors.fill: parent
                states: [
                    State {
                        when: dropArea.containsDrag
                        PropertyChanges {
                            target: _nowPlayingForm
                            opacity: 0.0
                        }
                    }
                ]

            }

        }

    }

    Settings {
        id: appSettings

        property string setUserName: ""
        property string setPassword: ""
        property string setServerURL: ""
        property string setServerPort: ""
        property string setFullServerURL: ""
        property real setMediaVolume
        property bool setIsSetup
        property bool setUseLoginCredentials
    }

    SettingsForm {
        id: settingsForm
        visible: false
        anchors.fill: parent
        //        property alias appSettings: _appSettings
        onVisibleChanged: {myLogger.log("Settings Visibility", visible) }
    }

    Timer {
        id: testTimer
        interval: 2000
        running: true
        repeat: false
        onTriggered: {
            if( appSettings.setIsSetup) {
                mainWindow.state = "ListChooserWindow"
                myLogger.log(appSettings.setServerURL, appSettings.setServerPort, appSettings.setUserName, appSettings.setPassword )
            } else {
                mainWindow.state = "Setup"
                myLogger.log(appSettings.setServerURL, appSettings.setServerPort, appSettings.setUserName, appSettings.setPassword )
                myLogger.log(appSettings.setFullServerURL)
            }
        }
    }

    states: [
        State {
            name: "initializing"
            PropertyChanges {
                target: settingsForm
                opacity: 0.0
                focus: false
            }
            PropertyChanges {
                target: loadingImage
                visible: true
                focus: true
                opacity: 1.0
            }
            PropertyChanges {
                target: listChooser
                opacity: 0.0
                focus: false
            }
            PropertyChanges {
                target: navFrame
                opacity: 0.0
                focus: false
            }
        },
        State {
            name: "ListChooserWindow"
            PropertyChanges {
                target: settingsForm
                opacity: 0.0
                focus: false
            }
            PropertyChanges {
                target: loadingImage
                focus: false
                opacity: 0.0
            }
            PropertyChanges {
                target: listChooser
                visible: true
                focus: true
                opacity: 1.0
            }
            PropertyChanges {
                target: navFrame
                opacity: 0.0
                focus: false
            }
        },
        State {
            name: "NowPlaying"
            PropertyChanges {
                target: settingsForm
                opacity: 0.0
                focus: false
            }
            PropertyChanges {
                target: loadingImage
                focus: false
                opacity: 0.0
            }
            PropertyChanges {
                target: listChooser
                focus: false
                opacity: 0.0
            }
            PropertyChanges {
                target: navFrame
                visible: true
                focus: true
                opacity: 1.0
            }
        },
        State {
            name: "Setup"
            PropertyChanges {
                target: settingsForm
                visible: true
                opacity: 1.0
                focus: true
            }
            PropertyChanges {
                target: loadingImage
                focus: false
                opacity: 0.0
            }
            PropertyChanges {
                target: listChooser
                focus: false
                opacity: 0.0
            }
            PropertyChanges {
                target: navFrame
                opacity: 0.0
                focus: false
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "ListChooserWindow"
            PropertyAnimation {
                property: "opacity"
                duration: 800
                easing.type: Easing.InOutQuad
            }

            onRunningChanged: {
                if( !running && state==="ListChooserWindow") {
                    loadingImage.visible = false
                    navFrame.visible = false
                    settingsForm.visible = false
                    listChooser.visible = true
                    myLogger.log("ListChooserWindow Done***********")
                }
            }
        },
        Transition {
            from: "*"
            to: "NowPlaying"
            PropertyAnimation {
                property: "opacity"
                duration: 800
                easing.type: Easing.InOutQuad
            }

            onRunningChanged: {
                if( !running && state==="NowPlaying") {
                    loadingImage.visible = false
                    navFrame.visible = true
                    settingsForm.visible = false
                    listChooser.visible = false
                    myLogger.log("NowPlaying Done***********")
                }
            }
        },
        Transition {
            from: "*"
            to: "Setup"
            PropertyAnimation {
                property: "opacity"
                duration: 800
                easing.type: Easing.InOutQuad
            }

            onRunningChanged: {
                if( !running && state==="Setup") {
                    loadingImage.visible = false
                    navFrame.visible = false
                    settingsForm.visible = true
                    listChooser.visible = false
                    myLogger.log("Setup Done***********", settingsForm.visible)
                }
            }
        },
        Transition {
            from: "*"
            to: "initializing"
            PropertyAnimation {
                property: "opacity"
                duration: 800
                easing.type: Easing.InOutQuad
            }

            onRunningChanged: {
                if( !running && state==="initializing") {
                    loadingImage.visible = true
                    navFrame.visible = false
                    settingsForm.visible = false
                    listChooser.visible = false
                    myLogger.log("Initializing Done***********")
                }
            }
        }
    ]

    function setMainWindowState( newState ) {
        state = newState
    }

    function getServerURL() {
        return appSettings.setFullServerURL
    }

    function getUserName() {
        return appSettings.setUserName
    }

    function getPassWord() {
        return appSettings.setPassword
    }

    function getToken() {
        return appWindow.myToken
    }

    function getSetupState() {
        return appSettings.setIsSetup
    }

    Component.onCompleted: testTimer.start()
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
