FROM debian:bookworm-20240110
ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y && \
    apt install --no-install-recommends --no-install-suggests -y \
    wget && \
    wget http://www.mirbsd.org/~tg/Debs/sources.txt/wtf-bookworm.sources && \
    mkdir -p /etc/apt/sources.list.d && \
    mv wtf-bookworm.sources /etc/apt/sources.list.d/ && \
    apt update && apt install -y \
    nano \
    openjdk-8-jdk && \
    adduser --disabled-password --gecos "" mc && \
    su mc -c "mkdir /home/mc/data" && \
    apt remove -y wget && \
    apt autoremove -y

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /home/mc/data/rlcraft_server
USER mc

ENTRYPOINT  /usr/local/bin/entrypoint.sh