import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml 2.15

Dialog {
    id: thisDialog
    width: 500
    height: 300
    title: "Login Failed"
    modal: true
    visible: false
    font.pointSize: 12

//    onAccepted: {
//        console.log("Ok clicked")
//        sendLogin()
//    }
//    onRejected: {
//        console.log("Cancel clicked")
//        visible = false
//        appWindow.close()
//    }

    Rectangle {
        id: rectangle
        color: "#ffffff"
        anchors.fill: parent

        Label {
            id: label
            y: (parent.height - frame.height) /2 - label.height
            text: qsTr("Login failure.  Is the server running?")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 24
        }

        Frame {
            id: frame
            height: 60
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20

            Button {
                id: btnLogIn
                anchors.right: btnSetup.left
                anchors.rightMargin: (parent.width/2 - btnSetup.width/2 - btnLogIn.width)/2
                text: qsTr("Retry")
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    thisDialog.visible = false
                    appWindow.sendLogin()
                }
            }

            Button {
                id: btnSetup
                text: qsTr("Go To Setup")
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    thisDialog.visible = false
                    mainWindow.state = "Setup"
                }
            }

            Button {
                id: btnExit
                anchors.left: btnSetup.right
                anchors.leftMargin: (parent.width/2 - btnSetup.width/2 - btnExit.width)/2
//                x: btnSetup.right + ((parent.width - btnSetup.right) / 2) - btnExit.width/2
                text: qsTr("Exit")
                anchors.verticalCenter: parent.verticalCenter
                onClicked: appWindow.close()
            }
        }
    }
}
