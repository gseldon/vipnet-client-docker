## ViPNet Client 4 
_(докер клиент на базе Ubuntu)_

### Подготовка к сборке образа.

Скачать дистрибутив с сайта [infotecs.ru](https://infotecs.ru/downloads/all/vipnet-client-4u.html) для версии Linux x64 и положить его в папку app

Подготовить файл 

Подготовить файл переменных ```.env```

```sh
KEYFILE_PASS=""
WEB_HEALTHCHECK=""
DNS_SERVER=""
INSTALL_DEB_PACKAGE="" # если нужна сборка
```

### Docker Build

```sh
docker build \
-t gseldon/vipnet:test \
--build-arg INSTALL_DEB_PACKAGE=vipnetclient_gost_ru_amd64_4.12.0-8655.deb \
--no-cache .
```

### Docker-compose ```docker-compose.yml```

```docker
version: '3.8'

services:
    vpn:
        image: gseldon/vipnetclient:latest
        container_name: vipnet
        cap_add:
            - net_admin
        env_file:
            - ./.env
        tmpfs:
            - /run
            - /tmp
        restart: unless-stopped
        privileged: true
        security_opt:
            - label:disable
        stdin_open: true
        tty: true
        volumes:
            - /dev/net:/dev/net:z
            - ./app/key.dst:/vipnet/key.dst
    service:
        image: ubuntu
        depends_on: 
        vpn:
            condition: service_healthy
        network_mode: "service:vpn"
        restart: unless-stopped
```


[Main Project](https://github.com/gseldon/vipnet-client)