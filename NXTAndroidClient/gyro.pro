TEMPLATE = app

QT += qml quick widgets sensors websockets

SOURCES += main.cpp \
    components/parser/jsonmodel.cpp \
    components/controls/sliderwidget.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

OTHER_FILES += \
    android/AndroidManifest.xml

HEADERS += \
    components/parser/jsonmodel.h \
    components/controls/sliderwidget.h
