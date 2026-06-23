class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
      );
}

class WordSettings {
  String fontName;
  double fontSize;
  String alignment;
  double lineSpacing;
  double spaceBefore;
  double spaceAfter;
  bool bold;
  bool italic;
  bool underline;

  WordSettings({
    this.fontName = 'Kruti Dev 010',
    this.fontSize = 14,
    this.alignment = 'justify',
    this.lineSpacing = 1.15,
    this.spaceBefore = 6,
    this.spaceAfter = 6,
    this.bold = false,
    this.italic = false,
    this.underline = false,
  });

  Map<String, dynamic> toJson() => {
        'font_name': fontName,
        'font_size': fontSize,
        'alignment': alignment,
        'line_spacing': lineSpacing,
        'space_before': spaceBefore,
        'space_after': spaceAfter,
        'bold': bold,
        'italic': italic,
        'underline': underline,
      };
}

class DocumentTemplate {
  final int id;
  final String name;
  final String filePath;
  final String category;

  DocumentTemplate({
    required this.id,
    required this.name,
    required this.filePath,
    required this.category,
  });

  factory DocumentTemplate.fromJson(Map<String, dynamic> json) =>
      DocumentTemplate(
        id: json['id'],
        name: json['name'],
        filePath: json['file_path'] ?? '',
        category: json['category'] ?? '',
      );
}

class TranscriptEntry {
  final String unicodeText;
  final String krutiText;
  final String language; // 'hi' or 'mr'
  final DateTime timestamp;

  TranscriptEntry({
    required this.unicodeText,
    required this.krutiText,
    this.language = 'hi',
    required this.timestamp,
  });

  String get languageLabel => language == 'mr' ? 'मराठी' : 'हिंदी';
}
