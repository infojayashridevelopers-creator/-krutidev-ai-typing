import 'package:flutter/foundation.dart';

class AppConstants {
  static String _customServerUrl = '';

  static void setServerUrl(String url) {
    _customServerUrl = url.trim().replaceAll(RegExp(r'/$'), '');
  }

  static String get serverUrl => _customServerUrl.isNotEmpty
      ? _customServerUrl
      : 'http://localhost:8080';

  // On web, use same origin as the page (works when phone opens http://<PC_IP>:8080)
  // On native desktop/mobile app, use the saved server URL or fall back to localhost
  static String get baseUrl {
    if (kIsWeb) return Uri.base.origin;
    return serverUrl;
  }

  static String get wsUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      return '${origin.replaceFirst('http', 'ws')}/ws';
    }
    return '${serverUrl.replaceFirst('http', 'ws')}/ws';
  }

  static const String appName = 'Kruti Dev AI Typing';
  static const String appVersion = '1.0.0';

  static const List<Map<String, String>> languages = [
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिंदी'},
    {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी'},
  ];

  static const Map<String, List<Map<String, String>>> voiceCommandsByLang = {
    'hi': [
      {'speak': 'एंटर', 'action': 'Enter'},
      {'speak': 'नया पैराग्राफ', 'action': 'New Paragraph'},
      {'speak': 'बोल्ड ऑन', 'action': 'Bold On'},
      {'speak': 'बोल्ड ऑफ', 'action': 'Bold Off'},
      {'speak': 'इटैलिक ऑन', 'action': 'Italic On'},
      {'speak': 'इटैलिक ऑफ', 'action': 'Italic Off'},
      {'speak': 'अंडरलाइन', 'action': 'Underline On'},
      {'speak': 'अंडरलाइन ऑफ', 'action': 'Underline Off'},
      {'speak': 'डॉक्यूमेंट सेव', 'action': 'Save Document'},
      {'speak': 'पीडीएफ बनाओ', 'action': 'Export PDF'},
      {'speak': 'स्पेस', 'action': 'Space'},
      {'speak': 'पूर्ण विराम', 'action': 'Full Stop (।)'},
      {'speak': 'अल्प विराम', 'action': 'Comma (,)'},
    ],
    'mr': [
      {'speak': 'एंटर द्या', 'action': 'Enter'},
      {'speak': 'नवा परिच्छेद', 'action': 'New Paragraph'},
      {'speak': 'ठळक चालू', 'action': 'Bold On'},
      {'speak': 'ठळक बंद', 'action': 'Bold Off'},
      {'speak': 'तिरपे चालू', 'action': 'Italic On'},
      {'speak': 'तिरपे बंद', 'action': 'Italic Off'},
      {'speak': 'अधोरेखित', 'action': 'Underline On'},
      {'speak': 'अधोरेखित बंद', 'action': 'Underline Off'},
      {'speak': 'दस्तऐवज जतन करा', 'action': 'Save Document'},
      {'speak': 'पीडीएफ करा', 'action': 'Export PDF'},
      {'speak': 'रिकामी जागा', 'action': 'Space'},
      {'speak': 'पूर्णविराम', 'action': 'Full Stop (।)'},
      {'speak': 'स्वल्पविराम', 'action': 'Comma (,)'},
    ],
  };

  static List<Map<String, String>> voiceCommandsFor(String langCode) {
    return voiceCommandsByLang[langCode] ?? voiceCommandsByLang['hi']!;
  }
}
