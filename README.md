# Audiobook Studio — Docker

Run the full application in Docker. The image includes Python, FFmpeg, fonts, and all dependencies. No local Python install required.

## Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/macOS) or Docker Engine + Compose (Linux)
- Internet access (Edge TTS uses Microsoft’s cloud API)

## Quick start

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USER/audiobook-studio.git
cd audiobook-studio

# 2. Start the app
cd docker
docker compose up --build
```

Open **http://localhost:8501** in your browser.

First build takes a few minutes. Later starts are much faster.

## Stop

```bash
cd docker
docker compose down
```

## Project layout

```
audiobook-studio/
├── app/                 # Application source (Streamlit UI + core)
├── docker/              # Docker deployment (this folder)
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── input/           # Optional: drop source books here
│   └── output/          # Optional: export destination
└── README.md
```

The Docker image is built from `app/`; you do not copy files into the image manually.

## Volumes

| Mount | Purpose |
|-------|---------|
| `docker/input` | Optional folder for source books on the host |
| `docker/output` | Optional folder for exported files on the host |
| `audiobook-studio-data` | Named volume — saved settings and custom fonts |

User settings are stored in the named volume at `/data` inside the container (`AUDIOBOOK_STUDIO_DATA`).

## Custom port

```bash
cp .env.example .env
# Edit HOST_PORT=8502
docker compose up --build
```

Then open `http://localhost:8502`.

## GPU encoding (optional, Linux)

Hardware encoding needs an NVIDIA GPU and [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) on the host.

```bash
cd docker
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up --build
```

Enable **Use GPU acceleration** in the app sidebar. CPU encoding works everywhere and is the default fallback.

## Publishing to GitHub

1. Push the whole repository (both `app/` and `docker/`).
2. Tell users to run the commands in **Quick start** above.
3. Replace `YOUR_USER/audiobook-studio` in clone URLs with your repo path.

No secrets or API keys are required for Edge TTS.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Port already in use | Set `HOST_PORT` in `.env` or stop the other service on 8501 |
| Build fails on `apt-get` | Retry `docker compose build --no-cache` |
| MP4 export fails | Confirm FFmpeg in container: `docker exec audiobook-studio ffmpeg -version` |
| No subtitles | Rebuild after pull — requires `edge-tts` 7+ (included in image) |
| Blank page after start | Wait for healthcheck (~45s), then refresh |

## Verify the container

```bash
docker compose ps
docker compose logs -f
docker exec audiobook-studio ffmpeg -version
```

## Run in background

```bash
docker compose up -d --build
```
