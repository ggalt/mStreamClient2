import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: _volumeControl
    objectName: "volumeControl"

    property int activeHeight: height
    property int inactiveHeight: width

    property bool topDown: true
    property alias volume: _volumeSlider.value
    property alias volumeSlider: _volumeSlider
    property bool mute: false

    property int drawSlideInterval: 1500
    property string volumeImage: "../images/audio-150191_640.png"
    property string muteVolumeImage: "../images/mute-audio-150191_640.png"

    state: "inactive"

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    Rectangle {
        id: volumeWindow
        anchors.horizontalCenter: parent.horizontalCenter
        width: (2*_volumeControl.width)/3
//        anchors.left: parent.left
//        anchors.right: parent.right
        anchors.bottom: topDown ? undefined : volumeImg.top
        anchors.top: topDown ? volumeImg.bottom : undefined
        color: "transparent"
        radius: width / 2

        ColorSlider {
            id: _volumeSlider
            anchors.fill: parent
            from: 0.0
            to: 1.0
            isVertical: true
            isTopDown: true
            onValueChanged: {
                sliderTimer.restart()
            }
        }
    }

    Image {
        id: volumeImg
        anchors.top: topDown ? parent.top : volumeWindow.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: width

        smooth: true
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        source: mute ? muteVolumeImage : volumeImage
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
//            onPressAndHold: {
//                _volumeControl.state = "active"
//            }

            onClicked: {
                if( mouse.button == Qt.RightButton ) {
                    myLogger.log("Mute Volume")
                    mute = !mute
                } else {
                    _volumeControl.state = "active"
                }
            }
        }
    }

    Timer {
        id: sliderTimer
        interval: drawSlideInterval
        onTriggered: {
            if( _volumeSlider.trackMouse )
                restart()
            else
                _volumeControl.state = "inactive"
        }
    }

    states: [
        State {
            name: "active"
            PropertyChanges {
                target: _volumeControl
                height: activeHeight
            }
            PropertyChanges {
                target: volumeWindow
                visible: true
                height: activeHeight - inactiveHeight
            }
        },
        State {
            name: "inactive"
            PropertyChanges {
                target: _volumeControl
                height: inactiveHeight
            }
        }
    ]

    transitions: [
        Transition {
            from: "inactive"
            to: "active"
            ParallelAnimation {
                NumberAnimation {
                    target: volumeImg
                    property: "rotation"
                    from: 0
                    to: 360
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: volumeWindow
                    property: "height"
                    from: 0
                    to: activeHeight - inactiveHeight
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
            onRunningChanged: {
                if(!running && state === "active") {
                    _volumeSlider.setVolume(volume)
                    sliderTimer.start()
                }
            }
        },
        Transition {
            from: "active"
            to: "inactive"
            ParallelAnimation {
                NumberAnimation {
                    target: volumeImg
                    property: "rotation"
                    from: 360
                    to: 0
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: volumeWindow
                    property: "height"
                    from: activeHeight - inactiveHeight
                    to: 0
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
            onRunningChanged: {
                if(!running && state==="inactive"){
                    volumeWindow.visible=false
                }
            }
        }
    ]
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:2}
}
##^##*/
