import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'dart:io' if (dart.library.html) '../utils/io_stub.dart' show File;

class AudioService {
  final Record _recorder = Record();
  bool _isRecording = false;
  String? _currentPath;

  bool get isRecording => _isRecording;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<String?> startRecording() async {
    if (_isRecording) return null;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return null;

    if (!kIsWeb) {
      final dir = await getTemporaryDirectory();
      final filename = '${const Uuid().v4()}.wav';
      _currentPath = p.join(dir.path, filename);
    }

    await _recorder.start(
      path: kIsWeb ? null : _currentPath,
      encoder: AudioEncoder.wav,
      samplingRate: 16000,
      numChannels: 1,
      bitRate: 256000,
    );

    _isRecording = true;
    return _currentPath;
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    final path = await _recorder.stop();
    _isRecording = false;
    return path ?? _currentPath;
  }

  Future<void> cancelRecording() async {
    if (_isRecording) {
      await _recorder.stop();
      if (!kIsWeb && _currentPath != null) {
        final file = File(_currentPath!);
        if (await file.exists()) await file.delete();
      }
      _isRecording = false;
    }
  }

  void dispose() {
    _recorder.dispose();
  }
}
