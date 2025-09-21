FROM alpine:3.18 AS gomplate-downloader
# Install gomplate
ARG GOMPLATE_VERSION=v4.1.0
RUN apk add --no-cache curl ca-certificates && \
    curl -sSL "https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-amd64" \
    -o /usr/local/bin/gomplate && \
    chmod +x /usr/local/bin/gomplate

FROM alpine:3.18
ENV ARGOCD_EXEC_TIMEOUT=90s

# Install runtime dependencies
RUN apk add --no-cache \
    bash \
    ca-certificates \
    git \
    openssh-client \
    curl \
    jq \
    yq

# Copy gomplate binary
COPY --from=gomplate-downloader /usr/local/bin/gomplate /usr/local/bin/gomplate

# Copy CMP configuration and entrypoint
COPY cmp.yaml /home/argocd/cmp-server/config/plugin.yaml
COPY entrypoint.sh /entrypoint.sh

# Create argocd user and set permissions
RUN adduser -H -D -s /bin/bash -G nobody -u 999 argocd && \
    chmod +x /entrypoint.sh && \
    chmod +x /usr/local/bin/gomplate

USER argocd:nobody
WORKDIR /home/argocd

ENTRYPOINT ["/entrypoint.sh"]
