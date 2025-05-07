import 'package:ecommerce_app/pages/commande_page.dart';
import 'package:ecommerce_app/pages/produit_page.dart';
import 'package:ecommerce_app/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_rounded, 'label': 'Accueil'},
    {'icon': Icons.shopping_cart, 'label': 'Produits'},
    {'icon': Icons.local_shipping, 'label': 'Commandes'},
    {'icon': Icons.person_outline, 'label': 'Profil'},
  ];

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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Youssef Kitabrhi",
                style: TextStyle(
                    color: Color(0xFF141414),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Text("Admin", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: const [
          Icon(Icons.search, color: Color(0xFF141414)),
          SizedBox(width: 12),
          Icon(Icons.notifications_none, color: Color(0xFF141414)),
          SizedBox(width: 12),
        ],
      ),
      body: _buildBody(),
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
        return CommandePage();
      case 3:
        return ProfilePage();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 24),
          const Text("Répartition des commandes",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF141414))),
          const SizedBox(height: 12),
          _buildPieChart(),
          const SizedBox(height: 30),
          const Text("Statistiques des produits",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF141414))),
          const SizedBox(height: 16),
          _statItem("Produit A", "300 Clients", 0.3, Icons.tune),
          _statItem("Produit B", "3149 Clients", 0.8, Icons.auto_graph),
          _statItem("Produit C", "4700 Clients", 1.0, Icons.check_circle_outline),
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

  Widget _buildPieChart() {
    final confirmed = 50.0;
    final cancelled = 20.0;
    final pending = 30.0;
    final total = confirmed + cancelled + pending;

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
                        title: '${(confirmed / total * 100).toInt()}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white),
                      ),
                      PieChartSectionData(
                        color: Colors.redAccent,
                        value: cancelled,
                        title: '${(cancelled / total * 100).toInt()}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white),
                      ),
                      PieChartSectionData(
                        color: Colors.orange,
                        value: pending,
                        title: '${(pending / total * 100).toInt()}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white),
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
                      Text("$total", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
