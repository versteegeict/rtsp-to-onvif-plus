# rtsp-to-onvif+ — multi-arch; upstream inside; Node 22 LTS; Debian bookworm-slim
# Requires internet during build to git clone upstream and run npm ci

FROM --platform=$BUILDPLATFORM debian:bookworm-slim AS base
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates curl git nodejs npm tini dumb-init iproute2 iputils-ping \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1) Clone upstream (release branch)
RUN git clone --depth 1 -b release https://github.com/p10tyr/rtsp-to-onvif /app/upstream

# 2) Install upstream deps
WORKDIR /app/upstream
RUN npm ci --omit=dev

# 3) Copy our manager + GUI
WORKDIR /app
COPY manager ./manager

# 4) Install manager deps
WORKDIR /app/manager
RUN npm ci --omit=dev

# Final image
FROM debian:bookworm-slim
ENV NODE_ENV=production \
    PORT=8090 \
    GUI_HOST=0.0.0.0 \
    ONVIF_CONFIG=/onvif.yaml \
    UPSTREAM_DIR=/app/upstream \
    AUTOPORT_BASE_SERVER=8081 \
    AUTOPORT_BASE_RTSP=8554 \
    AUTOPORT_BASE_SNAPSHOT=8080

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates tini dumb-init iproute2 iputils-ping \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=base /app/upstream /app/upstream
COPY --from=base /app/manager /app/manager
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

EXPOSE 8090 8081 8080 8554
HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD curl -fsSL http://127.0.0.1:${PORT}/api/health || exit 1

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/local/bin/docker-entrypoint.sh"]