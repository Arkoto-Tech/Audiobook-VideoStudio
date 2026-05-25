# Audiobook VideoStudio — Production Docker Image

FROM python:3.11-slim-bookworm

LABEL org.opencontainers.image.title="Audiobook VideoStudio"
LABEL org.opencontainers.image.description="Audiobook + subtitle + MP4 generation studio"
LABEL org.opencontainers.image.source="https://github.com/Arkoto-Tech/Audiobook-VideoStudio"

# Environment
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    STREAMLIT_SERVER_HEADLESS=true \
    STREAMLIT_BROWSER_GATHER_USAGE_STATS=false \
    STREAMLIT_SERVER_MAX_UPLOAD_SIZE=500 \
    AUDIOBOOK_STUDIO_DATA=/data

# System packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    fontconfig \
    fonts-dejavu-core \
    fonts-liberation \
    wget \
    curl \
    ca-certificates \
    git \
    build-essential \
    libsndfile1 \
    && fc-cache -f \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# App directory
WORKDIR /app

# Copy ENTIRE repository
COPY . /app

# Upgrade pip
RUN pip install --upgrade pip setuptools wheel

# Install requirements if they exist
RUN if [ -f requirements.txt ]; then \
        pip install -r requirements.txt; \
    elif [ -f app/requirements.txt ]; then \
        pip install -r app/requirements.txt; \
    else \
        echo "No requirements.txt found!"; \
    fi

# Create persistent folders
RUN mkdir -p \
    /input \
    /output \
    /data \
    /app/models \
    /app/temp \
    /app/logs \
    && chmod -R 777 /input /output /data /app/models /app/temp /app/logs

# Expose Streamlit port
EXPOSE 8501

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
CMD wget -qO- http://127.0.0.1:8501/_stcore/health >/dev/null 2>&1 || exit 1

# Auto-detect app entrypoint
CMD if [ -f app.py ]; then \
        streamlit run app.py --server.address=0.0.0.0 --server.port=8501; \
    elif [ -f app/app.py ]; then \
        streamlit run app/app.py --server.address=0.0.0.0 --server.port=8501; \
    else \
        echo "ERROR: Could not find app.py" && exit 1; \
    fi
