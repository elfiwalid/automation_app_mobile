import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommandePage extends StatefulWidget {
  const CommandePage({super.key});

  @override
  State<CommandePage> createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage> {
  final List<Map<String, dynamic>> commandes = [];
  bool loading = true;

  static const String baseUrl = "http://192.168.1.39:8080";

  @override
  void initState() {
    super.initState();
    _fetchCommandes();
  }

  /* ---------------- Helpers ---------------- */

  Future<Map<String, String>> _headers() async {
    final token =
        (await SharedPreferences.getInstance()).getString("auth_token") ?? "";
    return {"Authorization": "Bearer $token", "Content-Type": "application/json"};
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  String _normalize(String s) =>
      s.toLowerCase().replaceAll('é', 'e').replaceAll('è', 'e').trim();

  /* ---------------- API ---------------- */

  Future<void> _fetchCommandes() async {
    setState(() => loading = true);
    final res = await http.get(
      Uri.parse("$baseUrl/api/commandes/me"),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      setState(() {
        commandes
          ..clear()
          ..addAll(jsonDecode(res.body).cast<Map<String, dynamic>>());
        loading = false;
      });
    } else {
      _snack("Erreur chargement : ${res.statusCode}");
      setState(() => loading = false);
    }
  }

  Future<void> _updateStatut(int id, String statut) async {
    final res = await http.put(
      Uri.parse("$baseUrl/api/commandes/$id/statut?statut=$statut"),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      _snack("Statut mis à jour");
      await _fetchCommandes(); // relecture immédiate
    } else {
      _snack("Erreur statut : ${res.statusCode}");
    }
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: _buildAppBar(),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: commandes.length,
                itemBuilder: (_, i) => _buildCard(commandes[i]),
              ),
      );

  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 4,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: Color(0xFFFFEEE5),
            child:
                Icon(Icons.local_shipping_outlined, color: Color(0xFFFF5A1A)),
          ),
        ),
        title: const Text("Gestion des Commandes",
            style: TextStyle(
                color: Color(0xFF141414),
                fontWeight: FontWeight.w600,
                fontSize: 18)),
      );

  Widget _buildCard(Map<String, dynamic> c) {
    final raw = (c['statut'] ?? '').toString();
    final status = _normalize(raw);

    IconData icon;
    Color color;
    String badge;

    switch (status) {
      case 'validee':
        icon = Icons.check_circle;
        color = const Color(0xFF4CAF50);
        badge = 'Confirmée';
        break;
      case 'annulee':
        icon = Icons.cancel;
        color = const Color(0xFFE53935);
        badge = 'Annulée';
        break;
      default:
        icon = Icons.hourglass_bottom;
        color = const Color(0xFFFF9800);
        badge = 'En attente';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color),
            ),
            title: Text(c['nomClient'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(c['telephone']),
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14)),
              child: Text(badge,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ),
          ),
          const Divider(height: 20),
          _info("Produit", c['produit']?['nom'] ?? '-'),
          _info("Adresse", c['adresse']),
          _info("Ville", c['ville']),
          _info("Mode de paiement", c['modePaiement'] ?? ''),
          const SizedBox(height: 14),
          if (status == 'en_attente')
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatut(c['id'], 'validée'),
                  icon: const Icon(Icons.check),
                  label: const Text("Confirmer"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatut(c['id'], 'annulée'),
                  icon: const Icon(Icons.cancel),
                  label: const Text("Annuler"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ])
        ]),
      ),
    );
  }

  Widget _info(String l, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Text("$l : ",
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Color(0xFF141414))),
          Expanded(child: Text(v, style: const TextStyle(color: Colors.black87)))
        ]),
      );
}
