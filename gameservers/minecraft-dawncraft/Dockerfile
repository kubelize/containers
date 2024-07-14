FROM debian:bookworm-20240110
ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y && \
    apt install --no-install-recommends --no-install-suggests -y \
    wget \
    nano \
    curl \ 
    openjdk-17-jdk && \
    adduser --disabled-password --gecos "" mc && \
    su mc -c "mkdir /home/mc/data" && \
    apt remove -y wget && \
    apt autoremove -y

WORKDIR /home/mc/data/dawncraft
USER mc

ENTRYPOINT  /home/mc/data/dawncraft/start.sh