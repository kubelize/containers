FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y wget curl nano iputils-ping

RUN wget -O /usr/local/bin/gotty https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz && \
    tar -C /usr/local/bin -xzf /usr/local/bin/gotty && \
    chmod +x /usr/local/bin/gotty

RUN useradd -m web-rcon

COPY rcon /usr/local/bin/rcon
COPY rcon.yaml /home/web-rcon/rcon.yaml

USER web-rcon
WORKDIR /home/web-rcon

ENTRYPOINT gotty -w -p 8080 /bin/bash