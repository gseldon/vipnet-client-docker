#!/usr/bin/env bash
# Пустой HEALTHCHECK_CMD = проверка отключена.
# При сбое останавливаем PID 1: контейнер завершается и перезапускается политикой restart.
[ -n "${HEALTHCHECK_CMD:-}" ] || exit 0
if bash -c "$HEALTHCHECK_CMD"; then
    exit 0
fi
kill -TERM 1
exit 1
