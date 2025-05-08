import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_app/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String nom   = '';
  String role  = '';
  bool   charg = true;

  static const baseUrl = "http://192.168.1.39:8080";

  /* ---------------- Helpers ---------------- */

  Future<Map<String,String>> _headers() async {
    final token =
        (await SharedPreferences.getInstance()).getString("auth_token") ?? "";
    return {"Authorization": "Bearer $token", "Content-Type": "application/json"};
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  /* ---------------- API ---------------- */

  Future<void> _fetchMe() async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/auth/me"),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        nom   = data['username'] ?? '';
        role  = data['role']     ?? '';
        charg = false;
      });
    } else {
      _snack("Erreur profil : ${res.statusCode}");
      setState(() => charg = false);
    }
  }

  Future<void> _changePassword(String oldPwd, String newPwd) async {
    final body = jsonEncode({"oldPassword": oldPwd, "newPassword": newPwd});
    final res  = await http.put(
      Uri.parse("$baseUrl/api/auth/password"),
      headers: await _headers(),
      body: body,
    );
    if (res.statusCode == 200) {
      _snack("Mot de passe mis à jour ✔");
    } else {
      _snack("Échec : ${res.statusCode}");
    }
  }

  Future<void> _logout() async {
  (await SharedPreferences.getInstance()).remove("auth_token");

  if (!mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (route) => false,              // supprime toutes les anciennes pages
  );
}

  /* ---------------- UI ---------------- */

  @override
  void initState() {
    super.initState();
    _fetchMe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _appBar(),
      body: charg
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _header(),
                  const SizedBox(height: 30),
                  _profileOption(Icons.edit, "Modifier le profil", () {
                    _snack("À implémenter 🙂");
                  }),
                  _profileOption(Icons.lock_outline, "Changer le mot de passe",
                      _dialogChangePwd),
                  _profileOption(
                      Icons.help_center_outlined, "Centre d’aide", () {
                    _snack("À implémenter 🙂");
                  }),
                  _profileOption(Icons.logout, "Se déconnecter", _logout,
                      color: Colors.redAccent),
                ],
              ),
            ),
    );
  }

  /* -- Composants -- */

  PreferredSizeWidget _appBar() => AppBar(
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
              fontSize: 18),
        ),
      );

  Widget _header() => Column(
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFFFDEDE7),
            child: Icon(Icons.person, size: 50, color: Color(0xFFFA541C)),
          ),
          const SizedBox(height: 12),
          Text(nom,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF141414))),
          const SizedBox(height: 4),
          Text(role, style: const TextStyle(color: Colors.grey)),
        ],
      );

  Widget _profileOption(IconData icon, String title, VoidCallback onTap,
          {Color color = const Color(0xFF141414)}) =>
      InkWell(
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
                  offset: Offset(0, 3)),
            ],
          ),
          child: Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFFFF5F0),
              child: Icon(icon, color: const Color(0xFFFA541C)),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: color))),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.grey),
          ]),
        ),
      );

  /* -- Dialog change pwd -- */

  void _dialogChangePwd() {
    final oldC = TextEditingController();
    final newC = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Changer le mot de passe"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: oldC,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Ancien mot de passe"),
          ),
          TextField(
            controller: newC,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Nouveau mot de passe"),
          ),
        ]),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _changePassword(oldC.text.trim(), newC.text.trim());
            },
            child: const Text("Valider"),
          )
        ],
      ),
    );
  }
}
