package handlers

import (
	"encoding/json"
	"log"
	"net/http"

	"krutidev-ai-typing/services/unicode"
	"krutidev-ai-typing/services/word"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

type WSMessage struct {
	Type    string          `json:"type"`
	Payload json.RawMessage `json:"payload"`
}

type WSResponse struct {
	Type    string      `json:"type"`
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

// WebSocketHandler handles real-time voice typing via WebSocket.
// All Word COM calls are dispatched through word.RunOnCOMThread so they
// execute on the single OS thread that has CoInitialize called.
func WebSocketHandler(c *gin.Context) {
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Println("WebSocket upgrade error:", err)
		return
	}
	defer conn.Close()

	log.Println("WebSocket client connected")

	var wordApp *word.WordApp

	for {
		_, msg, err := conn.ReadMessage()
		if err != nil {
			break
		}

		var wsMsg WSMessage
		if err := json.Unmarshal(msg, &wsMsg); err != nil {
			sendWSError(conn, "invalid_message", "invalid JSON format")
			continue
		}

		switch wsMsg.Type {

		case "connect_word":
			if err := word.RunOnCOMThread(func() error {
				var connErr error
				wordApp, connErr = word.Connect()
				return connErr
			}); err != nil {
				sendWSError(conn, "word_error", err.Error())
				continue
			}
			sendWSResponse(conn, "word_connected", true, nil)

		case "type_text":
			var payload struct {
				Text      string `json:"text"`
				IsUnicode bool   `json:"is_unicode"`
			}
			json.Unmarshal(wsMsg.Payload, &payload)

			text := payload.Text
			if payload.IsUnicode {
				text = unicode.ConvertUnicodeToKruti(payload.Text)
			}

			if wordApp != nil {
				word.RunOnCOMThread(func() error {
					return wordApp.TypeText(text)
				})
			}
			sendWSResponse(conn, "typed", true, map[string]string{"kruti_text": text})

		case "voice_command":
			var payload struct {
				Command string `json:"command"`
			}
			json.Unmarshal(wsMsg.Payload, &payload)

			action := word.VoiceCommandToAction(payload.Command)
			if wordApp != nil && action != "" {
				word.RunOnCOMThread(func() error {
					runWSWordAction(wordApp, action)
					return nil
				})
			}
			sendWSResponse(conn, "command_executed", true, map[string]string{"action": action})

		case "live_transcript":
			var payload struct {
				Text string `json:"text"`
			}
			json.Unmarshal(wsMsg.Payload, &payload)
			krutiText := unicode.ConvertUnicodeToKruti(payload.Text)
			sendWSResponse(conn, "transcript_update", true, map[string]string{
				"unicode_text": payload.Text,
				"kruti_text":   krutiText,
			})

		case "ping":
			sendWSResponse(conn, "pong", true, nil)

		case "disconnect_word":
			if wordApp != nil {
				word.RunOnCOMThread(func() error {
					wordApp.Close()
					return nil
				})
				wordApp = nil
			}
			sendWSResponse(conn, "word_disconnected", true, nil)
		}
	}

	if wordApp != nil {
		word.RunOnCOMThread(func() error {
			wordApp.Close()
			return nil
		})
	}
	log.Println("WebSocket client disconnected")
}

// runWSWordAction executes a word action; must be called inside RunOnCOMThread.
func runWSWordAction(wordApp *word.WordApp, action string) {
	switch action {
	case "enter", "new_paragraph":
		wordApp.TypeParagraph()
	case "bold_on":
		wordApp.SetBold(true)
	case "bold_off":
		wordApp.SetBold(false)
	case "italic_on":
		wordApp.SetItalic(true)
	case "italic_off":
		wordApp.SetItalic(false)
	case "underline_on":
		wordApp.SetUnderline(true)
	case "underline_off":
		wordApp.SetUnderline(false)
	case "space":
		wordApp.TypeText(" ")
	case "full_stop":
		wordApp.TypeText("।")
	case "comma":
		wordApp.TypeText(",")
	}
}

func sendWSResponse(conn *websocket.Conn, msgType string, success bool, data interface{}) {
	resp := WSResponse{Type: msgType, Success: success, Data: data}
	conn.WriteJSON(resp)
}

func sendWSError(conn *websocket.Conn, msgType, errMsg string) {
	resp := WSResponse{Type: msgType, Success: false, Error: errMsg}
	conn.WriteJSON(resp)
}
