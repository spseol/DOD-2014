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

        data: 0
    }

    Image {
        id: topArrow

        y: parent.height - (speedSlider.data * parent.height) + height

        width: root.width * 0.054
        height: width
        rotation: 270
        source: "../../resources/images/white_arrow.svg"

        sourceSize.width: root.width * 0.054
        sourceSize.height: root.width * 0.054

        anchors.horizontalCenter: parent.horizontalCenter
    }

    Image {
        id: bottomArrow

        width: topArrow.width
        height: topArrow.height
        rotation: 90
        source: "../../resources/images/white_arrow.svg"

        sourceSize.width: topArrow.width
        sourceSize.height: topArrow.height

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: topArrow.bottom
        anchors.topMargin: height / 4
    }

    MouseArea {
        anchors.fill: speedSlider

        onPressed: speedSlider.handleMousePressed(mouse.y)
        onMouseYChanged: speedSlider.handleMouseMove(mouse.y, pressed)
    }
    //------------------------------------
}
