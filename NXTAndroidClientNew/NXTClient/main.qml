import QtQuick 2.3
import QtQuick.Controls 1.2
import Qt.WebSockets 1.0
import QtSensors 5.0 as Sensors
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.2

import AccelometerWidget 1.0
import JSONParser 1.0
import "components/qml" as Panels

ApplicationWindow {
    id: root

    visible: true
    width: 854
    height: 480

    //FILLER
    Item {
        id: filler
        anchors.fill: parent

        //BUTTONS
        Panels.ButtonPanel {
            id: buttonPanel

            width: root.width * 0.375
            height: root.height

            anchors.left: infoPanel.right
        }

        //INFO
        Panels.InfoPanel {
            id: infoPanel

            width: root.width * 0.25
            height: root.height

            anchors.left: sliderPanel.right
        }

        //SLIDER
        Panels.SliderPanel {
            id: sliderPanel

            width: root.width * 0.375
            height: root.height

            //anchors.left: infoPanel.right
        }
    }

    //--------------"COMPASS"-------------
    AccelometerWidget {
        id: accelometerWidget

        width: height
        height: root.height * 0.56

        edgeColor: "#393939"
        color: "#181818"
        arrowColor: "#E09E01"
        arrowWidth: width * 0.1
        edgeWidth: width * 0.1

        angle: -accelometer.angle.toFixed(0)

        anchors.centerIn: filler

        onTouched: aboutDialog.visible = true
    }
    //------------------------------------

    MessageDialog {
        id: aboutDialog

        title: "About"
        text: "©VOŠ a SPŠEOL - 2014<br>Android client: Sony Nguyen<br>UI Designer: Matěj Mitaš<br>Server, NXT: Josef Kolář<br>NXT HW: Tomáš Mrázek<br>Other HW: Martin Mitter"
        onAccepted: Qt.openUrlExternally("http://bit.ly/spseol-DOD-2014")
    }

    //------------DATA TRANSFER-----------
    WebSocket {
        id: socket

        signal dataChanged()

        active: true
        url: "ws://192.168.43.173:8888/ws/control"

        onStatusChanged: {
            var actualStatus = socket.status

            switch(actualStatus) {
                case WebSocket.Connecting:
                    console.log("Connecting");
                    infoPanel.connectionText.text = "Connecting";
                    break;

                case WebSocket.Open:
                    console.log("Open");
                    infoPanel.connectionText.text = "Connected";
                    break;

                case WebSocket.Closing:
                    console.log("Closing");
                    infoPanel.connectionText.text = "Closing";
                    break;

                case WebSocket.Closed:
                    console.log("Closed");
                    infoPanel.connectionText.text = "Closed";
                    break;

                case WebSocket.Error:
                    console.log("Error (" + socket.errorString + ")")
                    infoPanel.connectionText.text = socket.errorString;
                    break;
            }
        }

        function sendData() {
            if(!socket.active || !socket.status == WebSocket.Open)
                return;

            parser.clearData()
            parser.addVariable("steering", ((-accelometer.angle / 90) * 90 / accelometer.lock).toFixed(2))
            parser.addVariable("throttle", (buttonPanel.pressed) ?(sliderPanel.slider.data * 100).toFixed(0) :0)
            parser.addVariable("reverse", buttonPanel.reverse)
            socket.sendTextMessage(parser.data)
            //console.log(counter+"--"+ parser.data)
            //counter++
        }

        onDataChanged: socket.sendData()
    }
    //------------------------------------

    //----------------JSON----------------
    JSONParser {
        id: parser
    }
    //------------------------------------

    //---------------EVENTS---------------
    MultiPointTouchArea {
        id: touchArea

       anchors.fill: filler
        maximumTouchPoints: 5

        onPressed: {
            for(var key in touchPoints) {
                var point = touchPoints[key]
                accelometerWidget.handleTouch(Qt.point(point.x, point.y))
                sliderPanel.slider.handleTouch(Qt.point(point.x, point.y))
                buttonPanel.goWidget.handleTouch(Qt.point(point.x, point.y), point.pointId, "pressed")
                buttonPanel.stopWidget.handleTouch(Qt.point(point.x, point.y), point.pointId, "pressed")
            }
        }

        onReleased: {
            for(var key in touchPoints) {
                var point = touchPoints[key]

                buttonPanel.goWidget.handleTouch(Qt.point(point.x, point.y), point.pointId, "release")
                buttonPanel.stopWidget.handleTouch(Qt.point(point.x, point.y), point.pointId, "release")
            }
        }

        onTouchUpdated: {
            for(var key in touchPoints) {
                var point = touchPoints[key]

                if(point.pressed) {
                    sliderPanel.slider.handleTouch(Qt.point(point.x, point.y))
                    buttonPanel.goWidget.handleTouch(Qt.point(point.x, point.y), point.pointId, "pressed")
                    buttonPanel.stopWidget.handleTouch(Qt.point(point.x, point.y), point.pointId, "pressed")
                }
            }
        }
    }
    //------------------------------------

    //-------------ACCELOMETER------------
    Sensors.Accelerometer {
        id: accelometer

        property real tolerance: 1
        property real lock: 60
        property int previous: 11
        property real angle

        Behavior on angle {
            NumberAnimation { duration: 300 }
        }

        active: true
        dataRate: 10000

        onReadingChanged: {
            var value = -accelometer.reading.y
            var raw_value = value

            value = (value *9 >= accelometer.lock) ? accelometer.lock / 9 :value
            value = (value * 9 <= -accelometer.lock) ?(-accelometer.lock) / 9: value
            accelometer.angle = value * 9

            if(Math.abs(raw_value - accelometer.previous) > accelometer.tolerance) {
                accelometer.previous = raw_value
                socket.dataChanged()
            }
        }
    }
    //------------------------------------

    //--------------RESOURCES-------------
    FontLoader {
        id: startstopFont
        source: "resources/fonts/DIN.ttf"
    }

    FontLoader {
        id: helveticaLight
        source: "resources/fonts/HelveticaNeueCE-UltraLight.otf"
    }

    FontLoader {
        id: helveticaBlack
        source: "resources/fonts/HelveticaNeueCE-Black.otf"
    }
    //------------------------------------
}
