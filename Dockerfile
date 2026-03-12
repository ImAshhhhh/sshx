# Build stage: download sshx-server binary
FROM debian:bookworm-slim AS downloader

ARG SSHX_VERSION=v0.3.4
ARG TARGETARCH

RUN apt-get update && apt-get install -y curl ca-certificates && rm -rf /var/lib/apt/lists/*

RUN ARCH_MAP="amd64=x86_64 arm64=aarch64" && \
    ARCH=$(echo "$ARCH_MAP" | tr ' ' '\n' | grep "^${TARGETARCH}=" | cut -d= -f2) && \
    curl -fsSL "https://github.com/ekzhang/sshx/releases/download/${SSHX_VERSION}/sshx-server-${ARCH}-unknown-linux-musl.tar.gz" -o sshx-server.tar.gz && \
    tar -xzf sshx-server.tar.gz && \
    chmod +x sshx-server

# Runtime stage
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m -u 1000 sshx

COPY --from=downloader /sshx-server /usr/local/bin/sshx-server

USER sshx
WORKDIR /home/sshx

EXPOSE 8080

ENV SSHX_PORT=8080
ENV SSHX_HOST=0.0.0.0

CMD ["sh", "-c", "exec sshx-server --host ${SSHX_HOST} --port ${SSHX_PORT}"]
