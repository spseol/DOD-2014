import QtQuick 2.3
import QtQuick.Controls 1.2
import Qt.WebSockets 1.0
import QtSensors 5.0 as Sensors
import QtGraphicalEffects 1.0

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
    //GO
    GradientWidget {
        id: goWidget

        width: root.width * 0.375
        height: root.height * 0.5

        startPoint: GradientWidget.TopRightCorner
        colors: ["#00C538", "#00E054"]

        Image {
            id: blackArrow

            source: "resources/images/black_arrow.svg"

            width: goWidget.width / 7
            height: width

            sourceSize.width: goWidget.width / 7
            sourceSize.height: goWidget.height /7

            anchors.bottom: goText.top
            anchors.bottomMargin: height / 3
            anchors.horizontalCenter: goText.horizontalCenter
        }

        Text {
            id: goText

            text: "GO"

            y: (goWidget.height + blackArrow.height) / 2 - goText.height / 2
            x: goWidget.width / 2 - goText.width / 2

            font.pixelSize: goWidget.height / 3
            font.family: startstopFont.name
        }
    }

    //STOP
    GradientWidget {
        id: stopWidget

        width: goWidget.width
        height: goWidget.height

        startPoint: GradientWidget.TopLeftCorner
        colors: ["#C40001", "#EF0039"]

        anchors.top: goWidget.bottom

        Image {
            id: whiteArrow

            source: "resources/images/white_arrow.svg"

            width: stopWidget.width / 7
            height: width
            rotation: 180

            sourceSize.width: stopWidget.width / 7
            sourceSize.height: stopWidget.height /7

            anchors.bottom: stopText.top
            anchors.bottomMargin: height / 3
            anchors.horizontalCenter: stopText.horizontalCenter
        }

        Text {
            id: stopText

            text: "BACK"
            color: "white"

            y: (stopWidget.height + blackArrow.height) / 2 - stopText.height / 2
            x: stopWidget.width / 2 - stopText.width / 2

            font.pixelSize: stopWidget.height / 3
            font.family: startstopFont.name
        }
    }
    //------------------------------------

    //---------------INFO----------------
    LinearGradient {
        id: angleInfo

        width: root.width * 0.25
        height: root.height / 2

        anchors.left: stopWidget.right

        start: Qt.point(angleInfo.x + angleInfo.width / 2, angleInfo.y)
        end: Qt.point(angleInfo.x, angleInfo.y + angleInfo.height - 1)

        gradient: Gradient {
                    GradientStop { position: 0.0; color: "#2B2B2B" }
                    GradientStop { position: 1.0; color: "#1D1D1D" }
        }

        Text {
            id: speedLabel

            y: angleInfo.height / 5.5

            text: "Speed level"
            color: "white"

            font.pixelSize: angleInfo.height / 16
            font.family: helveticaBlack.name

            anchors.horizontalCenter: angleInfo.horizontalCenter
        }

        Text {
            id: speedText

            text: (speedSlider.data * 100).toFixed(0) + "%"
            color: "white"

            font.pixelSize: angleInfo.height / 8
            font.family: helveticaLight.name

            anchors.horizontalCenter: angleInfo.horizontalCenter
            anchors.top: speedLabel.bottom
            anchors.topMargin: speedLabel.height / 2
        }
    }

    Rectangle {
        width: angleInfo.width
        height: angleInfo.height

        color: "#171717"

        anchors.bottom: filler.bottom
        anchors.left: stopWidget.right
    }

    //-----------------------------------

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
