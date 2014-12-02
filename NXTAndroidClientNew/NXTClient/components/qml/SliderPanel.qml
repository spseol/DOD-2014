import QtQuick 2.3
import SliderWidget 1.0

Item {
    property alias slider: speedSlider
    //----------------SPEED---------------
    SliderWidget {
        id: speedSlider

        property int previous: 0

        width: parent.width
        height: parent.height

        activeColor: ["#00D2C2", "#00B2A4"]
        backgroundColor: "white"

        data: 0

        onDataChanged: {
            var value = (data * 100).toFixed(0)
            var tolerance = 2
            var previous = speedSlider.previous

            if(buttonPanel.pressed)
                if(previous + tolerance <= value || previous - tolerance >= value) {
                    speedSlider.previous = value
                    socket.dataChanged()
                }
        }
    }

    //TOP ARROW
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

    //BOTTOM ARROW
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
    //------------------------------------
}
