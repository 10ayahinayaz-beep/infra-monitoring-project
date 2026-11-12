#!/usr/bin/env bash
IPS=(192.168.1.10 192.168.1.11 192.168.1.25 10.0.0.5 10.0.0.7 172.16.0.3 172.16.0.8 8.8.4.4)
METHODS=(GET GET GET POST PUT DELETE)
PATHS=(/api/users /api/login /api/orders /api/products /api/health /api/admin)
CODES=(200 200 200 200 201 204 301 400 401 403 404 500 502 503)

: > "access.log"  

for ((i = 0; i < 300; i++)); do
    idx=$(( (RANDOM % ${#IPS[@]}) * (RANDOM % ${#IPS[@]}) / ${#IPS[@]} ))
    ip=${IPS[$idx]}
    method=${METHODS[RANDOM % ${#METHODS[@]}]}
    path=${PATHS[RANDOM % ${#PATHS[@]}]}
    code=${CODES[RANDOM % ${#CODES[@]}]}

    printf '%s - - [01/Jan/2026:%02d:%02d:%02d] "%s %s HTTP/1.1" %s\n' \
        "$ip" $((i / 3600)) $((i % 3600 / 60)) $((i % 60)) \
        "$method" "$path" "$code" >> "$access.log"
done

IP_REGEX='^([0-9]{1,3}\.){3}[0-9]{1,3}'

total=$(grep -cE "$IP_REGEX" "access.log")
echo "Общее количество запросов: $total"
echo

echo "Топ 3 адреса по числу запросов:"
grep -oE "$IP_REGEX" "$access.log" \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -n 3 \
    | awk '{ printf "  %-15s %s запросов\n", $2, $1 }'
echo

c4xx=$(awk '$NF ~ /^4[0-9][0-9]$/' "$access.log" | wc -l)
c5xx=$(awk '$NF ~ /^5[0-9][0-9]$/' "$access.log" | wc -l)
echo "Запросов с кодами 4xx: $c4xx"
echo "Запросов с кодами 5xx: $c5xx"
