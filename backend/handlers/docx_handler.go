package handlers

import (
	"net/http"

	docxsvc "krutidev-ai-typing/services/docx"

	"github.com/gin-gonic/gin"
)

// GenerateDocx creates a .docx file with Kruti Dev 010 font and returns it as a download.
// Accepts: {"text": "<already kruti-encoded string>"}
func GenerateDocx(c *gin.Context) {
	var req struct {
		Text string `json:"text" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "text is required"})
		return
	}

	data, err := docxsvc.GenerateKrutiDevDocx(req.Text)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	const mime = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
	c.Header("Content-Disposition", `attachment; filename="krutidev_document.docx"`)
	c.Data(http.StatusOK, mime, data)
}
