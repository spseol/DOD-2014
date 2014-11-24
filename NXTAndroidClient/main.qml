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
    //--------------------------------------
    Rectangle {
        id: background
        anchors.fill: filler

        color: "orange"
    }

    Rectangle {
        color: "cyan"
        height: filler.height
        width: 120
    }

    Rectangle {
        color: "lightGray"
        height: filler.height
        width: 120
        x: 120
    }
    //------------------------------------------

    Rectangle {
        id: goWidget

        width: filler.width / 3.0
        height: filler.height
        color: "red"
        anchors.right: filler.right
    }

    Rectangle {
        id: mask

        property real tolerance: 0.1
        property int previous: 11

        y: 0 - height
        width: Math.sqrt(Math.pow(filler.width, 2) + Math.pow(filler.height, 2))
        height: filler.height * 1.5
        color: Qt.rgba(255, 255, 255, 0.2)//"#FFC90E"

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
