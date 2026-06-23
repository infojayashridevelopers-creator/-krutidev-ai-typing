# ── Stage 1: Build Go backend ─────────────────────────────────────────────────
FROM golang:1.21-alpine AS go-builder

WORKDIR /app
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY backend/ .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o krutidev .

# ── Stage 2: Runtime (Python + Whisper + FFmpeg) ──────────────────────────────
FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir openai-whisper

WORKDIR /app

COPY --from=go-builder /app/krutidev ./krutidev

# Pre-built Flutter web SPA (run: flutter build web --release inside frontend/)
COPY frontend/build/web ./frontend/build/web

RUN mkdir -p uploads documents

EXPOSE 8080

ENV PORT=8080
ENV GIN_MODE=release
ENV WHISPER_PATH=whisper
ENV FFMPEG_PATH=ffmpeg
# Use "tiny" on Render free tier (512 MB RAM). Switch to "base" or "small" on paid plans.
ENV WHISPER_MODEL=tiny

CMD ["./krutidev"]
