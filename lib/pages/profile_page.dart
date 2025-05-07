import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: Color(0xFFFDEDE7),
            child: Icon(Icons.person_outline, color: Color(0xFFFA541C)),
          ),
        ),
        title: const Text(
          "Mon Profil",
          style: TextStyle(
            color: Color(0xFF141414),
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ Header
            Column(
              children: const [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xFFFDEDE7),
                  child: Icon(Icons.person, size: 50, color: Color(0xFFFA541C)),
                ),
                SizedBox(height: 12),
                Text(
                  "Youssef Kitabrhi",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF141414),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Admin",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ✅ Options stylisées
            _profileOption(Icons.edit, "Modifier le profil", () {}),
            _profileOption(Icons.lock_outline, "Changer le mot de passe", () {}),
            _profileOption(Icons.help_center_outlined, "Centre d’aide", () {}),
            _profileOption(Icons.logout, "Se déconnecter", () {},
                color: Colors.redAccent),
          ],
        ),
      ),
    );
  }

  Widget _profileOption(IconData icon, String title, VoidCallback onTap,
      {Color color = const Color(0xFF141414)}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(30, 0, 0, 0),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFFFF5F0),
              child: Icon(icon, color: const Color(0xFFFA541C)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
