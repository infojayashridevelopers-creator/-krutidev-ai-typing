package config

import (
	"os"
)

type Config struct {
	Port         string
	JWTSecret    string
	DBPath       string
	WhisperPath  string
	WhisperModel string
	FFmpegPath   string
	UploadDir    string
	DocumentsDir string
}

var App = &Config{
	Port:         getEnv("PORT", "8080"),
	JWTSecret:    getEnv("JWT_SECRET", "krutidev-secret-key-2024"),
	DBPath:       getEnv("DB_PATH", "./krutidev.db"),
	WhisperPath:  getEnv("WHISPER_PATH", "whisper"),
	WhisperModel: getEnv("WHISPER_MODEL", "small"),
	FFmpegPath:   getEnv("FFMPEG_PATH", "ffmpeg"),
	UploadDir:    getEnv("UPLOAD_DIR", "./uploads"),
	DocumentsDir: getEnv("DOCUMENTS_DIR", "./documents"),
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
