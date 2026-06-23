package handlers

import (
	"net/http"

	"krutidev-ai-typing/db"
	"krutidev-ai-typing/models"

	"github.com/gin-gonic/gin"
)

// GetTemplates returns all templates for the current user
func GetTemplates(c *gin.Context) {
	userID := c.GetUint("user_id")
	var templates []models.Template
	db.DB.Where("user_id = ?", userID).Find(&templates)
	c.JSON(http.StatusOK, gin.H{"templates": templates})
}

// CreateTemplate saves a new document template
func CreateTemplate(c *gin.Context) {
	var req struct {
		Name     string `json:"name" binding:"required"`
		FilePath string `json:"file_path"`
		Category string `json:"category"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID := c.GetUint("user_id")
	template := models.Template{
		UserID:   userID,
		Name:     req.Name,
		FilePath: req.FilePath,
		Category: req.Category,
	}

	if err := db.DB.Create(&template).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"template": template})
}

// DeleteTemplate removes a template
func DeleteTemplate(c *gin.Context) {
	id := c.Param("id")
	userID := c.GetUint("user_id")

	var template models.Template
	if err := db.DB.Where("id = ? AND user_id = ?", id, userID).First(&template).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "template not found"})
		return
	}

	db.DB.Delete(&template)
	c.JSON(http.StatusOK, gin.H{"success": true})
}

// GetSettings returns user settings
func GetSettings(c *gin.Context) {
	userID := c.GetUint("user_id")
	var settings []models.Setting
	db.DB.Where("user_id = ?", userID).Find(&settings)

	settingsMap := make(map[string]string)
	for _, s := range settings {
		settingsMap[s.Key] = s.Value
	}

	c.JSON(http.StatusOK, gin.H{"settings": settingsMap})
}

// UpdateSetting updates a single setting
func UpdateSetting(c *gin.Context) {
	var req struct {
		Key   string `json:"key" binding:"required"`
		Value string `json:"value"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID := c.GetUint("user_id")
	var setting models.Setting
	db.DB.Where("user_id = ? AND key = ?", userID, req.Key).First(&setting)

	if setting.ID == 0 {
		setting = models.Setting{UserID: userID, Key: req.Key, Value: req.Value}
		db.DB.Create(&setting)
	} else {
		setting.Value = req.Value
		db.DB.Save(&setting)
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "setting": setting})
}

// GetLogs returns recent logs for the user
func GetLogs(c *gin.Context) {
	userID := c.GetUint("user_id")
	var logs []models.Log
	db.DB.Where("user_id = ?", userID).Order("timestamp desc").Limit(100).Find(&logs)
	c.JSON(http.StatusOK, gin.H{"logs": logs})
}
