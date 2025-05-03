import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
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
            Text("Admin",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: const [
          Icon(Icons.search, color: Color(0xFF141414)),
          SizedBox(width: 12),
          Icon(Icons.notifications_none, color: Color(0xFF141414)),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchBar(),
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
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
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
    final int confirmed = 50;
    final int cancelled = 20;
    final int pending = 30;
    final int total = confirmed + cancelled + pending;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5),
        ],
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
                        value: confirmed.toDouble(),
                        title: '${((confirmed / total) * 100).toInt()}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      PieChartSectionData(
                        color: Colors.redAccent,
                        value: cancelled.toDouble(),
                        title: '${((cancelled / total) * 100).toInt()}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      PieChartSectionData(
                        color: Colors.orange,
                        value: pending.toDouble(),
                        title: '${((pending / total) * 100).toInt()}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                    centerSpaceColor: Colors.white,
                    pieTouchData: PieTouchData(enabled: false),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Total",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey)),
                      Text("$total",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
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
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
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

  Widget _bottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFFFF5A1A),
        unselectedItemColor: Colors.grey[400],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
        ],
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
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
