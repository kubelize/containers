FROM debian:bookworm-20240110
ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y && \
    apt install --no-install-recommends --no-install-suggests -y \
    ca-certificates \
    lib32gcc-s1 \
    curl \
    wine xvfb \
    xauth \
    nano \
    locales && \
    adduser --disabled-password --gecos "" steam && \
    su steam -c 'cd && \
        mkdir -p /home/steam/steamcmd && \
        cd /home/steam/steamcmd && \
        curl -o steamcmd_linux.tar.gz "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" && \
        tar zxf steamcmd_linux.tar.gz && \
        rm steamcmd_linux.tar.gz' && \
    apt remove --purge -y curl && \
    apt autoremove -y && \
    cd /home/steam/steamcmd 

WORKDIR /home/steam/steamcmd
USER steam

ENTRYPOINT  /home/steam/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir /home/steam/ce-server/ +login anonymous +app_update 443030 +quit && \
            /home/steam/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous +workshop_download_item 440900 3359158426 1113901982 +quit && \
            export WINEARCH=win64 && \
            export WINEPREFIX=/home/steam/.wine64 && \
            xvfb-run --auto-servernum wine /home/steam/ce-server/ConanSandboxServer.exe -log