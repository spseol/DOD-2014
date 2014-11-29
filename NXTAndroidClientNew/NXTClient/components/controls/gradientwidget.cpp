#include "gradientwidget.h"

GradientWidget::GradientWidget(QQuickItem *parent) :
    QQuickPaintedItem(parent)
{
}

void GradientWidget::paint(QPainter *painter)
{
    QPointF start;
    QPointF stop;

    switch (p_startPoint) {
        case TopLeftCorner:
            start = boundingRect().topLeft();
            stop = boundingRect().bottomRight();
            break;

        case TopRightCorner:
            start = boundingRect().topRight();
            stop = boundingRect().bottomLeft();
            break;
    }

    QLinearGradient gradient(start, stop);

    gradient.setColorAt(1, QColor(p_colors[0]));
    gradient.setColorAt(0.499999, QColor(p_colors[0]));
    gradient.setColorAt(0.5, QColor(p_colors[1]));

    painter->fillRect(boundingRect(), gradient);
}

/*-------------------------------------*/
/*---------------SETTERS---------------*/
/*-------------------------------------*/

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

/*-------------------------------------*/
/*---------------GETTERS---------------*/
/*-------------------------------------*/

int GradientWidget::startPoint() const
{
    return p_startPoint;
}

QStringList GradientWidget::colors() const
{
    return p_colors;
}
