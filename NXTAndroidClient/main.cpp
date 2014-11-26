#include <QApplication>
#include <QQmlApplicationEngine>
#include "components/parser/jsonmodel.h"
#include "components/controls/sliderwidget.h"
#include <QtQml>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    qmlRegisterType<JSONModel>("JSONModel", 1, 0, "JSONModel");
    qmlRegisterType<SliderWidget>("SliderWidget", 1, 0, "SliderWidget");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
