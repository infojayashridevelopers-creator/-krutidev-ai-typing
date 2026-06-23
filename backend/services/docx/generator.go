package docx

import (
	"archive/zip"
	"bytes"
	"fmt"
	"strings"
	"time"
)

// GenerateKrutiDevDocx creates a .docx file with Kruti Dev 010 font from already-encoded text.
func GenerateKrutiDevDocx(krutiText string) ([]byte, error) {
	paragraphs := strings.Split(strings.ReplaceAll(krutiText, "\r\n", "\n"), "\n")

	var buf bytes.Buffer
	w := zip.NewWriter(&buf)

	entries := []struct {
		name    string
		content string
	}{
		{"[Content_Types].xml", contentTypesXML},
		{"_rels/.rels", relsXML},
		{"word/_rels/document.xml.rels", wordRelsXML},
		{"word/document.xml", buildDocumentXML(paragraphs)},
		{"word/settings.xml", settingsXML},
		{"docProps/app.xml", appXML},
		{"docProps/core.xml", coreXML(time.Now())},
	}

	for _, e := range entries {
		fw, err := w.Create(e.name)
		if err != nil {
			return nil, fmt.Errorf("creating %s: %w", e.name, err)
		}
		if _, err := fw.Write([]byte(e.content)); err != nil {
			return nil, fmt.Errorf("writing %s: %w", e.name, err)
		}
	}

	if err := w.Close(); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

func buildDocumentXML(paragraphs []string) string {
	const ns = `xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"`
	var sb strings.Builder
	sb.WriteString(`<?xml version="1.0" encoding="UTF-8" standalone="yes"?>`)
	sb.WriteString(`<w:document ` + ns + `><w:body>`)

	for _, para := range paragraphs {
		sb.WriteString(`<w:p><w:pPr><w:rPr>`)
		sb.WriteString(`<w:rFonts w:ascii="Kruti Dev 010" w:hAnsi="Kruti Dev 010"/>`)
		sb.WriteString(`</w:rPr></w:pPr>`)
		if para != "" {
			sb.WriteString(`<w:r><w:rPr>`)
			sb.WriteString(`<w:rFonts w:ascii="Kruti Dev 010" w:hAnsi="Kruti Dev 010"/>`)
			sb.WriteString(`<w:sz w:val="28"/>`)
			sb.WriteString(`</w:rPr>`)
			sb.WriteString(`<w:t xml:space="preserve">`)
			sb.WriteString(xmlEscape(para))
			sb.WriteString(`</w:t></w:r>`)
		}
		sb.WriteString(`</w:p>`)
	}

	sb.WriteString(`<w:sectPr/></w:body></w:document>`)
	return sb.String()
}

func xmlEscape(s string) string {
	s = strings.ReplaceAll(s, "&", "&amp;")
	s = strings.ReplaceAll(s, "<", "&lt;")
	s = strings.ReplaceAll(s, ">", "&gt;")
	s = strings.ReplaceAll(s, `"`, "&quot;")
	return s
}

func coreXML(t time.Time) string {
	ts := t.UTC().Format("2006-01-02T15:04:05Z")
	return fmt.Sprintf(`<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties
  xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:creator>Kruti Dev AI Typing</dc:creator>
  <dcterms:created xsi:type="dcterms:W3CDTF">%s</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">%s</dcterms:modified>
</cp:coreProperties>`, ts, ts)
}

const contentTypesXML = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/settings.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>`

const relsXML = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>`

const wordRelsXML = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings" Target="settings.xml"/>
</Relationships>`

const settingsXML = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:settings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>`

const appXML = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties">
  <Application>Kruti Dev AI Typing</Application>
</Properties>`
