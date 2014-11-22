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

    Slider {
        width: 400
        style: SliderStyle {
                groove: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 8
                    color: "gray"
                    radius: 8

                    Rectangle {
                        z: 2
                        height: parent.height
                        width: styleData.handlePosition
                        color: "orange"
                    }
                }
                handle: Rectangle {
                    anchors.centerIn: parent
                    color: control.pressed ? "white" : "lightgray"
                    border.color: "gray"
                    border.width: 2
                    implicitWidth: 34
                    implicitHeight: 34
                    radius: 12
                }
            }
    }

    Rectangle {
        id: wheel

        property int angleRot: 0
        property real tolerance: 0.1
        property int previous: 11

        rotation: wheel.angleRot
        width: 200
        height: 40
        color: "#FFC90E"

        anchors.verticalCenter: filler.verticalCenter
        anchors.horizontalCenter: filler.horizontalCenter

        Behavior on rotation {
            RotationAnimation { duration: 300 }
        }
    }

    Sensors.Accelerometer {
        id: accelometer

        active: true
        dataRate: 10000

        onReadingChanged: {
            var value = accelometer.reading.y

            wheel.angleRot = 9 * value

            if(value + wheel.tolerance <= wheel.previous || value - wheel.tolerance >= wheel.previous) {
                wheel.previous = value
                //console.log(value)
            }
        }
    }
}
