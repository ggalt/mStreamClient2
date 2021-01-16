import QtQuick 2.12

Rectangle {
    id: scrollingTextWindow
    objectName: "scrollingTextWindow"

    clip: true

    property int scrollSpeed: 6000  // 6 seconds of scrolling
    property int scrollInterval: 8000   // 5 seconds of static text
    property int fadeOutSpeed: 1000
    property int fadeInSpeed: 200
    property int scrollStep: 0
    property int windowCoverage: 80 // percentage of window filled before we implement a scroll
    property int fadePoint: 50      // percentage of window covered by end of text before fade starts


    property alias scrollText: scrollingText.text
    property alias scrollFont: scrollingText.font
    property alias scrollFontPointSize: scrollingText.font.pointSize
    property alias scrollTextColor: scrollingText.color
    property alias scrollTextOpacity: scrollingText.opacity

    state: "Static"

    Component.objectName: setupScrolling()

    function animateText() {
        scrollingText.x = scrollingText.x-scrollStep

        if(scrollingText.x + textMetrics.width <= ((100 - fadePoint) * scrollingTextWindow.width)/100 ) {
            scrollingTextWindow.state = "FadeOut"
        }
    }

    function setupScrolling() {     // reset everything
        staticDisplayTimer.stop()
        scrollTimer.stop()
        scrollingText.horizontalAlignment=Text.AlignHCenter
        scrollingText.x = 0
        state="Static"

        if (textMetrics.width > windowCoverage * scrollingTextWindow.width / 100) {
            scrollStep = (((textMetrics.width - scrollingTextWindow.width) + scrollingTextWindow.width/3) * scrollTimer.interval) / scrollSpeed
            scrollingText.horizontalAlignment=Text.AlignLeft
            staticDisplayTimer.start()
        }
        return "_ScrollingTextWindow"
    }


    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    Timer {
        id: scrollTimer
        interval: 33    // ~30 fps
        repeat: true
        onTriggered: {
            animateText()
        }
    }

    Timer {
        id: staticDisplayTimer
        interval: scrollInterval
        onTriggered: {
            staticDisplayTimer.stop()
            scrollingTextWindow.state = "Scrolling"
            scrollTimer.start()
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.leftMargin: 10
        clip: true
        Text {
            id: scrollingText
            x: 0
            y: 0
            height: parent.height
            width: parent.width
            onTextChanged: setupScrolling()
            text: "test text"
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 20
            opacity: 1.0
        }
    }


    TextMetrics {
        id: textMetrics
        text: scrollingText.text
        font: scrollingText.font
    }

    states: [
        State {
            name: "Static"
            PropertyChanges {
                target: scrollingText
                opacity: 1.0
            }
        },

        State {
            name: "Scrolling"
            PropertyChanges {
                target: scrollingText
                opacity: 1.0
            }
        },
        State {
            name: "FadeOut"
            PropertyChanges {
                target: scrollingText
                opacity: 0
            }
        },
        State {
            name: "FadeIn"
            PropertyChanges {
                target: scrollingText
                opacity: 1.0
            }
        }

    ]

    transitions: [
        Transition {
            from: "*"
            to: "FadeOut"

            NumberAnimation {
                target: scrollingText
                property: "opacity"
                duration: fadeOutSpeed
                easing.type: Easing.InOutQuad
            }
            onRunningChanged: {
                if(!running && scrollingTextWindow.state==="FadeOut"){
                    scrollTimer.stop()
                    scrollingTextWindow.state="FadeIn"
                    scrollingText.x = 0
                }
            }
        },
        Transition {
            from: "*"
            to: "FadeIn"

            NumberAnimation {
                target: scrollingText
                property: "opacity"
                duration: fadeInSpeed
                easing.type: Easing.InOutQuad
            }
            onRunningChanged: {
                if(!running && scrollingTextWindow.state==="FadeIn"){
                    staticDisplayTimer.start()
                    scrollingTextWindow.state="Static"
                }
            }
        }
    ]

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
