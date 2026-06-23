# ── Stage 1: Build Go backend ─────────────────────────────────────────────────
FROM golang:1.21-alpine AS go-builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
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

RUN mkdir -p uploads documents

EXPOSE 8080

ENV PORT=8080
ENV GIN_MODE=release
ENV WHISPER_PATH=whisper
ENV FFMPEG_PATH=ffmpeg
ENV WHISPER_MODEL=tiny

CMD ["./krutidev"]
