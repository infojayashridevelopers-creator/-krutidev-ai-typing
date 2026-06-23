package unicode

import (
	"strings"
	"unicode/utf8"
)

// Single Unicode rune → Kruti Dev string mapping
var runeToKruti = map[rune]string{
	// Vowels (independent)
	'अ': "v",
	'आ': "vk",
	'इ': "b",
	'ई': "bZ",
	'उ': "m",
	'ऊ': "w",
	'ऋ': "_",
	'ए': ",",
	'ऐ': "S",
	'ओ': "vks",
	'औ': "vkS",

	// Consonants
	'क': "d",
	'ख': "[k",
	'ग': "x",
	'घ': "?k",
	'ङ': "M~",
	'च': "p",
	'छ': "N",
	'ज': "t",
	'झ': ">k",
	'ञ': "¥",
	'ट': "V",
	'ठ': "B",
	'ड': "M",
	'ढ': "<+",
	'ण': ".k",
	'त': "r",
	'थ': "Fk",
	'द': "n",
	'ध': "/k",
	'न': "u",
	'प': "i",
	'फ': "Q",
	'ब': "c",
	'भ': "Hk",
	'म': "e",
	'य': ";",
	'र': "j",
	'ल': "y",
	'व': "o",
	'श': "'k",
	'ष': "\"k",
	'स': "l",
	'ह': "g",
	'ळ': "G",

	// Matras (vowel signs)
	'ा': "k",
	'ि': "f",
	'ी': "h",
	'ु': "q",
	'ू': "w",
	'ृ': "`",
	'े': "s",
	'ै': "S",
	'ो': "ks",
	'ौ': "kS",
	'ं': "a",
	'ः': "%",
	'ँ': "¡",
	'्': "~",

	// Devanagari digits
	'०': "0",
	'१': "1",
	'२': "2",
	'३': "3",
	'४': "4",
	'५': "5",
	'६': "6",
	'७': "7",
	'८': "8",
	'९': "9",

	// Special punctuation
	'।': "A",
	'ॐ': "|",
}

// Multi-character Unicode strings → Kruti Dev encoding
// These must be checked before single-rune mapping
var multiCharToKruti = map[string]string{
	// Special combined vowels
	"अं": "va",  // अं
	"अः": "v%",  // अः

	// Conjunct consonants using halant (्)
	"क्क": "DD",      // क्क
	"क्त": "Dr",      // क्त
	"क्न": "Du",      // क्न
	"क्य": "D;",      // क्य
	"क्र": "Ø",       // क्र
	"क्ल": "Dy",      // क्ल
	"क्व": "Do",      // क्व
	"क्ष": "{k",      // क्ष (ksha)
	"क्स": "Dl",      // क्स
	"ख्र": "[kz",     // ख्र
	"ग्र": "xz",      // ग्र
	"ग्न": "Xu",      // ग्न
	"घ्र": "?kz",     // घ्र
	"च्च": "PN",      // च्च
	"च्छ": "PN",      // च्छ
	"च्य": "P;",      // च्य
	"ज्ञ": "K",       // ज्ञ (gya)
	"ज्य": "T;",      // ज्य
	"ज्र": "Tz",      // ज्र
	"ट्ट": "VV",      // ट्ट
	"ट्र": "Vz",      // ट्र
	"ड्र": "Mz",      // ड्र
	"त्त": "Ùk",      // त्त
	"त्न": "Ru",      // त्न
	"त्म": "Re",      // त्म
	"त्य": "R;",      // त्य
	"त्र": "=",       // त्र (tra)
	"त्व": "Ro",      // त्व
	"त्स": "Rl",      // त्स
	"थ्र": "Fkz",     // थ्र
	"द्द": "nn",      // द्द
	"द्ध": "n/k",     // द्ध
	"द्म": "ne",      // द्म
	"द्र": "nz",      // द्र
	"द्व": "n~o",     // द्व
	"ध्र": "/kz",     // ध्र
	"ध्य": "/;",      // ध्य
	"न्त": "Ur",      // न्त
	"न्थ": "UFk",     // न्थ
	"न्द": "Un",      // न्द
	"न्ध": "U/k",     // न्ध
	"न्न": "Uu",      // न्न
	"न्य": "U;",      // न्य
	"न्र": "uz",      // न्र
	"न्व": "Uo",      // न्व
	"न्स": "Ul",      // न्स
	"प्त": "Ir",      // प्त
	"प्न": "Iu",      // प्न
	"प्य": "I;",      // प्य
	"प्र": "iz",      // प्र
	"प्ल": "Iy",      // प्ल
	"फ्र": "Qz",      // फ्र
	"ब्र": "cz",      // ब्र
	"भ्र": "Hkz",     // भ्र
	"म्न": "eu",      // म्न
	"म्य": "E;",      // म्य
	"म्र": "ez",      // म्र
	"म्व": "Eo",      // म्व
	"ल्य": "Y;",      // ल्य
	"ल्ल": "Yy",      // ल्ल
	"व्र": "oz",      // व्र
	"व्य": "O;",      // व्य
	"श्च": "'kP",     // श्च
	"श्न": "'ku",     // श्न
	"श्र": "J",       // श्र (shra)
	"श्व": "'ko",     // श्व
	"ष्ट": "\"V",     // ष्ट
	"ष्ठ": "\"B",     // ष्ठ
	"ष्ण": "\".k",    // ष्ण
	"ष्य": "\";",     // ष्य
	"स्त": "Lr",      // स्त
	"स्थ": "LFk",     // स्थ
	"स्न": "Lu",      // स्न
	"स्प": "Li",      // स्प
	"स्फ": "LQ",      // स्फ
	"स्म": "Le",      // स्म
	"स्य": "L;",      // स्य
	"स्र": "lz",      // स्र
	"स्व": "Lo",      // स्व
	"ह्न": "gu",      // ह्न
	"ह्य": "g~;",     // ह्य
	"ह्र": "gz",      // ह्र
	"ह्व": "go",      // ह्व
	"ह्म": "ge",      // ह्म
	"ह्ल": "gy",      // ह्ल
}

// ConvertUnicodeToKruti converts Unicode Devanagari text to Kruti Dev 010 encoding
func ConvertUnicodeToKruti(input string) string {
	if input == "" {
		return ""
	}

	runes := []rune(input)
	var result strings.Builder
	i := 0

	for i < len(runes) {
		// Try 3-rune multi-char sequences first (consonant + halant + consonant)
		if i+2 < len(runes) {
			key := string(runes[i : i+3])
			if kruti, ok := multiCharToKruti[key]; ok {
				// Check if there's an i-matra (ि) after conjunct - place it before
				if i+3 < len(runes) && runes[i+3] == 'ि' {
					result.WriteString("f")
					result.WriteString(kruti)
					i += 4
					continue
				}
				result.WriteString(kruti)
				i += 3
				continue
			}
		}

		// Try 2-rune sequences (e.g., अं, अः)
		if i+1 < len(runes) {
			key := string(runes[i : i+2])
			if kruti, ok := multiCharToKruti[key]; ok {
				result.WriteString(kruti)
				i += 2
				continue
			}
		}

		// Handle र् (ra-halant = reph, displayed as Z after the consonant)
		if i+2 < len(runes) && runes[i] == 'र' && runes[i+1] == '्' {
			// reph: write next consonant first, then Z
			if kruti, ok := runeToKruti[runes[i+2]]; ok {
				result.WriteString(kruti)
				result.WriteString("Z")
				i += 3
				continue
			}
		}

		// Handle consonant + ि (i-matra comes before consonant in Kruti Dev)
		if i+1 < len(runes) && runes[i+1] == 'ि' {
			if kruti, ok := runeToKruti[runes[i]]; ok {
				result.WriteString("f")
				result.WriteString(kruti)
				i += 2
				continue
			}
		}

		// Single rune mapping
		r := runes[i]
		if kruti, ok := runeToKruti[r]; ok {
			result.WriteString(kruti)
		} else if r == ' ' || r == '\n' || r == '\t' || r == '\r' {
			result.WriteRune(r)
		} else if utf8.RuneLen(r) == 1 {
			result.WriteRune(r)
		} else {
			result.WriteRune(r)
		}
		i++
	}

	return result.String()
}

// DetectLanguage returns "hindi" if text contains Devanagari characters
func DetectLanguage(text string) string {
	for _, r := range text {
		if r >= 0x0900 && r <= 0x097F {
			return "hindi"
		}
	}
	return "english"
}
