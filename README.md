# x11-display-sidecar

Minimal Docker sidecar providing an X11 virtual display observable via a browser-based noVNC interface. Designed to be attached to any GUI container (e.g. Eclipse/SWT apps) via a shared named Docker volume, with zero changes to the application image.

## Quick start

```bash
docker compose up
```

Open `http://localhost:6080` in a browser to see the noVNC desktop.

## How it works

The sidecar runs four processes via supervisord:

| Process | Purpose |
|---|---|
| **Xvfb** | Virtual framebuffer (X11 display `:99`) |
| **metacity** | GTK-native window manager (recommended for Eclipse SWT) |
| **x11vnc** | VNC server exposing the display |
| **websockify + noVNC** | Browser-accessible VNC client at port 6080 |

The X11 socket is shared via a named Docker volume at `/tmp/.X11-unix`. Any container mounting the same volume and setting `DISPLAY=:99` will render into this display.

## Use as a sidecar

In your application's `docker-compose.yml`:

```yaml
services:
  your-app:
    image: your-gui-app:latest
    environment:
      - DISPLAY=:99
    depends_on:
      x11-display:
        condition: service_healthy
    volumes:
      - x11-socket:/tmp/.X11-unix

  x11-display:
    image: ghcr.io/matthewdart/x11-display-sidecar:latest
    ports:
      - "6080:6080"
    volumes:
      - x11-socket:/tmp/.X11-unix

volumes:
  x11-socket:
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| `DISPLAY` | `:99` | X11 display number |
| `SCREEN_WIDTH` | `1280` | Virtual screen width |
| `SCREEN_HEIGHT` | `720` | Virtual screen height |
| `SCREEN_DEPTH` | `24` | Color depth |
| `VNC_PORT` | `5900` | Raw VNC port |
| `NOVNC_PORT` | `6080` | noVNC web port |

## Why metacity?

Eclipse/SWT workloads use GTK for rendering. The Eclipse CBI developer community recommends **metacity** as the window manager for SWT because it shares GTK's theming stack, reducing rendering surprises with SWT dialogs and decorations. This is a deliberate choice over fluxbox (common in browser automation images).

## Platform

Built for `linux/arm64`. Runs natively on Oracle Cloud ARM instances.
