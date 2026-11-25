import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../api_config.dart';
import 'models/chatbot_message.dart';

class ChatbotService {
  static const String _baseUrl = ApiConfig.baseUrl;

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<ChatbotMessage>> fetchMessages() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user/chatbot/messages'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final data = body['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => ChatbotMessage.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    }

    throw Exception(_errorMessage(response, 'Gagal memuat riwayat chat.'));
  }

  Future<ChatbotMessage> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/user/chatbot/messages'),
      headers: await _headers(),
      body: json.encode({'message': message}),
    );

    final body = _decodeBody(response);

    if (response.statusCode == 200) {
      final data = body['data'];
      if (data is Map && data['assistant_message'] is Map) {
        return ChatbotMessage.fromJson(
          Map<String, dynamic>.from(data['assistant_message'] as Map),
        );
      }
      throw Exception('Format respons chatbot tidak valid.');
    }

    throw Exception(_errorMessage(response, 'Gagal mengirim pesan.'));
  }

  Future<void> clearMessages() async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/user/chatbot/messages'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Gagal menghapus riwayat chat.'));
    }
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    try {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return {};
  }

  String _errorMessage(http.Response response, String fallback) {
    final body = _decodeBody(response);
    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    return fallback;
  }
}
