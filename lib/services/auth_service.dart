import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8080/api/auth'; // ↪️ Android Emulator
  final storage = const FlutterSecureStorage();

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": username,
        "motDePasse": password,
      }),
    );

    if (response.statusCode == 200) {
      await storage.write(key: 'jwt', value: response.body);
      return true;
    } else {
      return false;
    }
  }
}
