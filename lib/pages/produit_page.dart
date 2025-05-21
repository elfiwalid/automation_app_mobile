import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProduitPage extends StatefulWidget {
  const ProduitPage({super.key});

  @override
  State<ProduitPage> createState() => _ProduitPageState();
}

class _ProduitPageState extends State<ProduitPage> {
  final List<Map<String, dynamic>> produits = [];
  bool loading = true;

  // contrôleurs
  final _codeController   = TextEditingController();
  final _nomController    = TextEditingController();
  final _descController   = TextEditingController();
  final _prixController   = TextEditingController();
  final _stockController  = TextEditingController();
  final _detailNomController    = TextEditingController();
  final _detailValeurController = TextEditingController();
  final List<Map<String,String>> _details = [];

  static const String baseUrl = "http://localhost:8080";

  @override
  void initState() {
    super.initState();
    _fetchProduits();
  }

  Future<Map<String,String>> _headers() async {
    final prefs  = await SharedPreferences.getInstance();
    final token  = prefs.getString("auth_token") ?? "";
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    };
  }

  /* -------------------- API -------------------- */

  Future<void> _fetchProduits() async {
    setState(() => loading = true);
    final res = await http.get(
      Uri.parse("$baseUrl/api/produits/me"),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      setState(() {
        produits
          ..clear()
          ..addAll(data.cast<Map<String,dynamic>>());
        loading = false;
      });
    } else {
      _snack("Erreur chargement : ${res.statusCode}");
      setState(() => loading = false);
    }
  }

  Future<void> _addProduit(Map<String,dynamic> p) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/produits"),
      headers: await _headers(),
      body: jsonEncode(p),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      setState(() => produits.add(jsonDecode(res.body)));
      _snack("Produit ajouté");
    } else {
      _snack("Erreur ajout : ${res.statusCode}");
    }
  }

  Future<void> _deleteProduit(int id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/api/produits/$id"),
      headers: await _headers(),
    );
    if (res.statusCode == 200 || res.statusCode == 204) {
      setState(() => produits.removeWhere((p) => p['id'] == id));
      _snack("Supprimé");
    } else {
      _snack("Erreur suppression : ${res.statusCode}");
    }
  }

  /* -------------------- UI -------------------- */

  @override
  void dispose() {
    _codeController.dispose();
    _nomController.dispose();
    _descController.dispose();
    _prixController.dispose();
    _stockController.dispose();
    _detailNomController.dispose();
    _detailValeurController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFFF),
      appBar: _buildAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductForm(context),
        backgroundColor: const Color(0xFFFF5A1A),
        icon: const Icon(Icons.add),
        label: const Text("Ajouter"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : produits.isEmpty
              ? const Center(
                  child: Text("Aucun produit ajouté.",
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: produits.length,
                  itemBuilder: (_, i) => _buildCard(produits[i]),
                ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 4,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: Color(0xFFFFEEE5),
            child: Icon(Icons.shopping_cart_outlined, color: Color(0xFFFF5A1A)),
          ),
        ),
        title: const Text("Gestion des Produits",
            style: TextStyle(
                color: Color(0xFF141414),
                fontWeight: FontWeight.w600,
                fontSize: 18)),
      );

  Widget _buildCard(Map<String,dynamic> p) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(p['nom'],
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF141414))),
              Row(children: [
                IconButton(
                    icon: const Icon(Icons.link, color: Colors.blueAccent),
                    onPressed: () {}), // TODO lien partage
                IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    onPressed: () => _deleteProduit(p['id'])),
              ])
            ]),
            const SizedBox(height: 6),
            Text(p['description'] ?? "", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: Text("Code : ${p['codeProduit']}")),
              Expanded(child: Text("Prix : ${p['prix']} MAD")),
              Expanded(child: Text("Stock : ${p['stock']}")),
            ]),
            const Divider(height: 28),
            const Text("Détails :",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: (p['details'] as List<dynamic>)
                  .map((d) => Chip(
                        label: Text("${d['nom']}: ${d['valeur']}"),
                        backgroundColor: const Color(0xFFFFEEE5),
                      ))
                  .toList(),
            )
          ]),
        ),
      );

  /* -------- Formulaire ajout -------- */

  void _showAddProductForm(BuildContext ctx) {
    _details.clear();
    _codeController.clear();
    _nomController.clear();
    _descController.clear();
    _prixController.clear();
    _stockController.clear();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(children: [
            const Text("Ajouter un Produit",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _input("Code produit", _codeController),
            _input("Nom", _nomController),
            _input("Description", _descController),
            _input("Prix", _prixController, type: TextInputType.number),
            _input("Stock", _stockController, type: TextInputType.number),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _input("Nom détail", _detailNomController)),
              const SizedBox(width: 8),
              Expanded(child: _input("Valeur", _detailValeurController)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFFFF5A1A)),
                onPressed: () {
                  if (_detailNomController.text.isNotEmpty &&
                      _detailValeurController.text.isNotEmpty) {
                    setState(() => _details.add({
                          'nom': _detailNomController.text,
                          'valeur': _detailValeurController.text
                        }));
                    _detailNomController.clear();
                    _detailValeurController.clear();
                  }
                },
              )
            ]),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _details
                  .map((d) => Chip(
                        label: Text("${d['nom']}: ${d['valeur']}"),
                        backgroundColor: const Color(0xFFFFEEE5),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text("Confirmer le produit",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5A1A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  final produitMap = {
                    'codeProduit': _codeController.text,
                    'nom': _nomController.text,
                    'description': _descController.text,
                    'prix': double.tryParse(_prixController.text) ?? 0,
                    'stock': int.tryParse(_stockController.text) ?? 0,
                    'details': List<Map<String,String>>.from(_details)
                  };
                  _addProduit(produitMap);
                  Navigator.pop(ctx);
                },
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c,
      {TextInputType type = TextInputType.text}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(
          controller: c,
          keyboardType: type,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      );

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
