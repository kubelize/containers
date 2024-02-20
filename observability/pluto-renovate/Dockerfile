FROM alpine:20231219

RUN apk add --update-cache wget curl gettext \  
  && rm -rf /var/cache/apk/*

# Install Spruce
RUN curl -s -L -o /usr/local/bin/spruce https://github.com/geofffranks/spruce/releases/download/v1.31.0/spruce-linux-amd64 \
    && chmod +x /usr/local/bin/spruce 

# Install Pluto
RUN wget https://github.com/FairwindsOps/pluto/releases/download/v5.10.7/pluto_5.10.7_linux_amd64.tar.gz -O - | tar -xz \
    && chmod +x ./pluto \
    && mv ./pluto /usr/local/bin/  

# Install Helm
RUN curl -s https://get.helm.sh/helm-v3.10.0-linux-amd64.tar.gz | tar zx && mv linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm
