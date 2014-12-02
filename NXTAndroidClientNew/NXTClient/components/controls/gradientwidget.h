#ifndef GRADIENTWIDGET_H
#define GRADIENTWIDGET_H

#include <QQuickPaintedItem>
#include <QPainter>

class GradientWidget : public QQuickPaintedItem
{
    Q_OBJECT

    Q_ENUMS(point)
    Q_PROPERTY(int startPoint READ startPoint WRITE setStartPoint NOTIFY startPointChanged)
    Q_PROPERTY(QStringList colors READ colors WRITE setColors NOTIFY colorsChanged)
    Q_PROPERTY(bool pressed READ pressed WRITE setPressed NOTIFY pressedChanged)

    private:
        int p_startPoint;
        QStringList p_colors;
        bool p_pressed;
        int p_ID;

    public:
        enum point { TopLeftCorner, TopRightCorner };

        explicit GradientWidget(QQuickItem *parent = 0);

        virtual void paint(QPainter *painter);

        /*---Setters and getters---*/
        void setStartPoint(int& value);
        void setColors(QStringList& value);
        void setPressed(bool value);

        int startPoint() const;
        QStringList colors() const;
        bool pressed() const;
        /*-------------------------*/

    public slots:
        void handleTouch(QPoint p, int ID, QString type);

    signals:
        void touched();
        void released();

        void startPointChanged();
        void colorsChanged();
        void pressedChanged();
};

#endif // GRADIENTWIDGET_H
