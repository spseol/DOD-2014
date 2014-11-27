#ifndef GRADIENTWIDGET_H
#define GRADIENTWIDGET_H

#include <QQuickPaintedItem>
#include <QPainter>

class GradientWidget : public QQuickPaintedItem
{
    Q_OBJECT

    Q_ENUMS(point)
    Q_PROPERTY(int startPoint READ startPoint WRITE setStartPoint NOTIFY startPointChanged)
    Q_PROPERTY(QStringList colors WRITE setColors NOTIFY colorsChanged)

    private:
        int p_startPoint;
        QStringList p_colors;

    public:
        enum point { TopLeftCorner, TopRightCorner };

        explicit GradientWidget(QQuickItem *parent = 0);

        virtual void paint(QPainter *painter);

        /*---Setters and getters---*/
        void setStartPoint(int& value);
        void setColors(QStringList& value);

        int startPoint() const;
        /*-------------------------*/

    signals:
        void startPointChanged();
        void colorsChanged();
};

#endif // GRADIENTWIDGET_H
