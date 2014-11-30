#include "gradientwidget.h"
#include <QtMath>

GradientWidget::GradientWidget(QQuickItem *parent) :
    QQuickPaintedItem(parent)
{
}

void GradientWidget::paint(QPainter *painter)
{
    QPointF start;
    QPointF stop;

    const qreal boundX = boundingRect().x();
    const qreal boundY = boundingRect().y();
    const qreal boundHeight = boundingRect().height();
    const qreal boundWidth = boundingRect().width();

    qreal diagonal = qSqrt(qPow(boundWidth, 2) + qPow(boundHeight, 2));
    qreal b = diagonal / 2.0;
    qreal alpha = qAtan(boundHeight / boundWidth);
    qreal c = b / qCos(alpha);

    switch (p_startPoint) {
        case TopLeftCorner:
            start.setX(boundX + (boundWidth - c));
            start.setY(boundY);

            stop.setX(boundX + c);
            stop.setY(boundY + boundHeight);
            break;

        case TopRightCorner:
            start.setX(boundX + c);
            start.setY(boundY);

            stop.setX(boundX + (boundWidth - c));
            stop.setY(boundY + boundHeight);
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
