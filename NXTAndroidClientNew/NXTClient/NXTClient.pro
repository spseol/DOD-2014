TEMPLATE = app

QT += qml quick widgets sensors websockets

SOURCES += main.cpp \
    components/parser/jsonparser.cpp \
    components/controls/sliderwidget.cpp \
    components/controls/gradientwidget.cpp \
    components/graphics/accelometerwidget.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

OTHER_FILES += \
    android/AndroidManifest.xml

HEADERS += \
    components/parser/jsonparser.h \
    components/controls/sliderwidget.h \
    components/controls/gradientwidget.h \
    components/graphics/accelometerwidget.h
