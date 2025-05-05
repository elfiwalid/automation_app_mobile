import 'package:flutter/material.dart';

class CommandePage extends StatefulWidget {
  const CommandePage({super.key});

  @override
  State<CommandePage> createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage> {
  List<Map<String, String>> commandes = [
    {
      'nom_client': 'Youssef Elkhadiri',
      'adresse': 'Rue El Fath, Rabat',
      'ville': 'Rabat',
      'telephone': '0601020304',
      'mode_paiement': 'COD',
      'produit': 'T-shirt Bleu',
      'statut': 'validée',
    },
    {
      'nom_client': 'Walid Elfilali',
      'adresse': 'Oulfa hay salam',
      'ville': 'Casablanca',
      'telephone': '0762415571',
      'mode_paiement': 'rapide',
      'produit': 'T-shirt Bleu',
      'statut': 'en_attente',
    },
    {
      'nom_client': 'Youssef Kita',
      'adresse': 'rue flani 23bd',
      'ville': 'Berrechid',
      'telephone': '065445767',
      'mode_paiement': 'COD',
      'produit': 'T-shirt Bleu',
      'statut': 'en_attente',
    },
  ];

  void _changerStatut(int index, String nouveauStatut) {
    setState(() {
      commandes[index]['statut'] = nouveauStatut;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
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
            child: const Icon(Icons.local_shipping_outlined, color: Color(0xFFFF5A1A)),
          ),
        ),
        title: const Text(
          "Gestion des Commandes",
          style: TextStyle(
            color: Color(0xFF141414),
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Color(0xFF141414)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: commandes.length,
        itemBuilder: (context, index) =>
            _buildCommandeCard(commandes[index], index),
      ),
    );
  }

  Widget _buildCommandeCard(Map<String, String> commande, int index) {
    final statut = commande['statut']!;
    IconData icon;
    Color color;
    String label;

    switch (statut) {
      case 'validée':
        icon = Icons.check_circle;
        color = Colors.green;
        label = 'Confirmée';
        break;
      case 'annulee':
        icon = Icons.cancel;
        color = Colors.redAccent;
        label = 'Annulée';
        break;
      default:
        icon = Icons.hourglass_bottom;
        color = const Color(0xFFFF9800);
        label = 'En attente';
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color),
              ),
              title: Text(
                commande['nom_client']!,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF141414)),
              ),
              subtitle: Text(
                commande['telephone']!,
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                ),
              ),
            ),
            const Divider(),
            _commandeInfo("Produit", commande['produit']!),
            _commandeInfo("Adresse", commande['adresse']!),
            _commandeInfo("Ville", commande['ville']!),
            _commandeInfo("Mode de paiement", commande['mode_paiement']!),
            const SizedBox(height: 12),
            if (statut == 'en_attente')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text("Confirmer"),
                      onPressed: () => _changerStatut(index, 'validée'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.cancel),
                      label: const Text("Annuler"),
                      onPressed: () => _changerStatut(index, 'annulee'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _commandeInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            "$label : ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF141414),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
