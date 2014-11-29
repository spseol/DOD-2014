import QtQuick 2.3
import QtQuick.Controls 1.2
import Qt.WebSockets 1.0
import QtSensors 5.0 as Sensors

import GradientWidget 1.0
import AccelometerWidget 1.0
import SliderWidget 1.0

ApplicationWindow {
    id: root

    visible: true
    width: 640
    height: 480

    Item {
        id: filler
        anchors.fill: parent
    }

    //-------------START STOP-------------
    GradientWidget {
        id: goWidget

        width: root.width * 0.375
        height: root.height * 0.5

        startPoint: GradientWidget.TopRightCorner
        colors: ["#00C538", "#00E054"]

        Image {
            source: "resources/images/black_arrow.svg"

            width: goWidget.width / 7
            height: width

            sourceSize.width: goWidget.width / 7
            sourceSize.height: goWidget.height /7

            anchors.bottom: goText.top
            anchors.horizontalCenter: goText.horizontalCenter
        }

        Text {
            id: goText

            text: "GO"

            y: goWidget.height / 2 - goText.height / 2
            x: goWidget.width / 2 - goText.width / 2

            font.pixelSize: goWidget.height / 3
            font.family: startstopFont.name
        }
    }

    GradientWidget {
        id: stopWidget

        width: goWidget.width
        height: goWidget.height

        startPoint: GradientWidget.TopLeftCorner
        colors: ["#C40001", "#EF0039"]

        anchors.top: goWidget.bottom
    }
    //------------------------------------

    //----------------SPEED---------------
    SliderWidget {
        id: speedSlider

        width: root.width * 0.375
        height: root.height

        activeColor: ["#00D2C2", "#00B2A4"]
        backgroundColor: "white"

        data: 0

        anchors.right: filler.right
    }

    MouseArea {
        anchors.fill: speedSlider

        onPressed: speedSlider.handleMousePressed(mouse.y)
        onMouseYChanged: speedSlider.handleMouseMove(mouse.y, pressed)
    }
    //------------------------------------

    //--------------"COMPASS"-------------
    AccelometerWidget {
        width: root.width * 0.35
        height: width

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

        active: false
        url: "ws://192.168.2.104:8888/ws/control"

        onStatusChanged: {
            var actualStatus = socket.status

            switch(actualStatus) {
                case WebSocket.Connecting:
                    console.log("Connecting");
                    break;

                case WebSocket.Open:
                    console.log("Open");
                    break;

                case WebSocket.Closing:
                    console.log("Closing");
                    break;

                case WebSocket.Closed:
                    console.log("Closed")
                    break;

                case WebSocket.Error:
                    console.log("Error (" + socket.errorString + ")")
                    break;
            }
        }
    }

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
            var value = -(accelometer.reading.y)

            value = (value *9 >= accelometer.lock) ? accelometer.lock / 9 :value
            value = (value * 9 <= -accelometer.lock) ?(-accelometer.lock) / 9: value
            accelometer.angle = value * 9

            if(value + accelometer.tolerance <= accelometer.previous || value - accelometer.tolerance >= accelometer.previous) {
                accelometer.previous = value
            }
        }
    }
    //------------------------------------

    //--------------RESOURCES-------------
    FontLoader {
        id: startstopFont
        source: "resources/fonts/DIN.ttf"
    }
    //------------------------------------
}
