import 'dart:convert';
import 'api_client.dart';

class WhatsAppService {
  final ApiClient _api = ApiClient();

  /// Status : { "connected": true/false }
  Future<bool> isConnected() async {
    final res = await _api.get("/api/whatsapp/status");
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['connected'] ?? false;
    }
    throw Exception("Status WhatsApp : ${res.statusCode}");
  }

  /// Test message manuel (POST /api/test-whatsapp)
  Future<void> sendTestMessage({
    required int ecommercantId,
    required String phone,
    required String message,
  }) async {
    final res = await _api.post("/api/test-whatsapp", {
      "ecommercant_id": ecommercantId.toString(),
      "phone"         : phone,
      "message"       : message,
    });

    if (res.statusCode != 200) {
      throw Exception("Échec WhatsApp : ${res.statusCode}");
    }
  }
}
