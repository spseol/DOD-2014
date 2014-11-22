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
        id: wheel_1

        property int angleRot: 0
        property real tolerance: 0.1
        property int previous: 11

        width: 100
        height: 40
        color: "#FFC90E"
        transform: Rotation { axis: { x: 1; y: 0; z: 0 } angle: wheel_1.angleRot }

        anchors.verticalCenter: filler.verticalCenter
        anchors.horizontalCenter: filler.horizontalCenter

        Behavior on rotation {
            RotationAnimation { duration: 2000 }
        }

        Rectangle {
            id: wheel_2

            width: wheel_1.width
            height: wheel_1.height
            color: wheel_1.color

            anchors.right: wheel_1.left
            anchors.top: wheel_1.top
        }
    }

    Sensors.Accelerometer {
        id: accelometer

        active: true
        dataRate: 10000

        onReadingChanged: {
            var value = accelometer.reading.y

            wheel_1.angleRot = 9* value

            if(value + wheel_1.tolerance <= wheel_1.previous || value - wheel_1.tolerance >= wheel_1.previous) {
                wheel_1.previous = value
                //console.log(value)
            }
        }
    }
}
