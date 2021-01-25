import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12

HoverButton {
    property bool checked: false
    property color checkedColor: "lightgreen"
    property color unCheckedColor: "white"
    property string toggledSource: ""
    property string untoggledSource: imageSource
    property bool hasToggledSource: false

    onClicked: {
        checked = !checked
    }

    onCheckedChanged: {
        if(checked) {
            backgroundColor = checkedColor
            if(hasToggledSource)
                imageSource = toggledSource
        } else {
            backgroundColor = unCheckedColor
            if(hasToggledSource)
                imageSource = untoggledSource
        }
    }
}
