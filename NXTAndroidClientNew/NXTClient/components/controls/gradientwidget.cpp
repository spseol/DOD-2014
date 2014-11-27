#include "gradientwidget.h"

GradientWidget::GradientWidget(QQuickItem *parent) :
    QQuickPaintedItem(parent)
{
}

void GradientWidget::paint(QPainter *painter)
{

}

void GradientWidget::setStartPoint(int &value)
{
    if(p_startPoint != value)
    {
        p_startPoint = value;
        emit startPointChanged();
    }
}

void GradientWidget::setColors(QStringList &value)
{
    if(p_colors != value)
    {
        p_colors = value;
        emit colorsChanged();
    }
}

int GradientWidget::startPoint() const
{
    return p_startPoint;
}
