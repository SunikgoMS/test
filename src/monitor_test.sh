#!/bin/bash

# Настройки
LOG_FILE="/var/log/monitoring.log"
URL="https://test.com/monitoring/test/api"
PROCESS_NAME="test"

# Функция проверки процесса
check_process() {
    local pid=$(pgrep -f "$PROCESS_NAME")
    if [[ -z "$pid" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Процесс $PROCESS_NAME не запущен" >> "$LOG_FILE"
        return 1
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Процесс $PROCESS_NAME запущен (PID: $pid)" >> "$LOG_FILE"
        return 0
    fi
}

# Функция отправки данных
send_data() {
    curl -s -o /dev/null -w "%{http_code}" "$URL" | grep -q "200"
    if [[ $? -eq 0 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Успешная отправка данных на сервер мониторинга" >> "$LOG_FILE"
        return 0
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Ошибка отправки данных на сервер мониторинга" >> "$LOG_FILE"
        return 1
    fi
}

# Основная логика
last_pid=""
while true; do
    if check_process; then
        current_pid=$(pgrep -f "$PROCESS_NAME")
        if [[ "$current_pid" != "$last_pid" ]]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Обнаружен перезапуск процесса $PROCESS_NAME" >> "$LOG_FILE"
            last_pid="$current_pid"
        fi
        send_data
    fi
    sleep 60
done
