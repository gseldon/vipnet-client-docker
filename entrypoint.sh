#!/usr/bin/env bash
set -Eeuo pipefail

log()  { echo -e "\e[93m$*\e[39m"; }
warn() { echo -e "\e[91m$*\e[39m" >&2; }

KEYFILE="/vipnet/key.dst"
KEYFILE_PASS="${KEYFILE_PASS:-}"
DEBUG_LEVEL="${DEBUG_LEVEL:-1}"
DNS_SERVER="${DNS_SERVER:-77.88.8.8}"

[ -f "$KEYFILE" ]       || { warn "Файл ключей $KEYFILE не найден"; exit 1; }
[ -n "$KEYFILE_PASS" ]  || { warn "KEYFILE_PASS не задан"; exit 1; }

# Экранируем спецсимволы sed в значении замены
dns_escaped=$(printf '%s' "$DNS_SERVER" | sed -e 's/[\/&|]/\\&/g')
sed -i -e "s/^;config_dir=/config_dir=\/vipnet/" \
       -e "s|^trusted=.*|trusted=${dns_escaped}|" /etc/vipnet.conf

log "Удаляем старый файл ключей"
yes | vipnetclient deletekeys || true

log "Подключаем файл ключей"
vipnetclient installkeys "$KEYFILE" --psw "$KEYFILE_PASS"
vipnetclient info

log "Проверка подключения"
vipnetclient debug --ping || warn "Проверка подключения (--ping) завершилась с ошибкой"

log "Включаем лог"
vipnetclient debug --loglevel "$DEBUG_LEVEL"

# Корректное завершение по SIGTERM/SIGINT (docker stop)
tail_pid=""
shutdown() {
    log "Останавливаем контейнер"
    [ -n "$tail_pid" ] && kill "$tail_pid" 2>/dev/null || true
    exit 0
}
trap shutdown TERM INT

mkdir -p /vipnet/var/log
# -F: переживает отсутствие/ротацию файлов; --pid не нужен, tail в фоне + wait
tail -n 0 -F /vipnet/var/log/*.log 2>/dev/null &
tail_pid=$!
while kill -0 "$tail_pid" 2>/dev/null; do
    wait "$tail_pid" || true
done
