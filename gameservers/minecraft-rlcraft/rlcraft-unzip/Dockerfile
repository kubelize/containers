FROM debian:bookworm-20240110
ENV DEBIAN_FRONTEND noninteractive

COPY rlcraft_server.zip /tmp/

RUN apt update && apt upgrade -y && \
    apt install --no-install-recommends --no-install-suggests -y \
    unzip