FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y wget curl nano iputils-ping

RUN wget -O /usr/local/bin/gotty https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz && \
    tar -C /usr/local/bin -xzf /usr/local/bin/gotty && \
    chmod +x /usr/local/bin/gotty

RUN useradd -m kubelize

COPY rcon /usr/local/bin/rcon
COPY .gotty.crt .gotty.key rcon.yaml .bashrc /home/kubelize/

RUN chown -R kubelize:kubelize /home/kubelize

RUN apt remove --purge -y wget && \
    apt autoremove -y

RUN setcap 'cap_net_bind_service=+ep' /usr/local/bin/gotty

USER kubelize
WORKDIR /home/kubelize

ENTRYPOINT gotty -w -t -p 443 /bin/bash