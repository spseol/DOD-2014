#ifndef ACCELOMETERWIDGET_H
#define ACCELOMETERWIDGET_H

#include <QQuickPaintedItem>
#include <QPainter>

class AccelometerWidget : public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(qreal angle READ angle WRITE setAngle NOTIFY angleChanged)
    Q_PROPERTY(QColor arrowColor READ arrowColor WRITE setArrowColor NOTIFY arrowColorChanged)
    Q_PROPERTY(QColor edgeColor READ edgeColor WRITE setEdgeColor NOTIFY edgeColorChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)

    private:
        qreal p_angle;
        QColor p_color;
        QColor p_edgeColor;
        QColor p_arrowColor;

    public:
        explicit AccelometerWidget(QQuickItem *parent = 0);

        virtual void paint(QPainter *painter);

        /*---Setters and getters---*/
        void setAngle(qreal& value);
        void setColor(QColor& value);
        void setEdgeColor(QColor& value);
        void setArrowColor(QColor& value);

        qreal angle() const;
        QColor color() const;
        QColor edgeColor() const;
        QColor arrowColor() const;
        /*-------------------------*/

    signals:
        void angleChanged();
        void colorChanged();
        void edgeColorChanged();
        void arrowColorChanged();
};

#endif // ACCELOMETERWIDGET_H
