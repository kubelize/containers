FROM debian:bookworm-20240110
ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y && \
    apt install --no-install-recommends --no-install-suggests -y \
    wget && \
    wget http://www.mirbsd.org/~tg/Debs/sources.txt/wtf-bookworm.sources && \
    mkdir -p /etc/apt/sources.list.d && \
    mv wtf-bookworm.sources /etc/apt/sources.list.d/ && \
    apt update && apt install -y \
    unzip \
    openjdk-8-jdk && \
    adduser --disabled-password --gecos "" mc && \
    su mc -c "cd && \
        mkdir /home/mc/data && \
        wget https://cloud.mckensy.xyz/s/66eaLksWEmEALir/download/rlcraft_server.zip && \
        unzip rlcraft_server.zip && \
        cd rlcraft_server && \
        bash -c 'echo eula=true > eula.txt'" && \
    apt remove -y wget unzip && \
    apt autoremove -y

WORKDIR /home/mc/rlcraft_server
USER mc

ENTRYPOINT /bin/bash