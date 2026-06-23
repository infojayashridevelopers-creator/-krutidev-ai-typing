package stt

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"krutidev-ai-typing/config"
)

type TranscribeResult struct {
	Text     string `json:"text"`
	Language string `json:"language"`
}

// SupportedLanguages lists languages supported by this app
var SupportedLanguages = map[string]string{
	"hi": "Hindi",
	"mr": "Marathi",
}

// Transcribe runs Whisper STT on the given audio file.
// lang: "hi" for Hindi, "mr" for Marathi (defaults to "hi")
func Transcribe(audioPath string, lang string) (*TranscribeResult, error) {
	if lang == "" {
		lang = "hi"
	}
	if _, ok := SupportedLanguages[lang]; !ok {
		lang = "hi"
	}

	outputDir := filepath.Dir(audioPath)
	baseName := strings.TrimSuffix(filepath.Base(audioPath), filepath.Ext(audioPath))

	// Convert to WAV 16kHz mono via ffmpeg
	wavPath := audioPath
	if !strings.HasSuffix(strings.ToLower(audioPath), ".wav") {
		wavPath = filepath.Join(outputDir, baseName+".wav")
		ffmpegCmd := exec.Command(
			config.App.FFmpegPath,
			"-i", audioPath,
			"-ar", "16000",
			"-ac", "1",
			"-y",
			wavPath,
		)
		if err := ffmpegCmd.Run(); err != nil {
			return nil, fmt.Errorf("ffmpeg conversion failed: %w", err)
		}
		defer os.Remove(wavPath)
	}

	model := config.App.WhisperModel
	if model == "" {
		model = "small"
	}

	whisperCmd := exec.Command(
		config.App.WhisperPath,
		wavPath,
		"--language", lang,
		"--model", model,
		"--output_format", "txt",
		"--output_dir", outputDir,
		"--fp16", "False",
	)
	whisperCmd.Env = append(os.Environ(), "PYTHONUTF8=1", "PYTHONIOENCODING=utf-8")

	out, err := whisperCmd.CombinedOutput()
	if err != nil {
		return nil, fmt.Errorf("whisper failed: %w, output: %s", err, string(out))
	}

	txtPath := filepath.Join(outputDir, baseName+".txt")
	defer os.Remove(txtPath)

	content, err := os.ReadFile(txtPath)
	if err != nil {
		text := parseWhisperOutput(string(out))
		if text == "" {
			return nil, fmt.Errorf("could not read whisper output: %w", err)
		}
		return &TranscribeResult{Text: text, Language: lang}, nil
	}

	text := strings.TrimSpace(string(content))
	text = cleanWhisperText(text)

	return &TranscribeResult{
		Text:     text,
		Language: lang,
	}, nil
}

func parseWhisperOutput(output string) string {
	lines := strings.Split(output, "\n")
	var textLines []string
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line != "" && !strings.HasPrefix(line, "[") && !strings.HasPrefix(line, "Detecting") {
			textLines = append(textLines, line)
		}
	}
	return strings.Join(textLines, " ")
}

func cleanWhisperText(text string) string {
	text = strings.TrimSpace(text)
	var cleaned strings.Builder
	for _, line := range strings.Split(text, "\n") {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "[") && strings.Contains(line, "-->") {
			continue
		}
		if line != "" {
			cleaned.WriteString(line)
			cleaned.WriteString(" ")
		}
	}
	return strings.TrimSpace(cleaned.String())
}
