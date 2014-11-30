#include "touchlogic.h"
#include <QRectF>
#include <QDebug>

TouchLogic::TouchLogic(QObject *parent) :
    QObject(parent)
{
}

bool TouchLogic::isInRect(int x, int y, QRectF rect)
{
    qDebug() <<"x: "<< x <<"---" <<rect.x() << "/" << rect.width();
    qDebug() <<"y: "<< y <<"---" <<rect.y() << "/" << rect.height();
    if(x >= rect.x() && x <= rect.x() + rect.width() && y >= rect.y() && y <= rect.y() + rect.height())
        return true;

    else
        return false;
}

bool TouchLogic::isInRect(QPointF point, QRectF rect)
{
    qDebug() <<"x: "<< point.x() <<"---" <<rect.x() << "/" << rect.width();
    qDebug() <<"y: "<< point.y() <<"---" <<rect.y() << "/" << rect.height();
    if(point.x() >= rect.x() && point.x() <= rect.x() + rect.width() && point.y() >= rect.y() && point.y() <= rect.y() + rect.height())
        return true;

    else
        return false;
}
