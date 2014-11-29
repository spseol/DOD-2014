#include "accelometerwidget.h"

AccelometerWidget::AccelometerWidget(QQuickItem *parent) :
    QQuickPaintedItem(parent)
{
}

void AccelometerWidget::paint(QPainter *painter)
{
    const int boundX = boundingRect().x();
    const int boundY = boundingRect().y();
    const int boundHeight = boundingRect().height();
    const int boundWidth = boundingRect().width();
    const QPointF center = boundingRect().center();

    //draw outer circle
    painter->setPen(QPen(p_edgeColor));
    painter->setBrush(QBrush(p_edgeColor));
    painter->setRenderHint(QPainter::Antialiasing);
    painter->drawEllipse(boundingRect());

   //draw inner circle
    painter->setPen(QPen(p_color));
    painter->setBrush(QBrush(p_color));
    painter->setRenderHint(QPainter::Antialiasing);
    painter->drawEllipse(boundX + p_edgeWidth, boundY + p_edgeWidth, boundWidth - 2 * p_edgeWidth, boundHeight - 2 * p_edgeWidth);

    //draw arrow
    //set triangle path
    QPainterPath path;
    path.moveTo(p_arrowWidth / 2, 0);
    path.lineTo(0, boundHeight /2 - p_edgeWidth * 0.75);
    path.lineTo(- p_arrowWidth / 2, 0);
    path.lineTo( - p_arrowWidth / 2, 0);

    //set painter
    painter->setPen(QPen(p_arrowColor));
    painter->setBrush(QBrush(p_arrowColor));
    painter->translate(center.x(), center.y());
    painter->rotate(p_angle + 180);
    painter->setRenderHint(QPainter::Antialiasing);
    painter->drawPath(path);

    //draw text
    painter->resetTransform();
    painter->setFont(QFont("Arial Narrow", boundHeight / 3.5, QFont::Black));
    painter->setPen(QPen(QColor("white")));
    painter->setBrush(QBrush(QColor("white")));
    painter->drawText(boundingRect(), Qt::AlignCenter, QString::number(p_angle).append("°"));
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

void AccelometerWidget::setEdgeWidth(int &value)
{
    if(p_edgeWidth != value)
    {
        p_edgeWidth = value;
        emit edgeWidthChanged();
    }
}

void AccelometerWidget::setArrowWidth(int &value)
{
    if(p_arrowWidth != value)
    {
        p_arrowWidth = value;
        emit arrowWidthChanged();
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

int AccelometerWidget::edgeWidth() const
{
    return p_edgeWidth;
}

int AccelometerWidget::arrowWidth() const
{
    return p_arrowWidth;
}
