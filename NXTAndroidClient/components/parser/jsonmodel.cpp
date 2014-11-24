#include "jsonmodel.h"

JSONModel::JSONModel(QObject *parent) :
    QObject(parent)
{
    clearData();
}

void JSONModel::clearData()
{
    p_data = "{ ";
}

void JSONModel::addVariable(const QString name, int value)
{
    p_data.append("\"");
    p_data.append(name);
    p_data.append("\":");
    p_data.append(QString::number(value));
    p_data.append(",");
}

void JSONModel::setData(QString &value)
{
    if(value != p_data)
    {
        p_data = value;
        emit dataChanged();
    }
}

QString JSONModel::data() {
    QString result = p_data.remove(p_data.length() - 1, 1);
    result.append(" }");

    return result;
}
