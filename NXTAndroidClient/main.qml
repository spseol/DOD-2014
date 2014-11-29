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
    //flags: ApplicationWindow.FullScreen

    Item {
        id: filler
        anchors.fill: parent
    }

    JSONModel {
        id: json
    }

    //------------DATA TRANSFER-----------
    WebSocket {
        id: socket

        property bool openR: false

        active: true
        url: "ws://192.168.43.212:8888/ws/control"

        onTextMessageReceived: console.log(message)

        function sendData() {
            if(!socket.active || !socket.openR)
                return;

            json.clearData()
            json.addRVariable("steering", (-accelometer.angle / 90).toFixed(1))
            json.addVariable("trottle", (goWidget.run) ?100 :0)
            json.addVariable("reverse", goWidget.reverse)
            socket.sendTextMessage(json.data)
        }


        onStatusChanged: {
            var actualStatus = socket.status

            switch(actualStatus) {
                case WebSocket.Connecting:
                    console.log("Connecting");
                    break;

                case WebSocket.Open:
                    socket.openR = true
                    console.log("Open");
                    break;

                case WebSocket.Closing:
                    console.log("Closing");
                    break;

                case WebSocket.Closed:
                    //socket.openR = false
                    console.log("Closed")
                    break;

                case WebSocket.Error:
                    console.log("Error (" + socket.errorString + ")")
                    break;
            }
        }
    }

    //------------------------------------

    //----------------SPEED---------------
    SliderWidget {
        id: slider

        width: filler.width * (5.0 / 13.0)
        height: filler.height
        data: 0.70
        activeColor: "cyan"
        backgroundColor: "lightGray"

        anchors.left: filler.left
    }

    MouseArea {
        anchors.fill: slider
        onPressed: slider.handleMousePressed(mouse.y)
        onMouseYChanged: slider.handleMouseMove(mouse.y, pressed)
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

                text: accelometer.angle.toFixed(0) + "°"
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

        property int reverse: 0
        property int run: 0

        width: filler.width * (5.0 / 13.0)
        height: filler.height
        color: "red"

        anchors.right: filler.right

        onRunChanged: socket.sendData()
        onReverseChanged: socket.sendData()

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(mouse.y >= goWidget.height / 2) {
                    goWidget.reverse = 1
                }

                else
                    goWidget.reverse = 0
            }

            onPressed: goWidget.run = 1
            onReleased: goWidget.run = 0
        }

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
            //socket.url = "ws://" + inputID.text + "/ws/control"
            //socket.active = true
            console.log("------------------------------------------------------------")
            console.log(socket.url)
            inputID.visible = false
        }
    }

    Sensors.Accelerometer {
        id: accelometer

        property real tolerance: 0.05
        property real lock: (Math.atan(filler.height / filler.width) / Math.PI) * 180
        property int previous: 11
        property real angle


        Behavior on angle {
            NumberAnimation { duration: 300 }
        }

        active: true
        dataRate: 10000

        //onAngleChanged: socket.sendData()

        onReadingChanged: {
            var value = -(accelometer.reading.y)
            var raw_value = -accelometer.reading.y

            if(value > 0 && mask.rotation > 0) {
                mask.transformOrigin = Item.BottomLeft
                mask.x = 0
            }

            else if(value < 0 && mask.rotation < 0){
                mask.transformOrigin = Item.BottomRight
                mask.x = 0 - (mask.width - filler.width)
            }

            value = (value *9 >= accelometer.lock) ? accelometer.lock / 9 :value
            value = (value * 9 <= -accelometer.lock) ?(-accelometer.lock) / 9: value
            mask.rotation = 9 * value
            accelometer.angle = raw_value * 9

            if(raw_value + accelometer.tolerance <= accelometer.previous || raw_value - accelometer.tolerance >= accelometer.previous ) {
                //console.log(accelometer.previous - raw_value)
                accelometer.previous = raw_value
                socket.sendData();
            }
        }
    }
}
