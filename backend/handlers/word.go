package handlers

import (
	"fmt"
	"net/http"
	"path/filepath"
	"time"

	"krutidev-ai-typing/config"
	"krutidev-ai-typing/db"
	"krutidev-ai-typing/models"
	"krutidev-ai-typing/services/unicode"
	"krutidev-ai-typing/services/word"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// TypeInWord types Kruti Dev text in Microsoft Word
func TypeInWord(c *gin.Context) {
	var req struct {
		Text            string               `json:"text" binding:"required"`
		IsUnicode       bool                 `json:"is_unicode"`
		Settings        *models.WordSettings `json:"settings"`
		ApplyFormatting bool                 `json:"apply_formatting"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	krutiText := req.Text
	if req.IsUnicode {
		krutiText = unicode.ConvertUnicodeToKruti(req.Text)
	}

	if err := word.RunOnCOMThread(func() error {
		wordApp, err := word.Connect()
		if err != nil {
			return fmt.Errorf("cannot connect to Word: %w", err)
		}
		defer wordApp.Close()
		if req.Settings != nil && req.ApplyFormatting {
			if err := wordApp.ApplySettings(*req.Settings); err != nil {
				return fmt.Errorf("settings error: %w", err)
			}
		}
		return wordApp.TypeText(krutiText)
	}); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	userID := c.GetUint("user_id")
	db.DB.Create(&models.Log{UserID: userID, Action: "type_in_word", Timestamp: time.Now()})

	c.JSON(http.StatusOK, gin.H{"success": true, "kruti_text": krutiText})
}

// ApplyWordSettings applies formatting settings to Word
func ApplyWordSettings(c *gin.Context) {
	var settings models.WordSettings
	if err := c.ShouldBindJSON(&settings); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := word.RunOnCOMThread(func() error {
		wordApp, err := word.Connect()
		if err != nil {
			return fmt.Errorf("cannot connect to Word: %w", err)
		}
		defer wordApp.Close()
		return wordApp.ApplySettings(settings)
	}); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	userID := c.GetUint("user_id")
	db.DB.Where("user_id = ? AND key = ?", userID, "font_name").
		Assign(models.Setting{Value: settings.FontName}).
		FirstOrCreate(&models.Setting{UserID: userID, Key: "font_name"})

	c.JSON(http.StatusOK, gin.H{"success": true, "settings": settings})
}

// SaveDocument saves the current Word document
func SaveDocument(c *gin.Context) {
	var req struct {
		FileName string `json:"file_name"`
	}
	c.ShouldBindJSON(&req)
	if req.FileName == "" {
		req.FileName = "document_" + uuid.New().String()[:8]
	}
	savePath := filepath.Join(config.App.DocumentsDir, req.FileName+".docx")

	if err := word.RunOnCOMThread(func() error {
		wordApp, err := word.Connect()
		if err != nil {
			return fmt.Errorf("cannot connect to Word: %w", err)
		}
		defer wordApp.Close()
		return wordApp.SaveDocument(savePath)
	}); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	userID := c.GetUint("user_id")
	db.DB.Create(&models.Log{UserID: userID, Action: "save_document", Timestamp: time.Now()})
	c.JSON(http.StatusOK, gin.H{"success": true, "path": savePath})
}

// ExportPDF exports the current document as PDF
func ExportPDF(c *gin.Context) {
	var req struct {
		FileName string `json:"file_name"`
	}
	c.ShouldBindJSON(&req)
	if req.FileName == "" {
		req.FileName = "export_" + uuid.New().String()[:8]
	}
	pdfPath := filepath.Join(config.App.DocumentsDir, req.FileName+".pdf")

	if err := word.RunOnCOMThread(func() error {
		wordApp, err := word.Connect()
		if err != nil {
			return fmt.Errorf("cannot connect to Word: %w", err)
		}
		defer wordApp.Close()
		return wordApp.ExportPDF(pdfPath)
	}); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	userID := c.GetUint("user_id")
	db.DB.Create(&models.Log{UserID: userID, Action: "export_pdf", Timestamp: time.Now()})
	c.JSON(http.StatusOK, gin.H{"success": true, "path": pdfPath})
}

// NewWordDocument creates a new Word document
func NewWordDocument(c *gin.Context) {
	if err := word.RunOnCOMThread(func() error {
		wordApp, err := word.Connect()
		if err != nil {
			return fmt.Errorf("cannot connect to Word: %w", err)
		}
		defer wordApp.Close()
		if err := wordApp.NewDocument(); err != nil {
			return err
		}
		defaults := models.DefaultWordSettings()
		return wordApp.ApplySettings(defaults)
	}); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "new document created"})
}

// VoiceCommand processes a voice command and executes the action in Word
func VoiceCommand(c *gin.Context) {
	var req struct {
		Command string `json:"command" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	action := word.VoiceCommandToAction(req.Command)
	if action == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "unknown voice command"})
		return
	}

	if err := word.RunOnCOMThread(func() error {
		wordApp, err := word.Connect()
		if err != nil {
			return fmt.Errorf("cannot connect to Word: %w", err)
		}
		defer wordApp.Close()

		switch action {
		case "enter", "new_paragraph":
			return wordApp.TypeParagraph()
		case "bold_on":
			return wordApp.SetBold(true)
		case "bold_off":
			return wordApp.SetBold(false)
		case "italic_on":
			return wordApp.SetItalic(true)
		case "italic_off":
			return wordApp.SetItalic(false)
		case "underline_on":
			return wordApp.SetUnderline(true)
		case "underline_off":
			return wordApp.SetUnderline(false)
		case "space":
			return wordApp.TypeText(" ")
		case "full_stop":
			return wordApp.TypeText("।")
		case "comma":
			return wordApp.TypeText(",")
		case "save":
			name := "document_" + uuid.New().String()[:8]
			return wordApp.SaveDocument(filepath.Join(config.App.DocumentsDir, name+".docx"))
		case "export_pdf":
			name := "export_" + uuid.New().String()[:8]
			return wordApp.ExportPDF(filepath.Join(config.App.DocumentsDir, name+".pdf"))
		}
		return nil
	}); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "action": action})
}
