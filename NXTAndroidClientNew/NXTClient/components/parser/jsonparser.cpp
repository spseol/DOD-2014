#include "jsonparser.h"

JSONParser::JSONParser(QObject *parent) :
    QObject(parent)
{
    clearData();
}

void JSONParser::clearData()
{
    p_data = "{ ";
}

void JSONParser::addVariable(const QString name, int value)
{
    p_data.append("\"");
    p_data.append(name);
    p_data.append("\":");
    p_data.append(QString::number(value));
    p_data.append(",");
}

void JSONParser::setData(QString &value)
{
    if(value != p_data)
    {
        p_data = value;
        emit dataChanged();
    }
}

QString JSONParser::data() {
    QString result = p_data.remove(p_data.length() - 1, 1);
    result.append(" }");

    return result;
}
