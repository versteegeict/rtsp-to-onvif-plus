# rtsp-to-onvif+

Een drop-in uitbreiding op [`p10tyr/rtsp-to-onvif`](https://github.com/p10tyr/rtsp-to-onvif) met een **web‑GUI** en **multi‑camera** beheer in één container.

## Features
- Web-GUI om camera’s toe te voegen/bewerken/verwijderen
- Meerdere virtuele ONVIF-devices vanuit één container
- Hot-reload: upstream herstart automatisch na config-wijziging
- Compatibel met Synology/Unraid (Docker), host-network + `NET_ADMIN`
- Zelfde YAML‑schema als upstream (`onvif:`)

## Snel starten
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t jouwrepo/rtsp-to-onvif-plus:latest .
docker compose up -d
```
Open daarna `http://<NAS-IP>:8090` en voeg camera’s toe in de GUI.

## Configuratie
De GUI schrijft naar `/onvif.yaml`.

## Licentie
MIT