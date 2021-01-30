import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: _colorSlider
    objectName: "colorSlider"
    property bool isVertical: true
    property bool isTopDown: true
    property real value
    property real from: 0
    property real to: 1.00
    color: "transparent"
    clip: true

    property bool trackMouse: false

    function setVolume(vol) {
        _colorSlider.value = vol
        if(isVertical) {
            btnImage.y = (_colorSlider.value * _mouseArea.drag.maximumY) / (_colorSlider.to - _colorSlider.from)
            myLogger.log("Area:", (_colorSlider.to - _colorSlider.from))
            myLogger.log("value:", _colorSlider.value)
            myLogger.log("drag area:", _mouseArea.drag.maximumY)
            myLogger.log("btnImage.y=", (_colorSlider.value * _mouseArea.drag.maximumY) / (_colorSlider.to - _colorSlider.from))
        }
    }

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        drag.target: btnImage
        drag.axis: isVertical ? Drag.YAxis : Drag.XAxis
        drag.minimumX: 0
        drag.minimumY: 0
        drag.maximumX: _colorSlider.width - btnImage.width
        drag.maximumY: _colorSlider.height - btnImage.height
        drag.smoothed: true

        onPressed: {
            isVertical ? drag.target.y = _mouseArea.mouseY : drag.target.x = _mouseArea.mouseX
            trackMouse = true
        }
        onReleased: trackMouse = false
    }

    Image {
        id: btnImage
        anchors.verticalCenter: isVertical ? undefined : parent.verticalCenter
        anchors.horizontalCenter: isVertical ? parent.horizontalCenter :  undefined
        width: isVertical ? parent.width : parent.height
        height: width
        source: "../images/audio-150191_640.png"
        fillMode: Image.PreserveAspectFit

        property real bufferedY // holds the mouseY restricted to

        onXChanged: {
            myLogger.log("X:",x, "MaxX", _colorSlider.width)

        }
        onYChanged: {
            bufferedY = (_mouseArea.drag.target.y <= _mouseArea.drag.maximumY) ? _mouseArea.drag.target.y : _mouseArea.drag.maximumY
            filledRect.height = bufferedY + btnImage.height
            _colorSlider.value = (_colorSlider.to - _colorSlider.from) * (bufferedY/_mouseArea.drag.maximumY)
            myLogger.log("value:", _colorSlider.value, _mouseArea.drag.maximumY, _mouseArea.drag.target.y, bufferedY)
        }
    }

    Rectangle {
        id: filledRect
        anchors.top: isVertical ? (isTopDown ? parent.top : undefined) : undefined
        anchors.bottom: isVertical ? (isTopDown ? undefined : parent.bottom) : undefined
        anchors.left: isVertical ? undefined : parent.left
        anchors.verticalCenter: isVertical ? undefined : parent.verticalCenter
        anchors.horizontalCenter: isVertical ? parent.horizontalCenter : undefined
        height: isVertical ? 0 : parent.height / 2
        width: isVertical ? parent.width / 2 : 0
        z: btnImage.z - 1

        radius: isVertical ? width /2 : height /2

        gradient: Gradient {
            orientation: isVertical ? Qt.Horizontal : Qt.Vertical
            GradientStop {
                position: 0
                color: "#99008080"
            }

            GradientStop {
                position: 0.5
                color: "#b3ffffff"
            }

            GradientStop {
                position: 1
                color: "#99008080"
            }
        }
    }
}
