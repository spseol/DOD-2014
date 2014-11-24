#include <QApplication>
#include <QQmlApplicationEngine>
#include"components/parser/jsonmodel.h"
#include <QtQml>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    qmlRegisterType<JSONModel>("JSONModel", 1, 0, "JSONModel");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
