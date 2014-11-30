import QtQuick 2.3
import QtQuick.Controls 1.2
import Qt.WebSockets 1.0
import QtSensors 5.0 as Sensors
import QtGraphicalEffects 1.0

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
        }

        //INFO
        Panels.InfoPanel {
            id: infoPanel

            width: root.width * 0.25
            height: root.height

            anchors.left: buttonPanel.right
        }

        //SLIDER
        Panels.SliderPanel {
            id: sliderPanel

            width: root.width * 0.375
            height: root.height

            anchors.left: infoPanel.right
        }
    }

    //--------------"COMPASS"-------------
    AccelometerWidget {
        width: height
        height: root.height * 0.56

        edgeColor: "#393939"
        color: "#181818"
        arrowColor: "#E09E01"
        arrowWidth: width * 0.1
        edgeWidth: width * 0.1

        angle: -accelometer.angle.toFixed(0)

        anchors.centerIn: filler
    }
    //------------------------------------

    //------------DATA TRANSFER-----------
    WebSocket {
        id: socket

        signal dataChanged()

        active: false
        url: "ws://192.168.2.104:8888/ws/control"

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

            json.clearData()
            json.addRVariable("steering", (-accelometer.angle / 90).toFixed(1))
            json.addVariable("trottle", (buttonPanel.pressed) ?(sliderPanel.slider.data * 100).toFixed(0) :0)
            json.addVariable("reverse", buttonPanel.reverse)
            socket.sendTextMessage(json.data)
        }

        onDataChanged: socket.sendData()
    }

    //IP INPUT
    TextField {
        id: inputID

        placeholderText: "Zadejte IP"
        onAccepted: {
            socket.url = "ws://" + inputID.text + "/ws/control"
            socket.active = true
            console.log(socket.url)
            inputID.visible = false
        }
    }

    //------------------------------------

    //----------------JSON----------------
    JSONParser {
        id: parser
    }

    //------------------------------------

    //-------------ACCELOMETER------------
    Sensors.Accelerometer {
        id: accelometer

        property real tolerance: 0.3
        property real lock: 45
        property int previous: 11
        property real angle

        Behavior on angle {
            NumberAnimation { duration: 300 }
        }

        active: true
        dataRate: 10000

        onReadingChanged: {
            var value = -accelometer.reading.y

            value = (value *9 >= accelometer.lock) ? accelometer.lock / 9 :value
            value = (value * 9 <= -accelometer.lock) ?(-accelometer.lock) / 9: value
            accelometer.angle = value * 9

            if(value + accelometer.tolerance <= accelometer.previous || value - accelometer.tolerance >= accelometer.previous) {
                accelometer.previous = value
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
