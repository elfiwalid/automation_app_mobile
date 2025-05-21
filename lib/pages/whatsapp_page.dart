// lib/pages/whatsapp_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WhatsAppPage extends StatefulWidget {
  final String ecommercantId;
  const WhatsAppPage({super.key, required this.ecommercantId});

  @override
  State<WhatsAppPage> createState() => _WhatsAppPageState();
}

class _WhatsAppPageState extends State<WhatsAppPage> {
  // URL de ton bridge NodeJS
  static const nodeUrl = 'http://localhost:3000';

  bool _loading = true;
  bool _connected = false;

  Timer? _pollStatus;
  Timer? _pollQr;
  final ValueNotifier<Uint8List?> _qr = ValueNotifier(null);

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final tok = prefs.getString('auth_token') ?? '';
    return {
      'Authorization': 'Bearer $tok',
      'Content-Type': 'application/json',
    };
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  /// Récupère `{ connected: true|false }`
  Future<void> _refreshStatus() async {
    setState(() => _loading = true);
    try {
      final res = await http
          .get(Uri.parse('$nodeUrl/whatsapp/connected/${widget.ecommercantId}'),
              headers: await _headers())
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final ok = (jsonDecode(res.body)['connected'] ?? false) as bool;
        setState(() => _connected = ok);
      } else {
        _snack('Statut erreur : ${res.statusCode}');
      }
    } catch (_) {
      _snack('Bridge Node injoignable');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Télécharge le QR base64 depuis `/whatsapp/qr/:id`
  Future<Uint8List?> _tryGetQr() async {
    try {
      final res = await http
          .get(Uri.parse('$nodeUrl/whatsapp/qr/${widget.ecommercantId}'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200 && res.body.contains('base64,')) {
        final b64 = RegExp(r'base64,([^"]+)')
            .firstMatch(res.body)
            ?.group(1);
        if (b64 != null) return base64Decode(b64);
      }
    } catch (_) {}
    return null;
  }

  /// Lance la génération du QR puis affiche le dialog de scan
  Future<void> _connect() async {
    // 1) Génération du QR
    try {
      await http
          .get(Uri.parse('$nodeUrl/connect/${widget.ecommercantId}'))
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      _snack('Bridge Node injoignable');
      return;
    }

    // 2) Polling du QR
    _qr.value = null;
    _pollQr?.cancel();
    _pollQr = Timer.periodic(const Duration(seconds: 2), (t) async {
      final img = await _tryGetQr();
      if (img != null) {
        _qr.value = img;
        t.cancel();
      }
    });

    // 3) Polling du statut
    _pollStatus?.cancel();
    _pollStatus = Timer.periodic(const Duration(seconds: 3), (t) async {
      await _refreshStatus();
      if (_connected) {
        t.cancel();
        _pollQr?.cancel();
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        _snack('WhatsApp connecté ✅');
      }
    });

    // 4) Affiche le dialog
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Scannez le QR-Code WhatsApp'),
        content: SizedBox(
          width: 280,
          height: 300,
          child: ValueListenableBuilder<Uint8List?>(
            valueListenable: _qr,
            builder: (_, bytes, __) => bytes == null
                ? const Center(child: CircularProgressIndicator())
                : Image.memory(bytes, fit: BoxFit.contain),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _pollQr?.cancel();
              _pollStatus?.cancel();
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  /// Déconnecte la session Baileys côté NodeJS
  Future<void> _disconnect() async {
    try {
      final res = await http
          .delete(
            Uri.parse('$nodeUrl/whatsapp/${widget.ecommercantId}'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        _snack('WhatsApp déconnecté ✔');
        setState(() => _connected = false);
      } else {
        _snack('Erreur déconnexion : ${res.statusCode}');
      }
    } catch (e) {
      _snack('Erreur réseau : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  @override
  void dispose() {
    _pollQr?.cancel();
    _pollStatus?.cancel();
    _qr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
        title: const Text('Intégrer WhatsApp',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircleAvatar(
                  radius: 64,
                  backgroundColor:
                      _connected ? const Color(0xFFDCF8C6) : const Color(0xFFFFF3E0),
                  child: Icon(
                    FontAwesomeIcons.whatsapp,
                    size: 54,
                    color:
                        _connected ? const Color(0xFF25D366) : const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  _connected
                      ? 'Compte WhatsApp connecté ✅'
                      : 'Aucun compte WhatsApp connecté',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF141414)),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(
                      _connected
                          ? Icons.link_off_rounded
                          : Icons.qr_code_scanner_rounded,
                      size: 22,
                    ),
                    label: Text(
                      _connected ? 'Déconnecter' : 'Scanner le QR-Code',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _connected ? Colors.redAccent : const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _connected ? _disconnect : _connect,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Une seule connexion suffit : ensuite les messages, '
                  'commandes auto et réponses IA fonctionneront directement '
                  'avec l’application.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                )
              ]),
            ),
    );
  }
}
