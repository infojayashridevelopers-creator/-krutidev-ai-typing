import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/websocket_service.dart';
import '../utils/download_helper.dart';

enum RecordingState { idle, recording, processing }

class AppProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  final WebSocketService _wsService = WebSocketService();

  User? _user;
  RecordingState _recordingState = RecordingState.idle;
  WordSettings _wordSettings = WordSettings();
  final List<TranscriptEntry> _transcripts = [];
  List<DocumentTemplate> _templates = [];
  String _statusMessage = '';
  bool _wordConnected = false;
  final bool _isUseWebSocket = true;
  String _lastUnicodeText = '';
  String _lastKrutiText = '';

  // Language: 'hi' = Hindi, 'mr' = Marathi
  String _selectedLanguage = 'hi';

  User? get user => _user;
  RecordingState get recordingState => _recordingState;
  WordSettings get wordSettings => _wordSettings;
  List<TranscriptEntry> get transcripts => _transcripts;
  List<DocumentTemplate> get templates => _templates;
  String get statusMessage => _statusMessage;
  bool get wordConnected => _wordConnected;
  bool get isRecording => _recordingState == RecordingState.recording;
  bool get isProcessing => _recordingState == RecordingState.processing;
  String get lastUnicodeText => _lastUnicodeText;
  String get lastKrutiText => _lastKrutiText;
  String get selectedLanguage => _selectedLanguage;

  String get selectedLanguageName =>
      _selectedLanguage == 'mr' ? 'मराठी' : 'हिंदी';

  void setLanguage(String langCode) {
    _selectedLanguage = langCode;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> init() async {
    await ApiService.loadToken();
    if (_isUseWebSocket) {
      await connectWebSocket();
    }
    await loadTemplates();
  }

  Future<bool> connectWebSocket() async {
    final connected = await _wsService.connect();
    // Don't set _wordConnected here — wait for the 'word_connected' server response.
    // WS connecting ≠ Word automation ready.
    if (connected) _wsService.messages.listen(_handleWSMessage);
    notifyListeners();
    return connected;
  }

  void _handleWSMessage(Map<String, dynamic> msg) {
    final type = msg['type'] as String;
    switch (type) {
      case 'word_connected':
        _wordConnected = true;
        _statusMessage = 'Word connected';
      case 'typed':
        final data = msg['data'] as Map<String, dynamic>?;
        _lastKrutiText = data?['kruti_text'] ?? '';
        _statusMessage = 'Text typed in Word';
      case 'command_executed':
        final data = msg['data'] as Map<String, dynamic>?;
        _statusMessage = 'Command: ${data?['action'] ?? ''}';
      case 'word_disconnected':
        _wordConnected = false;
        _statusMessage = 'Word disconnected';
    }
    notifyListeners();
  }

  Future<void> startRecording() async {
    if (_recordingState != RecordingState.idle) return;

    final path = await _audioService.startRecording();
    if (path != null) {
      _recordingState = RecordingState.recording;
      _statusMessage = _selectedLanguage == 'mr'
          ? 'रेकॉर्डिंग सुरू...'
          : 'Recording...';
      notifyListeners();
    }
  }

  Future<void> stopAndProcess() async {
    if (_recordingState != RecordingState.recording) return;

    _recordingState = RecordingState.processing;
    _statusMessage = _selectedLanguage == 'mr'
        ? 'ऑडिओ प्रक्रिया करत आहे...'
        : 'Processing audio...';
    notifyListeners();

    try {
      final audioPath = await _audioService.stopRecording();
      if (audioPath == null) {
        _setError('Recording failed');
        return;
      }

      _statusMessage = 'Uploading audio...';
      notifyListeners();
      final serverPath = await ApiService.uploadAudio(audioPath);
      if (serverPath == null) {
        _setError('Upload failed');
        return;
      }

      // Speech to text — pass selected language
      _statusMessage = _selectedLanguage == 'mr'
          ? 'मराठी ओळखत आहे...'
          : 'Recognizing Hindi speech...';
      notifyListeners();
      final sttResult =
          await ApiService.speechToText(serverPath, _selectedLanguage);
      _lastUnicodeText = sttResult['unicode_text'] ?? '';

      if (_lastUnicodeText.isEmpty) {
        _setError(_selectedLanguage == 'mr'
            ? 'बोलणे ओळखले नाही'
            : 'No speech detected');
        return;
      }

      // Convert Devanagari → Kruti Dev (same mapping for both languages)
      _statusMessage = 'Converting to Kruti Dev...';
      notifyListeners();
      final convertResult = await ApiService.convertToKruti(
          _lastUnicodeText, _selectedLanguage);
      _lastKrutiText = convertResult['kruti_text'] ?? '';

      _transcripts.insert(
        0,
        TranscriptEntry(
          unicodeText: _lastUnicodeText,
          krutiText: _lastKrutiText,
          language: _selectedLanguage,
          timestamp: DateTime.now(),
        ),
      );

      _statusMessage = 'Typing in Word...';
      notifyListeners();

      if (_isUseWebSocket && _wordConnected) {
        _wsService.typeText(_lastUnicodeText);
      } else {
        await ApiService.typeInWord(_lastUnicodeText, settings: _wordSettings);
      }

      _statusMessage = _selectedLanguage == 'mr'
          ? 'मजकूर Word मध्ये टाइप झाला!'
          : 'Done! Text typed in Word.';
    } catch (e) {
      _setError('Error: $e');
    } finally {
      _recordingState = RecordingState.idle;
      notifyListeners();
    }
  }

  Future<void> cancelRecording() async {
    await _audioService.cancelRecording();
    _recordingState = RecordingState.idle;
    _statusMessage = 'Recording cancelled';
    notifyListeners();
  }

  Future<void> sendVoiceCommand(String command) async {
    if (_isUseWebSocket && _wordConnected) {
      _wsService.voiceCommand(command);
    } else {
      await ApiService.voiceCommand(command);
    }
    _statusMessage = 'Command: $command';
    notifyListeners();
  }

  Future<void> newDocument() async {
    final ok = await ApiService.newWordDocument();
    _statusMessage = ok ? 'New document created' : 'Failed to create document';
    notifyListeners();
  }

  Future<void> saveDocument(String name) async {
    final path = await ApiService.saveDocument(name);
    _statusMessage = path != null ? 'Saved: $path' : 'Save failed';
    notifyListeners();
  }

  Future<void> exportPDF(String name) async {
    final path = await ApiService.exportPDF(name);
    _statusMessage = path != null ? 'PDF exported: $path' : 'Export failed';
    notifyListeners();
  }

  Future<void> applySettings() async {
    await ApiService.applyWordSettings(_wordSettings);
    _statusMessage = 'Settings applied';
    notifyListeners();
  }

  void updateSettings(WordSettings settings) {
    _wordSettings = settings;
    notifyListeners();
  }

  Future<void> loadTemplates() async {
    _templates = await ApiService.getTemplates();
    notifyListeners();
  }

  void clearTranscripts() {
    _transcripts.clear();
    notifyListeners();
  }

  // ── Mobile / cross-platform output actions ─────────────────────────────

  Future<void> copyToClipboard() async {
    if (_lastKrutiText.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _lastKrutiText));
    _statusMessage = 'Text copied to clipboard ✓';
    notifyListeners();
  }

  Future<void> shareKrutiText() async {
    if (_lastKrutiText.isEmpty) return;
    if (kIsWeb) {
      await Clipboard.setData(ClipboardData(text: _lastKrutiText));
      _statusMessage = 'Web: text copied to clipboard ✓';
    } else {
      await Share.share(_lastKrutiText, subject: 'Kruti Dev Text');
      _statusMessage = 'Shared!';
    }
    notifyListeners();
  }

  Future<void> downloadAsDocx() async {
    if (_lastKrutiText.isEmpty) return;
    _statusMessage = 'Generating .docx...';
    notifyListeners();
    try {
      final bytes = await ApiService.generateDocx(_lastKrutiText);
      if (bytes == null) {
        _statusMessage = 'Failed to generate document';
        notifyListeners();
        return;
      }
      await downloadDocxFile(bytes, 'krutidev_document.docx');
      _statusMessage = 'Document ready ✓';
    } catch (e) {
      _statusMessage = 'Error: $e';
    }
    notifyListeners();
  }

  void _setError(String message) {
    _recordingState = RecordingState.idle;
    _statusMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    _wsService.dispose();
    super.dispose();
  }
}
