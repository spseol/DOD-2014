import QtQuick 2.3
import QtQuick.Controls 1.2
import Qt.WebSockets 1.0
import QtSensors 5.0 as Sensors
import GradientWidget 1.0
import AccelometerWidget 1.0

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

    AccelometerWidget {
        width: root.width * 0.35
        height: width
        edgeColor: "#393939"
        color: "#181818"
        arrowColor: "#E09E01"
        arrowWidth: width * 0.1
        edgeWidth: width * 0.1
        angle: Math.abs(accelometer.angle)

        anchors.centerIn: filler
    }

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

            if(raw_value + accelometer.tolerance <= accelometer.previous || raw_value - accelometer.tolerance >= accelometer.previous) {
                accelometer.previous = value
            }
        }
    }
    //------------------------------------
}
