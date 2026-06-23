import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../utils/constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  bool get isConnected => _channel != null;

  Future<bool> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(AppConstants.wsUrl));
      _channel!.stream.listen(
        (data) {
          final msg = jsonDecode(data as String) as Map<String, dynamic>;
          _messageController.add(msg);
        },
        onDone: () => _channel = null,
        onError: (_) => _channel = null,
      );
      // Connect to Word on WS init
      send('connect_word', {});
      return true;
    } catch (_) {
      return false;
    }
  }

  void send(String type, Map<String, dynamic> payload) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode({'type': type, 'payload': payload}));
  }

  void typeText(String text, {bool isUnicode = true}) {
    send('type_text', {'text': text, 'is_unicode': isUnicode});
  }

  void voiceCommand(String command) {
    send('voice_command', {'command': command});
  }

  void sendLiveTranscript(String text) {
    send('live_transcript', {'text': text});
  }

  void disconnect() {
    send('disconnect_word', {});
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
