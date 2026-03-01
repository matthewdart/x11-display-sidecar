FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    SCREEN_WIDTH=1280 \
    SCREEN_HEIGHT=720 \
    SCREEN_DEPTH=24 \
    VNC_PORT=5900 \
    NOVNC_PORT=6080

RUN apt-get update && apt-get install -y --no-install-recommends \
        xvfb \
        x11vnc \
        novnc \
        websockify \
        metacity \
        supervisor \
        x11-utils \
    && rm -rf /var/lib/apt/lists/*

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY wait-for-display.sh /usr/local/bin/wait-for-display.sh
RUN chmod +x /usr/local/bin/wait-for-display.sh

VOLUME /tmp/.X11-unix

EXPOSE 6080 5900

HEALTHCHECK --interval=5s --timeout=3s --start-period=15s --retries=5 \
    CMD xdpyinfo -display :99 >/dev/null 2>&1 || exit 1

ENTRYPOINT ["supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
