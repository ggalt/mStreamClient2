/* JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 */

import QtQuick 2.15
import "jsonpath.js" as JSONPath

Item {
    objectName: "jSONListModel"

    property string source: ""
    property string json: ""
    property string query: ""
    property string objNm: "name"   // object name to substitute if the set of data is a JSON array of strings

    property ListModel model: ListModel { id: jsonModel }
    property alias count: jsonModel.count

    Logger {
        id:myLogger
        moduleName: parent.objectName
        debugLevel: appWindow.globalDebugLevel
    }

    onSourceChanged: {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE)
                json = xhr.responseText;
        }
        xhr.send();
    }

    onJsonChanged: updateJSONModel()
    onQueryChanged: updateJSONModel()

    function updateJSONModel() {
        jsonModel.clear();

        if ( json === "" )
            return;

        var objectArray = parseJSONString(json, query);

        for ( var key in objectArray ) {
            var jo = objectArray[key];
            myLogger.log("key", key, "value", jo )
            if( typeof jo === 'string' ) {
                var jojo = '{ "' + objNm + '" : "'+ jo + '" }'
                var newJo = JSON.parse(jojo);
                jsonModel.append(newJo);
            } else {
                jsonModel.append( jo );
                myLogger.log("object", JSON.stringify(jo))
            }
        }
    }

    function parseJSONString(jsonString, jsonPathQuery) {
        var objectArray = JSON.parse(jsonString);
        if ( jsonPathQuery !== "" )
            objectArray = JSONPath.jsonPath(objectArray, jsonPathQuery);

        return objectArray;
    }

    function clear() {
        jsonModel.clear()
    }

    function add(jObj) {
        if(typeof jObj === 'object') {
            jsonModel.append(jObj)
        }
    }

    function move(from, to) {
        jsonModel.move(from, to, 1)
    }

    function get(index) {
        return jsonModel.get(index)
    }

    function setProperty(index, prop, val) {
        jsonModel.setProperty(index, prop, val)
    }

    function set(index, jObj) {
        if( typeof jObj === 'object' ) {
            jsonModel.set(index, jObj)
        }
    }

    function findIndexOf(key,value) {
        for( var i = 0; i < jsonModel.count; i++ ) {
            myLogger.log("value of key is", jsonModel.get(i)[key])
            if( jsonModel.get(i)[key] === value )
                return i
        }
        return -1;
    }

    function returnObjectContaining(key,value) {
        return jsonModel.get(findIndexOf(key,value))
    }
}
