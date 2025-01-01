    FROM debian:bookworm-20240110
    ENV DEBIAN_FRONTEND noninteractive

    RUN apt update && apt upgrade -y && \
        apt install --no-install-recommends --no-install-suggests -y \
        ca-certificates \
        lib32gcc-s1 \
        curl \
        nano \
        locales && \
        adduser --disabled-password --gecos "" steam && \
        su steam -c 'cd && \
            mkdir -p /home/steam/steamcmd /home/steam/sdtd && \
            cd /home/steam/steamcmd && \
            curl -o steamcmd_linux.tar.gz "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" && \
            tar zxf steamcmd_linux.tar.gz && \
            rm steamcmd_linux.tar.gz' && \
        apt remove --purge -y curl && \
        apt autoremove -y && \
        cd /home/steam/steamcmd 

    WORKDIR /home/steam/steamcmd
    USER steam

    ENTRYPOINT  /home/steam/steamcmd/steamcmd.sh +force_install_dir /home/steam/sdtd/ +login anonymous +app_update 294420 +quit && \
                /home/steam/sdtd/startserver.sh -configfile=serverconfig.xml