# Audiobook Studio — production image
# Build from repository root:
#   docker compose -f docker/docker-compose.yml build

FROM python:3.11-slim-bookworm

LABEL org.opencontainers.image.title="Audiobook Studio"
LABEL org.opencontainers.image.description="Ebook to audiobook with synced subtitles and MP4 export"
LABEL org.opencontainers.image.source="https://github.com/YOUR_USER/audiobook-studio"

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    STREAMLIT_SERVER_HEADLESS=true \
    STREAMLIT_BROWSER_GATHER_USAGE_STATS=false \
    STREAMLIT_SERVER_MAX_UPLOAD_SIZE=500 \
    AUDIOBOOK_STUDIO_DATA=/data

# FFmpeg (required for MP4), fonts for subtitle burn-in, healthcheck tool
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    fontconfig \
    fonts-dejavu-core \
    fonts-liberation \
    wget \
    ca-certificates \
    && fc-cache -f \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies first (better layer cache)
COPY app/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Application source
COPY app/app.py /app/app.py
COPY app/core/ /app/core/
COPY app/.streamlit/ /root/.streamlit/

# Persistent dirs (mounted as volumes in compose)
RUN mkdir -p /input /output /data \
    && chmod 777 /input /output /data

EXPOSE 8501

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8501/_stcore/health >/dev/null 2>&1 || exit 1

CMD ["streamlit", "run", "app.py", \
     "--server.address=0.0.0.0", \
     "--server.port=8501", \
     "--server.headless=true", \
     "--browser.gatherUsageStats=false"]
