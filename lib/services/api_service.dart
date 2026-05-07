import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Gunakan 10.0.2.2 untuk Emulator Android, atau IP Laptop untuk HP asli
  static const String baseUrl = "http://192.168.100.6:8000/api";

  // Fungsi Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {'Accept': 'application/json'},
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Simpan token ke memori HP
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      return data;
    } else {
      throw Exception('Login Gagal: ${response.body}');
    }
  }

  // Fungsi ambil data gunung (Contoh route: /user/gunungs)
  Future<List<dynamic>> getGunungs() async {
    final response = await http.get(
      Uri.parse("$baseUrl/user/gunungs"),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal ambil data gunung');
    }
  }

  // Tambahkan di dalam ApiService
  Future<Map<String, String>> getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token', // Ini kunci utamanya!
    };
  }

  // Contoh mengambil profile user
  Future<Map<String, dynamic>> getProfile() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/user/profile"),
      headers: headers,
    );
    return json.decode(response.body);
  }
}
