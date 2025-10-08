#!/bin/bash

LOG_FILE="/var/log/monitoring.log"
URL="https://test.com/monitoring/test/api"
PROCESS_NAME="test"
API_KEY=$(cat /etc/monitoring/api.key)  # Храним ключ в отдельном файле
CA_CERT="/etc/ssl/certs/ca-bundle.crt"

check_process() {
    local pid=$(pgrep -f "$PROCESS_NAME")
    if [ -z "$pid" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Процесс $PROCESS_NAME не запущен" >> "$LOG_FILE"
        return 1
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Процесс $PROCESS_NAME запущен (PID: $pid)" >> "$LOG_FILE"
        return 0
    fi
}

send_data() {
    response=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: Bearer $API_KEY" \
        --cacert "$CA_CERT" \
        "$URL")
    
    if [ "$response" -eq 200 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Успешная отправка данных" >> "$LOG_FILE"
        return 0
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Ошибка отправки данных (код: $response)" >> "$LOG_FILE"
        return 1
    fi
}

main() {
    last_pid=""
    while true; do
        if check_process; then
            current_pid=$(pgrep -f "$PROCESS_NAME")
            if [ "$current_pid" != "$last_pid" ]; then
                echo "$(date '+%Y-%m-%d %H:%M:%S') - Перезапуск процесса" >> "$LOG_FILE"
                last_pid="$current_pid"
            fi
            send_data
        fi
        sleep 60
    done
}

main
