//go:build windows

package word

import (
	"fmt"

	"krutidev-ai-typing/models"

	"github.com/go-ole/go-ole"
	"github.com/go-ole/go-ole/oleutil"
)

// WordApp holds the COM automation objects
type WordApp struct {
	word      *ole.IDispatch
	docs      *ole.IDispatch
	activeDoc *ole.IDispatch
}

// Connect connects to a running Word instance or starts a new one.
// Must be called from within RunOnCOMThread — never call directly from
// a goroutine, as all COM calls must happen on the CoInitialize'd thread.
func Connect() (*WordApp, error) {
	var word *ole.IDispatch
	var err error

	// Try to connect to running instance first
	unknown, err := oleutil.GetActiveObject("Word.Application")
	if err != nil {
		// Start new instance
		wordClass, err2 := oleutil.CreateObject("Word.Application")
		if err2 != nil {
			return nil, fmt.Errorf("cannot start Word: %w", err2)
		}
		word, err = wordClass.QueryInterface(ole.IID_IDispatch)
		if err != nil {
			return nil, fmt.Errorf("cannot get Word dispatch: %w", err)
		}
	} else {
		word, err = unknown.QueryInterface(ole.IID_IDispatch)
		if err != nil {
			return nil, fmt.Errorf("cannot get Word dispatch: %w", err)
		}
	}

	// Make Word visible
	oleutil.PutProperty(word, "Visible", true)

	docs := oleutil.MustGetProperty(word, "Documents").ToIDispatch()

	return &WordApp{
		word: word,
		docs: docs,
	}, nil
}

// NewDocument creates and opens a new document
func (w *WordApp) NewDocument() error {
	result := oleutil.MustCallMethod(w.docs, "Add")
	w.activeDoc = result.ToIDispatch()
	return nil
}

// OpenDocument opens an existing document
func (w *WordApp) OpenDocument(path string) error {
	result := oleutil.MustCallMethod(w.docs, "Open", path)
	w.activeDoc = result.ToIDispatch()
	return nil
}

// ApplySettings applies word settings (font, size, alignment, etc.)
func (w *WordApp) ApplySettings(settings models.WordSettings) error {
	if w.activeDoc == nil {
		return fmt.Errorf("no document open")
	}

	selection := oleutil.MustGetProperty(w.word, "Selection").ToIDispatch()
	defer selection.Release()

	// Font settings
	font := oleutil.MustGetProperty(selection, "Font").ToIDispatch()
	defer font.Release()
	oleutil.PutProperty(font, "Name", settings.FontName)
	oleutil.PutProperty(font, "Size", settings.FontSize)
	oleutil.PutProperty(font, "Bold", settings.Bold)
	oleutil.PutProperty(font, "Italic", settings.Italic)
	oleutil.PutProperty(font, "Underline", settings.Underline)

	// Paragraph settings
	paraFormat := oleutil.MustGetProperty(selection, "ParagraphFormat").ToIDispatch()
	defer paraFormat.Release()

	// Alignment: 0=Left, 1=Center, 2=Right, 3=Justify
	alignMap := map[string]int{"left": 0, "center": 1, "right": 2, "justify": 3}
	if align, ok := alignMap[settings.Alignment]; ok {
		oleutil.PutProperty(paraFormat, "Alignment", align)
	}

	oleutil.PutProperty(paraFormat, "SpaceBefore", settings.SpaceBefore)
	oleutil.PutProperty(paraFormat, "SpaceAfter", settings.SpaceAfter)

	// Line spacing: wdLineSpaceMultiple = 5
	oleutil.PutProperty(paraFormat, "LineSpacingRule", 5)
	oleutil.PutProperty(paraFormat, "LineSpacing", settings.LineSpacing*12)

	return nil
}

// TypeText types text at current cursor position
func (w *WordApp) TypeText(text string) error {
	selection := oleutil.MustGetProperty(w.word, "Selection").ToIDispatch()
	defer selection.Release()

	oleutil.MustCallMethod(selection, "TypeText", text)
	return nil
}

// TypeParagraph inserts a new paragraph
func (w *WordApp) TypeParagraph() error {
	selection := oleutil.MustGetProperty(w.word, "Selection").ToIDispatch()
	defer selection.Release()
	oleutil.MustCallMethod(selection, "TypeParagraph")
	return nil
}

// SetBold sets bold formatting on selection
func (w *WordApp) SetBold(bold bool) error {
	selection := oleutil.MustGetProperty(w.word, "Selection").ToIDispatch()
	defer selection.Release()
	font := oleutil.MustGetProperty(selection, "Font").ToIDispatch()
	defer font.Release()
	oleutil.PutProperty(font, "Bold", bold)
	return nil
}

// SetItalic sets italic formatting
func (w *WordApp) SetItalic(italic bool) error {
	selection := oleutil.MustGetProperty(w.word, "Selection").ToIDispatch()
	defer selection.Release()
	font := oleutil.MustGetProperty(selection, "Font").ToIDispatch()
	defer font.Release()
	oleutil.PutProperty(font, "Italic", italic)
	return nil
}

// SetUnderline sets underline formatting
func (w *WordApp) SetUnderline(underline bool) error {
	selection := oleutil.MustGetProperty(w.word, "Selection").ToIDispatch()
	defer selection.Release()
	font := oleutil.MustGetProperty(selection, "Font").ToIDispatch()
	defer font.Release()
	val := 0
	if underline {
		val = 1 // wdUnderlineSingle
	}
	oleutil.PutProperty(font, "Underline", val)
	return nil
}

// SaveDocument saves the current document to path
func (w *WordApp) SaveDocument(path string) error {
	if w.activeDoc == nil {
		return fmt.Errorf("no document open")
	}
	// wdFormatDocumentDefault = 16
	oleutil.MustCallMethod(w.activeDoc, "SaveAs2", path, 16)
	return nil
}

// ExportPDF exports current document as PDF
func (w *WordApp) ExportPDF(path string) error {
	if w.activeDoc == nil {
		return fmt.Errorf("no document open")
	}
	// wdExportFormatPDF = 17
	oleutil.MustCallMethod(w.activeDoc, "ExportAsFixedFormat", path, 17)
	return nil
}

// Close releases COM objects. Must be called from within RunOnCOMThread.
func (w *WordApp) Close() {
	if w.activeDoc != nil {
		w.activeDoc.Release()
	}
	if w.docs != nil {
		w.docs.Release()
	}
	if w.word != nil {
		w.word.Release()
	}
}

// VoiceCommandToAction maps spoken Hindi and Marathi commands to Word actions
func VoiceCommandToAction(command string) string {
	commands := map[string]string{
		// ── Hindi commands ──────────────────────────────
		"एंटर":          "enter",
		"नया पैराग्राफ":  "new_paragraph",
		"बोल्ड ऑन":      "bold_on",
		"बोल्ड ऑफ":      "bold_off",
		"इटैलिक ऑन":     "italic_on",
		"इटैलिक ऑफ":     "italic_off",
		"अंडरलाइन":      "underline_on",
		"अंडरलाइन ऑफ":   "underline_off",
		"डॉक्यूमेंट सेव": "save",
		"पीडीएफ बनाओ":   "export_pdf",
		"स्पेस":         "space",
		"पूर्ण विराम":    "full_stop",
		"अल्प विराम":    "comma",
		// ── Marathi commands ─────────────────────────────
		"एंटर द्या":      "enter",
		"नवा परिच्छेद":   "new_paragraph",
		"ठळक चालू":       "bold_on",
		"ठळक बंद":        "bold_off",
		"तिरपे चालू":     "italic_on",
		"तिरपे बंद":      "italic_off",
		"अधोरेखित":       "underline_on",
		"अधोरेखित बंद":   "underline_off",
		"दस्तऐवज जतन करा": "save",
		"पीडीएफ करा":     "export_pdf",
		"रिकामी जागा":    "space",
		"पूर्णविराम":     "full_stop",
		"स्वल्पविराम":    "comma",
	}

	if action, ok := commands[command]; ok {
		return action
	}
	return ""
}
