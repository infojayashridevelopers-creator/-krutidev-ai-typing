package handlers

import (
	"net/http"
	"path/filepath"
	"time"

	"krutidev-ai-typing/config"
	"krutidev-ai-typing/db"
	"krutidev-ai-typing/models"
	"krutidev-ai-typing/services/stt"
	"krutidev-ai-typing/services/unicode"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// UploadAudio saves uploaded audio file and returns its server path
func UploadAudio(c *gin.Context) {
	file, err := c.FormFile("audio")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "audio file required"})
		return
	}

	ext := filepath.Ext(file.Filename)
	if ext == "" {
		ext = ".wav"
	}

	filename := uuid.New().String() + ext
	savePath := filepath.Join(config.App.UploadDir, filename)

	if err := c.SaveUploadedFile(file, savePath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "could not save file"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"file_path": savePath,
		"file_name": filename,
	})
}

// SpeechToText transcribes audio to Devanagari Unicode text.
// Accepts language: "hi" (Hindi, default) or "mr" (Marathi).
func SpeechToText(c *gin.Context) {
	var req struct {
		FilePath string `json:"file_path" binding:"required"`
		Language string `json:"language"` // "hi" or "mr"
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if req.Language == "" {
		req.Language = "hi"
	}

	userID := c.GetUint("user_id")

	result, err := stt.Transcribe(req.FilePath, req.Language)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	db.DB.Create(&models.Log{
		UserID:    userID,
		Action:    "speech_to_text:" + req.Language,
		Timestamp: time.Now(),
	})

	c.JSON(http.StatusOK, gin.H{
		"unicode_text": result.Text,
		"language":     result.Language,
	})
}

// ConvertToKrutiDev converts Unicode Devanagari text (Hindi or Marathi) to Kruti Dev encoding
func ConvertToKrutiDev(c *gin.Context) {
	var req struct {
		Text     string `json:"text" binding:"required"`
		Language string `json:"language"` // "hi" or "mr" — both use same Devanagari→Kruti mapping
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	krutiText := unicode.ConvertUnicodeToKruti(req.Text)
	lang := req.Language
	if lang == "" {
		lang = unicode.DetectLanguage(req.Text)
	}

	c.JSON(http.StatusOK, gin.H{
		"unicode_text": req.Text,
		"kruti_text":   krutiText,
		"language":     lang,
	})
}

// GetSupportedLanguages returns the list of supported STT languages
func GetSupportedLanguages(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"languages": []map[string]string{
			{"code": "hi", "name": "Hindi", "native": "हिंदी"},
			{"code": "mr", "name": "Marathi", "native": "मराठी"},
		},
	})
}
