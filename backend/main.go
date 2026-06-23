package main

import (
	"log"
	"net/http"
	"os"
	"path/filepath"

	"krutidev-ai-typing/config"
	"krutidev-ai-typing/db"
	"krutidev-ai-typing/handlers"
	"krutidev-ai-typing/middleware"

	"github.com/gin-gonic/gin"
)

func main() {
	// Create required directories
	os.MkdirAll(config.App.UploadDir, 0755)
	os.MkdirAll(config.App.DocumentsDir, 0755)

	// Init DB
	db.Init(config.App.DBPath)

	// Setup router
	r := gin.Default()

	// CORS
	r.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type,Authorization")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	// Public routes
	r.POST("/api/auth/register", handlers.Register)
	r.POST("/api/auth/login", handlers.Login)
	r.GET("/ws", handlers.WebSocketHandler)

	// Protected routes
	api := r.Group("/api", middleware.AuthRequired())
	{
		// Speech & conversion
		api.POST("/upload/audio", handlers.UploadAudio)
		api.POST("/speech-to-text", handlers.SpeechToText)
		api.POST("/unicode/convert", handlers.ConvertToKrutiDev)
		api.GET("/languages", handlers.GetSupportedLanguages)

		// Word automation
		api.POST("/word/new", handlers.NewWordDocument)
		api.POST("/word/type", handlers.TypeInWord)
		api.POST("/word/settings", handlers.ApplyWordSettings)
		api.POST("/word/command", handlers.VoiceCommand)
		api.POST("/document/save", handlers.SaveDocument)
		api.POST("/document/export", handlers.ExportPDF)
		api.POST("/document/generate", handlers.GenerateDocx)

		// Templates & settings
		api.GET("/documents", handlers.GetTemplates)
		api.POST("/documents", handlers.CreateTemplate)
		api.DELETE("/documents/:id", handlers.DeleteTemplate)
		api.GET("/settings", handlers.GetSettings)
		api.PUT("/settings", handlers.UpdateSetting)
		api.GET("/logs", handlers.GetLogs)
	}

	// Serve Flutter web SPA — accessible from any device on the network via http://<PC_IP>:8080
	webDir := "../frontend/build/web"
	if _, err := os.Stat(webDir); err == nil {
		absWeb, _ := filepath.Abs(webDir)
		fileServer := http.FileServer(http.Dir(absWeb))
		r.NoRoute(func(c *gin.Context) {
			// Serve actual static file if it exists, else fall back to index.html (SPA routing)
			urlPath := filepath.Clean(c.Request.URL.Path)
			candidate := filepath.Join(absWeb, urlPath)
			if info, err := os.Stat(candidate); err == nil && !info.IsDir() {
				fileServer.ServeHTTP(c.Writer, c.Request)
				return
			}
			c.File(filepath.Join(absWeb, "index.html"))
		})
		log.Printf("Serving Flutter web app — open http://localhost:8080 or http://<YOUR_IP>:8080 on any device")
	}

	log.Printf("Kruti Dev AI Typing Backend started on :%s", config.App.Port)
	r.Run(":" + config.App.Port)
}
