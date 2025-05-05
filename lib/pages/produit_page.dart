import 'package:flutter/material.dart';

class ProduitPage extends StatefulWidget {
  const ProduitPage({super.key});

  @override
  State<ProduitPage> createState() => _ProduitPageState();
}

class _ProduitPageState extends State<ProduitPage> {
  final List<Map<String, dynamic>> _produits = [];

  void _ajouterProduit(Map<String, dynamic> nouveauProduit) {
    setState(() => _produits.add(nouveauProduit));
  }

  void _ouvrirFormulaireAjout() {
    final _formKey = GlobalKey<FormState>();
    final _data = {
      'code_produit': '',
      'nom': '',
      'description': '',
      'prix': '',
      'stock': '',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter un produit"),
        content: Form(
          key: _formKey,
          child: SizedBox(
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Code Produit"),
                    onSaved: (val) => _data['code_produit'] = val!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Nom"),
                    onSaved: (val) => _data['nom'] = val!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Description"),
                    onSaved: (val) => _data['description'] = val!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Prix"),
                    keyboardType: TextInputType.number,
                    onSaved: (val) => _data['prix'] = val!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Stock"),
                    keyboardType: TextInputType.number,
                    onSaved: (val) => _data['stock'] = val!,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Ajouter"),
            onPressed: () {
              _formKey.currentState?.save();
              _ajouterProduit(_data);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Produits"),
        backgroundColor: Colors.orange,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: _ouvrirFormulaireAjout,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _produits.length,
        itemBuilder: (context, index) {
          final p = _produits[index];
          return Card(
            child: ListTile(
              title: Text("${p['nom']} - ${p['prix']} MAD"),
              subtitle: Text("${p['description']}\nStock: ${p['stock']}"),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
