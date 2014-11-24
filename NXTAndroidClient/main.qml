import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtSensors 5.0 as Sensors

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Item {
        id: filler
        anchors.fill: parent
    }

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

    Rectangle {
        id: mask

        property real tolerance: 0.1
        property int previous: 11

        y: 0 - height
        width: Math.sqrt(Math.pow(filler.width, 2) + Math.pow(filler.height, 2))
        height: filler.height * 1.5
        color: Qt.rgba(255, 255, 255, 0.7)

        Behavior on rotation {
            RotationAnimation { duration: 300 }
        }
    }

    Sensors.Accelerometer {
        id: accelometer

        active: true
        dataRate: 10000

        onReadingChanged: {
            var value = -(accelometer.reading.y)

            if(value > 0 && mask.rotation > 0) {
                mask.transformOrigin = Item.BottomLeft
                mask.x = 0
            }

            else if(value < 0 && mask.rotation < 0){
                mask.transformOrigin = Item.BottomRight
                mask.x = 0 - (mask.width - filler.width)
            }

            mask.rotation = 9 * value

            if(value + mask.tolerance <= mask.previous || value - mask.tolerance >= mask.previous) {
                mask.previous = value
                //console.log(value)
            }
        }
    }
}
