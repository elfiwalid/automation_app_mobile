import 'dart:convert';
import 'package:ecommerce_app/pages/whatsapp_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce_app/pages/commande_page.dart';
import 'package:ecommerce_app/pages/produit_page.dart';
import 'package:ecommerce_app/pages/profile_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  String _ecomId = '' ;    

  Map<String, dynamic> dashboardData = {};
  bool isLoading = true;

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_rounded, 'label': 'Accueil'},
    {'icon': Icons.shopping_cart, 'label': 'Produits'},
    {'icon': FontAwesomeIcons.whatsapp,    'label': 'WhatsApp'},
    {'icon': Icons.local_shipping, 'label': 'Commandes'},
    {'icon': Icons.person_outline, 'label': 'Profil'},
  ];

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

 Future<void> fetchDashboardData() async {
  setState(() => isLoading = true);

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("auth_token");

  if (token == null) {
    print("❌ Aucun token trouvé !");
    setState(() => isLoading = false);
    return;
  }

  print("🔑 Token : $token");

  try {
    final response = await http.get(
      Uri.parse("http://192.168.1.39:8080/api/dashboard/infos"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    print("📡 Status: ${response.statusCode}");
    print("📡 Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _ecomId = (data['ecommercant_id'] ?? '').toString();   // ⬅️  NOUVEAU
      setState(() {
        dashboardData = data;
        isLoading = false;
      });
    } else {
      print("❌ Erreur API: ${response.statusCode}");
      setState(() => isLoading = false);
    }
  } catch (e) {
    print("❌ Exception pendant l'appel API: $e");
    setState(() => isLoading = false);
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundImage: AssetImage("assets/logo.png"),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dashboardData['nom'] ?? 'Chargement...',
              style: const TextStyle(
                  color: Color(0xFF141414),
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.search, color: Color(0xFF141414)),
          SizedBox(width: 12),
          Icon(Icons.notifications_none, color: Color(0xFF141414)),
          SizedBox(width: 12),
        ],
      ),
      body: isLoading ? Center(child: CircularProgressIndicator()) : _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return ProduitPage();
      case 2:
        return WhatsAppPage(ecommercantId: _ecomId);
      case 3:
        return CommandePage();
      case 4:
        return ProfilePage();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDashboardContent() {
    final confirmed = dashboardData['commandes_validees'] ?? 0;
    final cancelled = dashboardData['commandes_annulees'] ?? 0;
    final pending = dashboardData['commandes_en_attente'] ?? 0;
    final total = confirmed + cancelled + pending;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 24),
          const Text("Répartition des commandes",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          _buildPieChart(confirmed.toDouble(), cancelled.toDouble(), pending.toDouble(), total.toDouble()),
          const SizedBox(height: 30),
          const Text("Clients par produit",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          _statItem("Clients contactés", "${dashboardData['clients_contactes'] ?? 0} personnes", 1.0, Icons.people),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: "Rechercher un produit...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPieChart(double confirmed, double cancelled, double pending, double total) {
  // Évite la division par zéro
  double pct(double v) => total == 0 ? 0 : (v / total * 100);

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
    ),
    child: Column(
      children: [
        SizedBox(
          height: 180,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  centerSpaceRadius: 45,
                  sectionsSpace: 2,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: confirmed,
                      title: '${pct(confirmed).toInt()}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.redAccent,
                      value: cancelled,
                      title: '${pct(cancelled).toInt()}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.orange,
                      value: pending,
                      title: '${pct(pending).toInt()}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                    ),
                  ],
                  centerSpaceColor: Colors.white,
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Total", style: TextStyle(color: Colors.grey)),
                    Text("$total",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _LegendItem(color: Colors.green, label: "Confirmés"),
            _LegendItem(color: Colors.redAccent, label: "Annulés"),
            _LegendItem(color: Colors.orange, label: "En attente"),
          ],
        )
      ],
    ),
  );
}


  Widget _statItem(String title, String subtitle, double progress, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFEEE5),
            radius: 24,
            child: Icon(icon, color: Color(0xFFFF5A1A)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFF5A1A)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          final bool isSelected = _currentIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _currentIndex = index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color.fromARGB(255, 255, 107, 48) : Colors.transparent,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    _navItems[index]['icon'],
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _navItems[index]['label'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? const Color.fromARGB(255, 255, 107, 48) : Colors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
