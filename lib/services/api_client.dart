import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = "http://192.168.1.39:8080";

  /* -------- entête avec Bearer -------- */
  Future<Map<String,String>> _headers() async {
    final token =
        (await SharedPreferences.getInstance()).getString("auth_token") ?? "";
    return {"Authorization": "Bearer $token", "Content-Type": "application/json"};
  }

  /* -------- wrappers -------- */
  Future<http.Response> get(String path) async =>
      http.get(Uri.parse("$baseUrl$path"), headers: await _headers());

  Future<http.Response> post(String path, Map<String, dynamic> body) async =>
      http.post(Uri.parse("$baseUrl$path"),
          headers: await _headers(), body: jsonEncode(body));

  Future<http.Response> put(String path, Map<String, dynamic> body) async =>
      http.put(Uri.parse("$baseUrl$path"),
          headers: await _headers(), body: jsonEncode(body));
}
