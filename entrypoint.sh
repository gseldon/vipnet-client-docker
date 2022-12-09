#!/usr/bin/bash
set -e
set -o errexit
set -o pipefail
set -o nounset

KEYFILE_PASS="${KEYFILE_PASS}"
DEBUG_LEVEL="${DEBUG_LEVEL}"
DNS_SERVER="${DNS_SERVER}"
sed -i "s/;config_dir=/config_dir=\/vipnet/" /etc/vipnet.conf
sed -i "s/trusted=.*/trusted=${DNS_SERVER}/" /etc/vipnet.conf
echo -e "\e[93mУдаляем файл ключей\e[39m"
yes | vipnetclient deletekeys || \
echo -e "\e[93mПодключаем файл ключей\e[39m" && \
vipnetclient installkeys /vipnet/key.dst --psw $KEYFILE_PASS
vipnetclient info
echo -e "\e[93mПроверка подключения\e[39m"
vipnetclient debug --ping
echo -e "\e[93mВключаем лог\e[39m"
vipnetclient debug --loglevel $DEBUG_LEVEL
tail -f /vipnet/var/log/*.log
exec "$@"