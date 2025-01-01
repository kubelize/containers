FROM debian:bookworm-20240110
ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y && \
    apt install --no-install-recommends --no-install-suggests -y \
    ca-certificates \
    zip unzip \
    curl \
    nano \
    locales && \
    adduser --disabled-password --gecos "" terra && \
    su terra -c 'cd && \
        mkdir -p /home/terra/.local/share/Terraria/Worlds/ && \
        cd /home/terra && \
        curl -o terraria-server-1449.zip "https://terraria.org/api/download/pc-dedicated-server/terraria-server-1449.zip" && \
        unzip terraria-server-1449.zip && \
        rm terraria-server-1449.zip' && \
    apt remove --purge -y curl && \
    apt autoremove -y && \
    cd /home/terra/1449/Linux && \
    chmod +x TerrariaServer.bin.x86_64

WORKDIR /home/terra/1449/Linux
USER terra

ENTRYPOINT  ./TerrariaServer.bin.x86_64 -config /home/terra/.local/share/Terraria/ServerConfig.txt