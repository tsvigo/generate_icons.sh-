#!/bin/bash

MAIN_DIR="/home/viktor/my_projects_qt_2/icon_konsole/"

# Указываем путь к исходному изображению
ICON_SRC="/mnt/usb-TOSHIBA_External_USB_3.0_20170624011116F-0:0-part1/images/2024-08-20_16-42-00_9646.png"

# Указываем путь к каталогу иконок в проекте
ICON_DIR=$MAIN_DIR"icons/"

# Указываем путь к .qrc файлу
QRC_FILE=$MAIN_DIR"resources.qrc"

# путь к .pro файлу
PRO_FILE=$MAIN_DIR"icon_konsole.pro"

# Указываем путь к .pro файлу проекта
#PRO_FILE="project.pro"

ICON_64="QGuiApplication::setWindowIcon(QIcon(\"$MAIN_DIR""icons/icon_64x64.png\"));"

MAIN_CPP=$MAIN_DIR"main.cpp"

# Размеры иконок
SIZES=(16 32 48 64 128 256)

# Проверка наличия исходного изображения
if [ ! -f "$ICON_SRC" ]; then
    echo "Исходное изображение $ICON_SRC не найдено!"
    exit 1
fi

# Создание каталога для иконок, если он не существует
mkdir -p "$ICON_DIR"

# Создание иконок разных размеров
for SIZE in "${SIZES[@]}"; do
    convert "$ICON_SRC" -resize "${SIZE}x${SIZE}" "$ICON_DIR/icon_${SIZE}x${SIZE}.png"
done

# Генерация .qrc файла
echo "<RCC>" > "$QRC_FILE"
echo "    <qresource prefix=\"/icons\">" >> "$QRC_FILE"
for SIZE in "${SIZES[@]}"; do
    echo "        <file>icons/icon_${SIZE}x${SIZE}.png</file>" >> "$QRC_FILE"
done
echo "    </qresource>" >> "$QRC_FILE"
echo "</RCC>" >> "$QRC_FILE"

# Добавление строки в конец .pro файла, если её там нет
if ! grep -q "RESOURCES += $QRC_FILE" "$PRO_FILE"; then
    echo "RESOURCES += $QRC_FILE" >> "$PRO_FILE"
    echo "Строка 'RESOURCES += $QRC_FILE' добавлена в $PRO_FILE"
else
    echo "Строка 'RESOURCES += $QRC_FILE' уже существует в $PRO_FILE"
fi

# Добавление значения переменной ICON_64 после строки QApplication a(argc, argv);
if grep -q "QApplication a(argc, argv);" "$MAIN_CPP"; then
    sed -i "/QApplication a(argc, argv);/a $ICON_64" "$MAIN_CPP"
    echo "Строка '$ICON_64' добавлена после 'QApplication a(argc, argv);' в $MAIN_CPP"
else
    echo "Строка 'QApplication a(argc, argv);' не найдена в $MAIN_CPP"
fi

# Добавление значения переменной ICON_64 после строки QApplication a(argc, argv);
if grep -q "QCoreApplication a(argc, argv);" "$MAIN_CPP"; then
    sed -i "/QCoreApplication a(argc, argv);/a $ICON_64" "$MAIN_CPP"
    echo "Строка '$ICON_64' добавлена после 'QCoreApplication a(argc, argv);' в $MAIN_CPP"
else
    echo "Строка 'QCoreApplication a(argc, argv);' не найдена в $MAIN_CPP"
fi

# Сообщение об успешном завершении
echo "Иконки созданы и .qrc файл обновлен успешно!"
