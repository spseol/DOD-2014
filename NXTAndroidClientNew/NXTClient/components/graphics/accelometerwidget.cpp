#include "accelometerwidget.h"

AccelometerWidget::AccelometerWidget(QQuickItem *parent) :
    QQuickPaintedItem(parent)
{
}

void AccelometerWidget::paint(QPainter *painter)
{

}

/*-------------------------------------*/
/*---------------SETTERS---------------*/
/*-------------------------------------*/

void AccelometerWidget::setAngle(qreal &value)
{
    if(p_angle != value)
    {
        p_angle = value;
        emit angleChanged();
    }
}

void AccelometerWidget::setColor(QColor &value)
{
    if(p_color != value)
    {
        p_color = value;
        emit colorChanged();
    }
}

void AccelometerWidget::setEdgeColor(QColor &value)
{
    if(p_edgeColor != value)
    {
        p_edgeColor = value;
        emit edgeColorChanged();
    }
}

void AccelometerWidget::setArrowColor(QColor &value)
{
    if(p_arrowColor != value)
    {
        p_arrowColor = value;
        emit arrowColorChanged();
    }
}

/*-------------------------------------*/
/*---------------GETTERS---------------*/
/*-------------------------------------*/

qreal AccelometerWidget::angle() const
{
    return p_angle;
}

QColor AccelometerWidget::color() const
{
    return p_color;
}

QColor AccelometerWidget::edgeColor() const
{
    return p_edgeColor;
}

QColor AccelometerWidget::arrowColor() const
{
    return p_arrowColor;
}
