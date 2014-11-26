import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtSensors 5.0 as Sensors
import JSONModel 1.0
import SliderWidget 1.0
import Qt.WebSockets 1.0

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Item {
        id: filler
        anchors.fill: parent
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

    //------------------------------------

    //----------------DATA----------------
    Rectangle {
        id: infoWidget

        width: filler.width * (3.0 / 13.0)
        height: filler.height
        color: "lightGray"

        anchors.right: goWidget.left

        Item {
            anchors.centerIn: parent

            Text {
                id: angleInfo

                text: mask.rotation.toFixed(0) + "°"
                color: "gray"

                font.pixelSize: filler.height / 8

                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
    //------------------------------------

    //----------------PEDAL---------------
    Rectangle {
        id: goWidget

        width: filler.width * (5.0 / 13.0)
        height: filler.height
        color: "red"

        anchors.right: filler.right

        Text {
            text: qsTr("GO")
            color: "white"

            font.bold: Font.Black
            font.family: "RobotoBlack"
            font.pixelSize: filler.height / 5

            anchors.centerIn: parent
        }
    }
    //------------------------------------

    SliderWidget {
        anchors.left: filler.left
        width: 200
        height: filler.height
         data: 0.70
        activeColor: "cyan"
        backgroundColor: "gray"
    }

    Rectangle {
        id: mask

        y: 0 - height
        width: Math.sqrt(Math.pow(filler.width, 2) + Math.pow(filler.height, 2))
        height: filler.width
        color: Qt.rgba(255, 255, 255, 0.7)

        Behavior on rotation {
            RotationAnimation { duration: 300 }
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

    Sensors.Accelerometer {
        id: accelometer

        property real tolerance: 1
        property int previous: 11

        active: true
        dataRate: 10000

        onReadingChanged: {
            var value = -(accelometer.reading.x)

            if(value > 0 && mask.rotation > 0) {
                mask.transformOrigin = Item.BottomLeft
                mask.x = 0
            }

            else if(value < 0 && mask.rotation < 0){
                mask.transformOrigin = Item.BottomRight
                mask.x = 0 - (mask.width - filler.width)
            }

            mask.rotation = 9 * value

            if(value + accelometer.tolerance <= accelometer.previous || value - accelometer.tolerance >= accelometer.previous) {
                accelometer.previous = value
                //console.log(value)
            }
        }
    }
}
