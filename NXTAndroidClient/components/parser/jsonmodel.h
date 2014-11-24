#ifndef JSONMODEL_H
#define JSONMODEL_H

#include <QObject>

class JSONModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString data READ data WRITE setData NOTIFY dataChanged)

    private:
        QString p_data;

    public:
        explicit JSONModel(QObject *parent = 0);

        Q_INVOKABLE void addVariable(const QString name, int value);
        Q_INVOKABLE void clearData();

        /*---Setters and getters---*/
        void setData(QString& value);

        QString data();
        /*-------------------------*/

    signals:
        void dataChanged();
};

#endif // JSONMODEL_H
