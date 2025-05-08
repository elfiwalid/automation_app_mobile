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
  final List<Map<String, dynamic>> _commandes = [];
  final TextEditingController _search = TextEditingController();

  bool _loading = true;

  static const String baseUrl = "http://192.168.1.39:8080";

  /* ---------------- Helpers ---------------- */

  Future<Map<String, String>> _headers() async {
    final token =
        (await SharedPreferences.getInstance()).getString("auth_token") ?? "";
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    };
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  String _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp(r'[_\s]+'), '')
      .trim();

  /* ---------------- API ---------------- */

  Future<void> _fetchCommandes() async {
    final now = DateTime.now();
    debugPrint(">>> fetch commandes @ $now");
    setState(() => _loading = true);

    final res = await http.get(
      Uri.parse("$baseUrl/api/commandes/me"),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      setState(() {
        _commandes
          ..clear()
          ..addAll(jsonDecode(res.body).cast<Map<String, dynamic>>());
        _loading = false;
      });
    } else {
      _snack("Erreur chargement : ${res.statusCode}");
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatut(int id, String newStatut) async {
  final uri = Uri.parse("$baseUrl/api/commandes/$id/statut?statut=$newStatut");
  final res = await http.put(uri, headers: await _headers());

  if (res.statusCode == 200) {
    setState(() {
      final idx = _commandes.indexWhere((c) => c['id'] == id);
      if (idx != -1) _commandes[idx]['statut'] = newStatut;  // ⬅️ maj locale
    });
    _snack("Statut mis à jour");
  } else {
    _snack("Erreur statut : ${res.statusCode}");
  }
}


  /* ---------------- Lifecycle ---------------- */

  @override
  void initState() {
    super.initState();
    _fetchCommandes();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _fetchCommandes,
                      child: _buildList(),
                    ),
            ),
          ],
        ),
      );

  /* -- AppBar -- */

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
        actions: [
          IconButton(
              onPressed: _fetchCommandes,
              icon: const Icon(Icons.refresh, color: Color(0xFF141414)))
        ],
      );

  /* -- Search -- */

  Widget _buildSearchBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        child: TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: "Rechercher (client, produit, ville…) ",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
        ),
      );

  /* -- List -- */

  Widget _buildList() {
    final query = _search.text.trim().toLowerCase();
    final data = query.isEmpty
        ? _commandes
        : _commandes.where((c) {
            bool inside(String? v) =>
                v != null && v.toLowerCase().contains(query);
            return inside(c['nomClient']) ||
                inside(c['telephone']) ||
                inside(c['ville']) ||
                inside(c['adresse']) ||
                inside(c['produit']?['nom']);
          }).toList();

    if (data.isEmpty) {
      return const Center(
          child: Text("Aucun résultat",
              style: TextStyle(color: Colors.grey, fontSize: 16)));
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: data.length,
      itemBuilder: (_, i) => _buildCard(data[i]),
    );
  }

  /* -- Card -- */

  Widget _buildCard(Map<String, dynamic> c) {
    final status = _normalize(c['statut'] ?? '');

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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          if (status == 'enattente')
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

  Widget _info(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Text("$label : ",
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Color(0xFF141414))),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ]),
      );
}
