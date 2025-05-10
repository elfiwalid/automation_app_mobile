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
  /* ───── CONFIG ───── */
  static const springUrl = 'http://192.168.1.39:8080';
  static const nodeUrl   = 'http://192.168.1.39:3000';

  bool _loading   = true;
  bool _connected = false;

  Timer? _statusPoll;                 // vérifie la connexion
  Timer? _qrPoll;                     // récupère le QR
  final ValueNotifier<Uint8List?> _qr = ValueNotifier(null); // ← nouveau

  /* ───── Helpers ───── */
  Future<Map<String,String>> _headers() async {
    final tok = (await SharedPreferences.getInstance())
        .getString('auth_token') ?? '';
    return {
      'Authorization':'Bearer $tok',
      'Content-Type' : 'application/json'
    };
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  /* ───── Statut connexion ───── */
  Future<void> _fetchStatus() async {
    try {
      final uri = Uri.parse(
        '$springUrl/api/whatsapp/status?ecommercant_id=${widget.ecommercantId}');
      final res = await http.get(uri, headers: await _headers())
                            .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        setState(() => _connected = d['connected'] ?? false);
      }
    } catch (_) {/* ignore */}
    finally { if (mounted) _loading = false; }
  }

  

  /* ───── Téléchargement du QR (base64) ───── */
  Future<Uint8List?> _tryGetQr() async {
    try {
      final res = await http
          .get(Uri.parse('$nodeUrl/whatsapp/qr/${widget.ecommercantId}'))
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200 && res.body.contains('base64,')) {
        final String? b64 = RegExp(r'base64,([^"]+)')
            .firstMatch(res.body)
            ?.group(1);
        if (b64 != null) return base64Decode(b64);
      }
    } catch (_) {/* network errors ignorés */}
    return null;
  }

  /* ───── Démarre le flux QR + polling statut ───── */
  Future<void> _connect() async {
    // 1) on demande la génération de QR
    try {
      await http.get(Uri.parse('$nodeUrl/connect/${widget.ecommercantId}'))
                .timeout(const Duration(seconds: 5));
    } catch (_) {
      _snack('Bridge Node injoignable');
      return;
    }

    // 2) dialog + ValueListenableBuilder
    _qr.value = null;
    _qrPoll?.cancel();
    _qrPoll = Timer.periodic(const Duration(seconds: 2), (t) async {
      final img = await _tryGetQr();
      if (img != null) {
        _qr.value = img;          // => rafraîchit automatiquement l’image
        t.cancel();               // stoppe le polling QR
      }
    });

    _statusPoll?.cancel();
    _statusPoll = Timer.periodic(const Duration(seconds: 3), (t) async {
      await _fetchStatus();
      if (_connected) {
        t.cancel();
        _qrPoll?.cancel();
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        _snack('WhatsApp connecté ✅');
      }
    });

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Scannez ce QR-Code'),
        content: SizedBox(
          width : 280,
          height: 300,
          child : ValueListenableBuilder<Uint8List?>(
            valueListenable: _qr,
            builder: (_, bytes, __) => bytes == null
                ? const Center(child: CircularProgressIndicator())
                : Image.memory(bytes, fit: BoxFit.contain),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _statusPoll?.cancel();
              _qrPoll?.cancel();
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'))
        ],
      ),
    );
  }

  /* ───── Déconnexion ───── */
  Future<void> _disconnect() async {
    try {
      final res = await http.delete(
        Uri.parse('$springUrl/api/whatsapp?ecommercant_id=${widget.ecommercantId}'),
        headers: await _headers()).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        _snack('Déconnecté ✔');
        setState(() => _connected = false);
      } else {
        _snack('Erreur : ${res.statusCode}');
      }
    } catch (_) { _snack('Erreur réseau'); }
  }

  /* ───── life-cycle ───── */
  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  @override
  void dispose() {
    _statusPoll?.cancel();
    _qrPoll?.cancel();
    _qr.dispose();
    super.dispose();
  }

  /* ───── UI ───── */
  @override
  Widget build(BuildContext context) => Scaffold(
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundColor:
                        _connected ? const Color(0xFFDCF8C6) : const Color(0xFFFFF3E0),
                    child: Icon(FontAwesomeIcons.whatsapp,
                        size : 54,
                        color: _connected ? const Color(0xFF25D366)
                                          : const Color(0xFFFF9800)),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _connected
                        ? 'Compte WhatsApp connecté ✅'
                        : 'Aucun compte WhatsApp connecté',
                    textAlign : TextAlign.center,
                    style     : const TextStyle(
                      fontSize : 20,
                      fontWeight: FontWeight.w600,
                      color    : Color(0xFF141414)),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon : Icon(
                        _connected ? Icons.link_off_rounded
                                   : Icons.qr_code_scanner_rounded,
                        size: 22),
                      label: Text(
                        _connected ? 'Déconnecter' : 'Scanner le QR-Code',
                        style: const TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _connected ? Colors.redAccent : const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape : RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _connected 
                      ? null 
                      : _connect,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Une seule connexion suffit : ensuite les messages, '
                    'commandes auto et réponses IA fonctionneront directement '
                    'avec l’application.',
                    textAlign: TextAlign.center,
                    style    : TextStyle(color: Colors.grey),
                  )
                ]),
              ),
      );
}
