import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.13
import QtQml 2.13
import Qt.labs.settings 1.1
import QtMultimedia 5.12
import QtQuick.Layouts 1.12
import "../resourceElements"
import "../"

Rectangle {
        id: _settingsForm
    //    property alias userName: appSettings.setUserName
    //    property alias passWord: appSettings.setPassword
    //    property string serverURLandPort: ""
    //    property alias serverURL: appSettings.setServerURL
    //    property alias serverPort: appSettings.setServerPort
    //    property alias mediaVolume: appSettings.setMediaVolume
    //    property alias isSetup: appSettings.setIsSetup

    objectName: "settingsForm"

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    function updateSettings() {
        appSettings.setUseLoginCredentials = loginCredentials
        if(loginCredentials.checked) {
            appSettings.setUserName = txtUserName.text
            appSettings.setPassword = txtPassword.text
        }
        appSettings.setServerURL = txtServerURL.text
        appSettings.setServerPort = txtPortNumber.text
        getFullURL()
        appSettings.setIsSetup = true
        myLogger.log(appSettings.setServerURL, appSettings.setServerPort, appSettings.setUserName, appSettings.setPassword )
        mainWindow.setMainWindowState("ListChooserWindow")
    }

    function getFullURL() {
        if(appSettings.setServerURL.substring(0,7) === "http://") {
            appSettings.setFullServerURL = appSettings.setServerURL+":"+appSettings.setServerPort
        } else if(appSettings.setServerURL.substring(0,8) === "https://") {
            appSettings.setFullServerURL = "http://"+appSettings.setServerURL.substring(8, appSettings.setServerURL.length-8)+":"+appSettings.setServerPort
        } else {
            appSettings.setFullServerURL = "http://"+appSettings.setServerURL+":"+appSettings.setServerPort
        }
    }

    function setVolume( currentVol ) {
        mediaVolume = currentVol
    }

    Item {
        id: colLayout
        anchors.fill: parent
        anchors.margins: 10
        anchors.rightMargin: 8
        anchors.bottomMargin: 8
        anchors.leftMargin: 12
        anchors.topMargin: 12
        Text {
            id: text1
            //                x: 8
            //                y: 37
            text: qsTr("mStream Server URL:")
            anchors.verticalCenter: txtServerURL.verticalCenter
            anchors.left: parent.left
            font.pixelSize: 12
            minimumPixelSize: 0
            minimumPointSize: 20
        }

        TextField {
            id: txtServerURL
            //                x: 135
            //                y: 35
            width: 185
            height: 25
            text: qsTr(appSettings.setServerURL)
            anchors.left: text1.right
            anchors.top: parent.top
            font.pixelSize: 12
            anchors.leftMargin: 10
            anchors.topMargin: 10
            cursorVisible: true
        }
        Text {
            id: text2
            //                x: 333
            //                y: 37
            text: qsTr("Server Port:")
            anchors.verticalCenter: txtPortNumber.verticalCenter
            anchors.left: parent.left
            font.pixelSize: 12
            anchors.leftMargin: 0
            minimumPixelSize: 0
            minimumPointSize: 20
        }

        TextField {
            id: txtPortNumber
            //                x: 406
            //                y: 35
            width: 80
            height: 25
            text: qsTr(appSettings.setServerPort)
            anchors.left: txtServerURL.left
            anchors.top: txtServerURL.bottom
            font.pixelSize: 12
            anchors.topMargin: 10
        }
        Frame {
            id: frame
            //                x: 8
            //                y: 61
            height: 200
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: txtPortNumber.bottom
            anchors.topMargin: 20

            Switch {
                id: loginCredentials
                text: qsTr("Use Login Credentials")
                anchors.left: parent.left
                anchors.top: parent.top
                checked: appSettings.setUseLoginCredentials

                onCheckedChanged: {
                    if(checked) {
                        txtUserName.enabled = true
                        txtPassword.enabled = true
                    } else {
                        txtUserName.enabled = false
                        txtPassword.enabled = false
                    }
                }
            }

            Text {
                id: text3
                y: 46
                text: qsTr("Username:")
                anchors.verticalCenter: txtUserName.verticalCenter
                anchors.left: parent.left
                font.pixelSize: 12
                minimumPixelSize: 14
                minimumPointSize: 14
            }

            TextField {
                id: txtUserName
                width: 226
                height: 25
                text: qsTr(appSettings.setUserName)
                anchors.left: text3.right
                anchors.top: loginCredentials.bottom
                font.pixelSize: 12
                anchors.topMargin: 10
                anchors.leftMargin: 10
            }

            Text {
                id: text4
                y: 81
                text: qsTr("Password:")
                anchors.verticalCenter: txtPassword.verticalCenter
                anchors.left: parent.left
                font.pixelSize: 12
            }

            TextField {
                id: txtPassword
                width: 226
                height: 25
                text: qsTr(appSettings.setPassword)
                anchors.left: txtUserName.left
                anchors.top: txtUserName.bottom
                font.pixelSize: 12
                anchors.topMargin: 15
            }
        }

        Frame {
            id: frame1
            x: 196
            width: 50
            height: 40
            visible: false
            anchors.top: frame.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
        }

        Button {
            id: btnOK
            x: 78
            //                x: 215
            //                y: 351
            text: qsTr("Accept")
            anchors.right: frame1.left
            anchors.top: frame1.top
            onClicked:{
                updateSettings()
            }
        }

        Button {
            id: btnCancel
            //                x: 346
            //                y: 351
            text: qsTr("Cancel")
            anchors.left: frame1.right
            anchors.top: frame1.top
            onClicked: mainWindow.setMainWindowState("ListChooserWindow")

        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:8}D{i:9}D{i:11}D{i:7}D{i:13}D{i:14}D{i:15}
}
##^##*/
