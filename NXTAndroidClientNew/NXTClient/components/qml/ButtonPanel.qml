import QtQuick 2.0
import GradientWidget 1.0

Item {
    id: buttonGroup

    property int reverse: stopWidget.pressed
    property bool pressed: (goWidget.pressed || stopWidget.pressed)
    property alias goWidget: goWidget
    property alias stopWidget: stopWidget
    //-------------START STOP-------------
    //GO
    GradientWidget {
        id: goWidget

        width: parent.width
        height: parent.height / 2

        startPoint: GradientWidget.TopRightCorner
        colors: ["#00C538", "#00E054"]

        //ARROW
        Image {
            id: blackArrow

            source: "../../resources/images/black_arrow.svg"

            width: goWidget.width / 7
            height: width

            sourceSize.width: goWidget.width / 7
            sourceSize.height: goWidget.height /7

            anchors.bottom: goText.top
            anchors.bottomMargin: height / 3
            anchors.horizontalCenter: goText.horizontalCenter
        }

        //LABEL
        Text {
            id: goText

            text: "GO"

            y: (goWidget.height + blackArrow.height) / 2 - goText.height / 2
            x: goWidget.width / 2 - goText.width / 2

            font.pixelSize: goWidget.height / 3
            font.family: startstopFont.name
        }

        onTouched: socket.dataChanged()
        onReleased: socket.dataChanged()
    }

    //STOP
    GradientWidget {
        id: stopWidget

        width: goWidget.width
        height: goWidget.height

        startPoint: GradientWidget.TopLeftCorner
        colors: ["#C40001", "#EF0039"]

        anchors.top: goWidget.bottom

        //ARROW
        Image {
            id: whiteArrow

            source: "../../resources/images/white_arrow.svg"

            width: stopWidget.width / 7
            height: width
            rotation: 180

            sourceSize.width: stopWidget.width / 7
            sourceSize.height: stopWidget.height /7

            anchors.bottom: stopText.top
            anchors.bottomMargin: height / 3
            anchors.horizontalCenter: stopText.horizontalCenter
        }

        //LABEL
        Text {
            id: stopText

            text: "BACK"
            color: "white"

            y: (stopWidget.height + blackArrow.height) / 2 - stopText.height / 2
            x: stopWidget.width / 2 - stopText.width / 2

            font.pixelSize: stopWidget.height / 3
            font.family: startstopFont.name
        }

        onTouched: socket.dataChanged()
        onReleased: socket.dataChanged()
    }
    //------------------------------------
}
