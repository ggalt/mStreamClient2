import QtQuick 2.0

Item {
    id: qmlLogger
    property int debugLevel: 0
    property var output
    property int i: 0
    property string moduleName: parent.objectName

    function log(...args){
        if(debugLevel >= 2) {
            output = ""
            for(i = 0; i < args.length; i++) {
                output += args[i] + " "
            }
            console.log(moduleName, Date().toLocaleString(Qt.locale(), "dd MM hh:mm:ss.zzz"), output)
        }
    }

    function warn(...args){
        if(debugLevel >= 1) {
            output = ""
            for(i = 0; i < args.length; i++) {
                output += args[i] + " "
            }
            console.log(moduleName, output)
        }
    }

    function critical(...args){
        if(debugLevel >= 0) {
            output = ""
            for(i = 0; i < args.length; i++) {
                output += args[i] + " "
            }
            console.log(moduleName, output)
        }
    }

}
