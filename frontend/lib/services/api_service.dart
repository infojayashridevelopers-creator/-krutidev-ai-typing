import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';
import '../utils/constants.dart';

class ApiService {
  static String? _token;

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<void> loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('server_url') ?? '';
    if (url.isNotEmpty) AppConstants.setServerUrl(url);
  }

  static Future<void> saveServerUrl(String url) async {
    AppConstants.setServerUrl(url);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', url);
  }

  static bool get isLoggedIn => _token != null;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // Auth
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await saveToken(data['token']);
    }
    return data;
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 201) {
      await saveToken(data['token']);
    }
    return data;
  }

  // Audio upload — on web, filePath is a blob URL returned by the recorder
  static Future<String?> uploadAudio(String filePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.baseUrl}/api/upload/audio'),
    );
    request.headers['Authorization'] = 'Bearer $_token';

    if (kIsWeb) {
      // Fetch blob URL bytes (works in browser context via XHR)
      final blobRes = await http.get(Uri.parse(filePath));
      request.files.add(http.MultipartFile.fromBytes(
        'audio',
        blobRes.bodyBytes,
        filename: 'recording.webm',
      ));
    } else {
      request.files.add(await http.MultipartFile.fromPath('audio', filePath));
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final data = jsonDecode(body);

    if (response.statusCode == 200) {
      return data['file_path'] as String;
    }
    return null;
  }

  // Speech to text — lang: 'hi' (Hindi) or 'mr' (Marathi)
  static Future<Map<String, dynamic>> speechToText(
      String filePath, String lang) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/speech-to-text'),
      headers: _headers,
      body: jsonEncode({'file_path': filePath, 'language': lang}),
    );
    return jsonDecode(res.body);
  }

  // Convert Unicode Devanagari to Kruti Dev (works for both Hindi and Marathi)
  static Future<Map<String, dynamic>> convertToKruti(
      String text, String lang) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/unicode/convert'),
      headers: _headers,
      body: jsonEncode({'text': text, 'language': lang}),
    );
    return jsonDecode(res.body);
  }

  // Word operations
  static Future<bool> newWordDocument() async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/word/new'),
      headers: _headers,
    );
    return res.statusCode == 200;
  }

  static Future<bool> typeInWord(String text,
      {bool isUnicode = true, WordSettings? settings}) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/word/type'),
      headers: _headers,
      body: jsonEncode({
        'text': text,
        'is_unicode': isUnicode,
        'apply_formatting': settings != null,
        if (settings != null) 'settings': settings.toJson(),
      }),
    );
    return res.statusCode == 200;
  }

  static Future<bool> applyWordSettings(WordSettings settings) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/word/settings'),
      headers: _headers,
      body: jsonEncode(settings.toJson()),
    );
    return res.statusCode == 200;
  }

  static Future<bool> voiceCommand(String command) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/word/command'),
      headers: _headers,
      body: jsonEncode({'command': command}),
    );
    return res.statusCode == 200;
  }

  static Future<String?> saveDocument(String fileName) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/document/save'),
      headers: _headers,
      body: jsonEncode({'file_name': fileName}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['path'] as String;
    }
    return null;
  }

  static Future<String?> exportPDF(String fileName) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/document/export'),
      headers: _headers,
      body: jsonEncode({'file_name': fileName}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['path'] as String;
    }
    return null;
  }

  // Generate .docx file with Kruti Dev 010 font — returns raw bytes
  static Future<List<int>?> generateDocx(String krutiText) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/document/generate'),
      headers: _headers,
      body: jsonEncode({'text': krutiText}),
    );
    if (res.statusCode == 200) return res.bodyBytes.toList();
    return null;
  }

  // Templates
  static Future<List<DocumentTemplate>> getTemplates() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/api/documents'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final list = data['templates'] as List? ?? [];
      return list.map((e) => DocumentTemplate.fromJson(e)).toList();
    }
    return [];
  }

}
