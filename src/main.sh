#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Необходимо запускать скрипт с правами суперпользователя!"
  exit 1
fi

if [[ ! -f ./monitor_test.sh ]]; then
  echo "Ошибка: файл monitor_test.sh не найден!"
  exit 1
fi

if [[ ! -f ./monitor_test.service ]]; then
  echo "Ошибка: файл monitor_test.service не найден!"
  exit 1
fi

echo "Создаем необходимые директории..."
mkdir -p /usr/local/bin
mkdir -p /etc/systemd/system

echo "Копируем скрипт мониторинга..."
cp ./monitor_test.sh /usr/local/bin/monitor_test.sh

echo "Настраиваем права доступа..."
chmod +x /usr/local/bin/monitor_test.sh

echo "Копируем unit-файл сервиса..."
cp ./monitor_test.service /etc/systemd/system/monitor_test.service

echo "Обновляем systemd и запускаем сервис..."
systemctl daemon-reload
systemctl start monitor_test
systemctl enable monitor_test

echo "Проверка статуса сервиса:"
systemctl status monitor_test

echo "Установка завершена!"
