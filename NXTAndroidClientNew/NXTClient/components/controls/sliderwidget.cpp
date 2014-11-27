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

    this->update();
}

void SliderWidget::paint(QPainter *painter)
{
    painter->setRenderHint(QPainter::HighQualityAntialiasing);

    painter->setPen(QPen(p_backgroundColor));
    painter->setBrush(QBrush(p_backgroundColor));
    painter->drawRect(boundingRect());

    painter->setPen(QPen(p_activeColor));
    painter->setBrush(QBrush(p_activeColor));
    painter->drawRect(boundingRect().x(), boundingRect().y() + (1.0 - p_data) * boundingRect().height(), boundingRect().width(), p_data * boundingRect().height());
}

void SliderWidget::setActiveColor(QColor &value)
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

QColor SliderWidget::activeColor() const
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
