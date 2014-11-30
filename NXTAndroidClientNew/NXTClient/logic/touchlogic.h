#ifndef TOUCHLOGIC_H
#define TOUCHLOGIC_H

#include <QObject>

class TouchLogic : public QObject
{
    Q_OBJECT

    public:
        explicit TouchLogic(QObject *parent = 0);

        static bool isInRect(int x, int y, QRectF rect);
        static bool isInRect(QPointF point, QRectF rect);
};

#endif // TOUCHLOGIC_H
