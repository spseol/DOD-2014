#include "sliderwidget.h"

SliderWidget::SliderWidget(QQuickItem *parent) :
    QQuickPaintedItem(parent)
{
}

void SliderWidget::handleMousePressed(int y)
{
    mouseY = y;
}

void SliderWidget::handleMouseMove(int y, bool pressed)
{
    if(!pressed)
        return;

    qreal boundingHeight = boundingRect().height();

    p_data = (mouseY - y) / boundingHeight + (boundingHeight - mouseY) / boundingHeight;
    p_data = (p_data <= 0.0) ? 0.0 :p_data;
    p_data = (p_data >= 1.0) ? 1.0 :p_data;

    emit dataChanged();
    this->update();
}

void SliderWidget::paint(QPainter *painter)
{
    const int boundX = boundingRect().x();
    const int boundY = boundingRect().y();
    const int boundWidth = boundingRect().width();
    const int boundHeight = boundingRect().height();
    const int triangleHeight = boundHeight * 0.2;

    painter->setRenderHint(QPainter::HighQualityAntialiasing);

    painter->setPen(QPen(p_backgroundColor));
    painter->setBrush(QBrush(p_backgroundColor));
    painter->drawRect(boundingRect());

    //draw bar
    QRectF active(boundX, boundY + (1.0 - p_data) * boundHeight + triangleHeight, boundWidth, p_data * boundHeight - triangleHeight);

    QLinearGradient gradient(active.topLeft(), active.bottomLeft());

    gradient.setColorAt(0, QColor(p_activeColor[0]));
    gradient.setColorAt(1, QColor(p_activeColor[1]));

    painter->fillRect(active, gradient);

    //draw triangle
    QPainterPath path;
    path.moveTo(active.topLeft());
    path.lineTo(boundingRect().center().x(), active.y() - triangleHeight);
    path.lineTo(active.topRight());
    path.lineTo(active.topLeft());

    painter->setBrush(QBrush(QColor(p_activeColor[0])));
    painter->setPen(QPen(QColor(p_activeColor[0])));
    painter->setRenderHint(QPainter::Antialiasing);
    painter->drawPath(path);
}

/*-------------------------------------*/
/*---------------SETTERS---------------*/
/*-------------------------------------*/

void SliderWidget::setActiveColor(QStringList &value)
{
    if(p_activeColor != value)
    {
        p_activeColor = value;
        emit activeColorChanged();
    }
}

void SliderWidget::setBackgroundColor(QColor &value)
{
    if(p_backgroundColor != value)
    {
        p_backgroundColor = value;
        emit backgroundColorChanged();
    }
}

void SliderWidget::setData(qreal &value)
{
    if(p_data != value)
    {
        p_data = value;
        emit dataChanged();
    }
}

/*-------------------------------------*/
/*---------------GETTERS---------------*/
/*-------------------------------------*/

QStringList SliderWidget::activeColor() const
{
    return p_activeColor;
}

QColor SliderWidget::backgroundColor() const
{
    return p_backgroundColor;
}

qreal SliderWidget::data() const
{
    return p_data;
}
