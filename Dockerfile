# ============================================================
# rtsp-to-onvif+ — multi-arch; upstream inside; Node 22 LTS
# ============================================================

FROM node:22-bookworm-slim AS base
ENV DEBIAN_FRONTEND=noninteractive

# tools voor build
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates curl git \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1) Clone upstream (release branch)
RUN git clone --depth 1 -b release https://github.com/p10tyr/rtsp-to-onvif /app/upstream

# 2) Install upstream deps
WORKDIR /app/upstream
RUN npm ci --omit=dev || npm install --omit=dev

# 3) Copy our manager + GUI
WORKDIR /app
COPY manager ./manager

# 4) Install manager deps
WORKDIR /app/manager
RUN [ -f package-lock.json ] && npm ci --omit=dev || npm install --omit=dev

# ============================================================
# Final runtime image
# ============================================================

FROM node:22-bookworm-slim
ENV NODE_ENV=production \
    PORT=8090 \
    GUI_HOST=0.0.0.0 \
    ONVIF_CONFIG=/onvif.yaml \
    UPSTREAM_DIR=/app/upstream \
    AUTOPORT_BASE_SERVER=8081 \
    AUTOPORT_BASE_RTSP=8554 \
    AUTOPORT_BASE_SNAPSHOT=8080

# runtime deps (Node, tini, curl voor healthcheck, iproute2/iputils voor MAC/IP tricks)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    tini dumb-init iproute2 iputils-ping curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=base /app/upstream /app/upstream
COPY --from=base /app/manager /app/manager
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# poorten
EXPOSE 8090 8081 8080 8554

# healthcheck
HEALTHCHECK --interval=30s --timeout=5s --retries=5 \
  CMD curl -fsSL http://127.0.0.1:${PORT}/api/health || exit 1

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/local/bin/docker-entrypoint.sh"]
