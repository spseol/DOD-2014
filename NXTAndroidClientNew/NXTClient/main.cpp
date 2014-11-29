#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "components/controls/gradientwidget.h"
#include "components/graphics/accelometerwidget.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    qmlRegisterType<AccelometerWidget>("AccelometerWidget", 1, 0, "AccelometerWidget");
    qmlRegisterType<GradientWidget>("GradientWidget", 1, 0, "GradientWidget");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
