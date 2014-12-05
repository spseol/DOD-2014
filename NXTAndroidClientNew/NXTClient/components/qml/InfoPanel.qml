import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    property alias connectionText: connetionText
    //---------------INFO----------------
    //SPEED
    LinearGradient {
        id: speedInfo

        width: parent.width
        height: parent.height / 2

        start: Qt.point(x + width / 2, y)
        end: Qt.point(x, y + height - 1)

        gradient: Gradient {
                    GradientStop { position: 0.0; color: "#2B2B2B" }
                    GradientStop { position: 1.0; color: "#1D1D1D" }
        }

        //SPEED LABEL
        Text {
            id: speedLabel

            y: parent.height / 10

            text: "Speed level"
            color: "white"

            font.pixelSize: parent.height / 16
            font.family: helveticaBlack.name

            anchors.horizontalCenter: parent.horizontalCenter
        }

        //SPEED VALUE
        Text {
            id: speedText

            text: (sliderPanel.slider.data * 100).toFixed(0) + "%"
            color: "white"

            font.pixelSize: parent.height / 8
            font.family: helveticaLight.name

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: speedLabel.bottom
            anchors.topMargin: speedLabel.height / 2
        }
    }

    //CONNECTION
    Rectangle {
        width: speedInfo.width
        height: speedInfo.height

        color: "#171717"

        anchors.top: speedInfo.bottom

        //APP NAME
        Text {
            id: nameLabel

            y: parent.height / 1.6

            text: "NXT Driver"
            color: "white"

            font.pixelSize: parent.height / 8
            font.family: helveticaLight.name

            anchors.horizontalCenter: parent.horizontalCenter
        }

        //SOCKET STATUS
        Text {
            id: connetionText

            text: "Closed"
            color: "white"

            font.pixelSize: parent.height / 16
            font.family: helveticaBlack.name

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: nameLabel.bottom
            anchors.topMargin: nameLabel.height / 4
        }
    }
    //-----------------------------------
}
