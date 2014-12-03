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
    Q_PROPERTY(int edgeWidth READ edgeWidth WRITE setEdgeWidth NOTIFY edgeWidthChanged)
    Q_PROPERTY(int arrowWidth READ arrowWidth WRITE setArrowWidth NOTIFY arrowWidthChanged)

    private:
        qreal p_angle;
        QColor p_color;
        QColor p_edgeColor;
        QColor p_arrowColor;
        int p_edgeWidth;
        int p_arrowWidth;

        QString fontFamily;

    public:
        explicit AccelometerWidget(QQuickItem *parent = 0);

        virtual void paint(QPainter *painter);

        /*---Setters and getters---*/
        void setAngle(qreal& value);
        void setColor(QColor& value);
        void setEdgeColor(QColor& value);
        void setArrowColor(QColor& value);
        void setEdgeWidth(int& value);
        void setArrowWidth(int& value);

        qreal angle() const;
        QColor color() const;
        QColor edgeColor() const;
        QColor arrowColor() const;
        int edgeWidth() const;
        int arrowWidth() const;
        /*-------------------------*/

    public slots:
        void handleTouch(QPoint p);

    signals:
        void touched();

        void angleChanged();
        void colorChanged();
        void edgeColorChanged();
        void arrowColorChanged();
        void edgeWidthChanged();
        void arrowWidthChanged();
};

#endif // ACCELOMETERWIDGET_H
