import 'package:flutter/material.dart';

class ProduitPage extends StatefulWidget {
  const ProduitPage({super.key});

  @override
  State<ProduitPage> createState() => _ProduitPageState();
}

class _ProduitPageState extends State<ProduitPage> {
  final List<Map<String, dynamic>> produits = [];

  // Champs
  final _codeController = TextEditingController();
  final _nomController = TextEditingController();
  final _descController = TextEditingController();
  final _prixController = TextEditingController();
  final _stockController = TextEditingController();
  final _detailNomController = TextEditingController();
  final _detailValeurController = TextEditingController();
  final List<Map<String, String>> _details = [];

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
      backgroundColor: const Color.fromARGB(255, 254, 255, 255),
      appBar: AppBar(
  backgroundColor: Colors.white.withOpacity(0.9),
  elevation: 4,
  centerTitle: true,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
  ),
  leading: Padding(
    padding: const EdgeInsets.only(left: 12),
    child: CircleAvatar(
      backgroundColor: const Color(0xFFFFEEE5),
      child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFFFF5A1A)),
    ),
  ),
  title: const Text(
    "Gestion des Produits",
    style: TextStyle(
      color: Color(0xFF141414),
      fontWeight: FontWeight.w600,
      fontSize: 18,
      letterSpacing: 0.5,
    ),
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.filter_list, color: Color(0xFF141414)),
      onPressed: () {
        // Action de filtre
      },
    ),
    const SizedBox(width: 8),
  ],
),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductForm(context),
        backgroundColor: const Color(0xFFFF5A1A),
        icon: const Icon(Icons.add),
        label: const Text("Ajouter"),
      ),
      body: produits.isEmpty
          ? const Center(
              child: Text(
                "Aucun produit ajouté.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: produits.length,
              itemBuilder: (context, index) {
                final produit = produits[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(produit['nom'],
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF141414))),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.link, color: Colors.blueAccent),
                                  tooltip: "Générer un lien",
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Lien généré")),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.grey),
                                  tooltip: "Modifier",
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  tooltip: "Supprimer",
                                  onPressed: () {
                                    setState(() {
                                      produits.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(produit['description'], style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: Text("Code : ${produit['code']}")),
                            Expanded(child: Text("Prix : ${produit['prix']} MAD")),
                            Expanded(child: Text("Stock : ${produit['stock']}")),
                          ],
                        ),
                        const Divider(height: 28),
                        const Text("Détails :",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: List.generate(produit['details'].length, (i) {
                            final detail = produit['details'][i];
                            return Chip(
                              label: Text("${detail['nom']}: ${detail['valeur']}"),
                              backgroundColor: const Color(0xFFFFEEE5),
                              labelStyle: const TextStyle(color: Color(0xFF141414)),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddProductForm(BuildContext context) {
    _details.clear();
    _codeController.clear();
    _nomController.clear();
    _descController.clear();
    _prixController.clear();
    _stockController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text("Ajouter un Produit",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold )),
                const SizedBox(height: 20),
                _buildInput("Code produit", _codeController),
                _buildInput("Nom", _nomController),
                _buildInput("Description", _descController),
                _buildInput("Prix", _prixController,
                    keyboardType: TextInputType.number),
                _buildInput("Stock", _stockController,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildInput("Nom détail", _detailNomController)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInput("Valeur", _detailValeurController)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFFFF5A1A)),
                      onPressed: () {
                        if (_detailNomController.text.isNotEmpty &&
                            _detailValeurController.text.isNotEmpty) {
                          setState(() {
                            _details.add({
                              'nom': _detailNomController.text,
                              'valeur': _detailValeurController.text
                            });
                          });
                          _detailNomController.clear();
                          _detailValeurController.clear();
                        }
                      },
                    )
                  ],
                ),
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
                    icon: const Icon(Icons.check,color : Colors.white),
                    label: const Text("Confirmer le produit", style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      setState(() {
                        produits.add({
                          'code': _codeController.text,
                          'nom': _nomController.text,
                          'description': _descController.text,
                          'prix': _prixController.text,
                          'stock': _stockController.text,
                          'details': List<Map<String, String>>.from(_details)
                        });
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5A1A),
                      iconColor: Color.fromARGB(255, 255, 255, 255),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInput(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
