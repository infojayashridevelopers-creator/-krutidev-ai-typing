//go:build !windows

package word

import (
	"errors"

	"krutidev-ai-typing/models"
)

var errNotOnWindows = errors.New("Word COM automation is only available on Windows")

type WordApp struct{}

func Connect() (*WordApp, error)                                  { return nil, errNotOnWindows }
func (w *WordApp) NewDocument() error                             { return errNotOnWindows }
func (w *WordApp) OpenDocument(path string) error                 { return errNotOnWindows }
func (w *WordApp) ApplySettings(s models.WordSettings) error      { return errNotOnWindows }
func (w *WordApp) TypeText(text string) error                     { return errNotOnWindows }
func (w *WordApp) TypeParagraph() error                           { return errNotOnWindows }
func (w *WordApp) SetBold(bold bool) error                        { return errNotOnWindows }
func (w *WordApp) SetItalic(italic bool) error                    { return errNotOnWindows }
func (w *WordApp) SetUnderline(underline bool) error              { return errNotOnWindows }
func (w *WordApp) SaveDocument(path string) error                 { return errNotOnWindows }
func (w *WordApp) ExportPDF(path string) error                    { return errNotOnWindows }
func (w *WordApp) Close()                                         {}

// VoiceCommandToAction maps spoken Hindi/Marathi commands to Word actions.
func VoiceCommandToAction(command string) string {
	commands := map[string]string{
		"एंटर": "enter", "नया पैराग्राफ": "new_paragraph",
		"बोल्ड ऑन": "bold_on", "बोल्ड ऑफ": "bold_off",
		"इटैलिक ऑन": "italic_on", "इटैलिक ऑफ": "italic_off",
		"अंडरलाइन": "underline_on", "अंडरलाइन ऑफ": "underline_off",
		"डॉक्यूमेंट सेव": "save", "पीडीएफ बनाओ": "export_pdf",
		"स्पेस": "space", "पूर्ण विराम": "full_stop", "अल्प विराम": "comma",
		"एंटर द्या": "enter", "नवा परिच्छेद": "new_paragraph",
		"ठळक चालू": "bold_on", "ठळक बंद": "bold_off",
		"तिरपे चालू": "italic_on", "तिरपे बंद": "italic_off",
		"अधोरेखित": "underline_on", "अधोरेखित बंद": "underline_off",
		"दस्तऐवज जतन करा": "save", "पीडीएफ करा": "export_pdf",
		"रिकामी जागा": "space", "पूर्णविराम": "full_stop", "स्वल्पविराम": "comma",
	}
	if action, ok := commands[command]; ok {
		return action
	}
	return ""
}
