import QtQuick 2.0
import SliderWidget 1.0

Item {
    property alias slider: speedSlider
    //----------------SPEED---------------
    SliderWidget {
        id: speedSlider

        width: parent.width
        height: parent.height

        activeColor: ["#00D2C2", "#00B2A4"]
        backgroundColor: "white"

        data: 0.5
    }

    MouseArea {
        anchors.fill: speedSlider

        onPressed: speedSlider.handleMousePressed(mouse.y)
        onMouseYChanged: speedSlider.handleMouseMove(mouse.y, pressed)
    }
    //------------------------------------
}
