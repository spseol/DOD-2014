#ifndef SLIDERWIDGET_H
#define SLIDERWIDGET_H

#include <QQuickPaintedItem>
#include <QPainter>

class SliderWidget : public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(QColor activeColor READ activeColor WRITE setActiveColor NOTIFY activeColorChanged)
    Q_PROPERTY(QColor backgroundColor READ backgroundColor WRITE setBackgroundColor NOTIFY backgroundColorChanged)
    Q_PROPERTY(qreal data READ data WRITE setData NOTIFY dataChanged)

    private:
        QColor p_activeColor;
        QColor p_backgroundColor;
        qreal p_data;

        int mouseY;

    public:
        explicit SliderWidget(QQuickItem *parent = 0);

        virtual void paint(QPainter *painter);

        /*---Setters and getters---*/
        void setActiveColor(QColor& value);
        void setBackgroundColor(QColor& value);
        void setData(qreal& value);

        QColor activeColor() const;
        QColor backgroundColor() const;
        qreal data()const;
        /*-------------------------*/

    public slots:
        void handleMousePressed(int y);
        void handleMouseMove(int y, bool pressed);

    signals:
        void activeColorChanged();
        void backgroundColorChanged();
        void dataChanged();
};

#endif // SLIDERWIDGET_H
