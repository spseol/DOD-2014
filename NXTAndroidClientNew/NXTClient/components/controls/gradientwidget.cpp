#include "gradientwidget.h"
#include <QtMath>
#include "../../logic/touchlogic.h"

GradientWidget::GradientWidget(QQuickItem *parent) :
    QQuickPaintedItem(parent)
{
    p_pressed = false;
}

void GradientWidget::handleTouch(QPoint p, int ID, QString type = "pressed")
{
    QObject *parent = this->parent();

    p.rx() -= parent->property("x").toDouble() + this->x();
    p.ry() -= parent->property("y").toDouble() + this->y();

    if(TouchLogic::isInRect(p, boundingRect()) && !p_pressed && type == "pressed")
    {
        p_ID = ID;
        setPressed(true); //because of emit signal
        emit touched();
    }

    else if(((!TouchLogic::isInRect(p, boundingRect()) && p_pressed && type == "pressed") || (TouchLogic::isInRect(p, boundingRect()) && type == "release" && p_pressed)) && p_ID == ID)
    {
        setPressed(false); //because of emit signal
        emit released();
    }
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

void GradientWidget::setPressed(bool value)
{
    if(p_pressed != value)
    {
        p_pressed = value;
        emit pressedChanged();
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

bool GradientWidget::pressed() const
{
    return p_pressed;
}


