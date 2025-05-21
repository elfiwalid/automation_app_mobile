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
  String _nom = '';
  String _role = '';
  bool _load = true;

  static const baseUrl = "http://localhost:8080";
  static const orange = Color(0xFFFF6B30);
  static const veryLightOrange = Color(0xFFFFF5F0);

  /* ---------- Helpers ---------- */

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

  /* ---------- API ---------- */

  Future<void> _fetchMe() async {
    final res =
        await http.get(Uri.parse("$baseUrl/api/auth/me"), headers: await _headers());
    if (!mounted) return;
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        _nom = data['username'] ?? '';
        _role = data['role'] ?? '';
        _load = false;
      });
    } else {
      _snack("Erreur profil : ${res.statusCode}");
      setState(() => _load = false);
    }
  }

  Future<void> _changePassword(String oldPwd, String newPwd) async {
    final res = await http.put(Uri.parse("$baseUrl/api/auth/password"),
        headers: await _headers(),
        body: jsonEncode({"oldPassword": oldPwd, "newPassword": newPwd}));
    _snack(res.statusCode == 200
        ? "Mot de passe mis à jour ✔"
        : "Échec : ${res.statusCode}");
  }

  Future<void> _updateProfile(Map<String, String> body) async {
    final res = await http.put(Uri.parse("$baseUrl/api/auth/profile"),
        headers: await _headers(), body: jsonEncode(body));
    if (res.statusCode == 200) {
      _snack("Profil mis à jour ✔");
      _fetchMe();
    } else {
      _snack("Erreur : ${res.statusCode}");
    }
  }

  Future<void> _logout() async {
    (await SharedPreferences.getInstance()).remove("auth_token");
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  /* ---------- Lifecycle ---------- */

  @override
  void initState() {
    super.initState();
    _fetchMe();
  }

  /* ---------- UI ---------- */

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: _appBar(),
        body: _load
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  _header(),
                  const SizedBox(height: 30),
                  _option(Icons.edit, "Modifier le profil", _editProfileSheet),
                  _option(
                      Icons.lock_outline, "Changer le mot de passe", _changePwdSheet),
                  _option(Icons.help_center_outlined, "Centre d’aide",
                      () => _snack("À implémenter 🙂")),
                  _option(Icons.logout, "Se déconnecter", _logout,
                      color: Colors.redAccent),
                ]),
              ),
      );

  /* ---------- Widgets ---------- */

  PreferredSizeWidget _appBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: veryLightOrange,
            child: Icon(Icons.person_outline, color: orange),
          ),
        ),
        title: const Text("Mon Profil",
            style: TextStyle(
                color: Color(0xFF141414),
                fontWeight: FontWeight.w600,
                fontSize: 18)),
      );

  Widget _header() => Column(children: [
        const CircleAvatar(
          radius: 48,
          backgroundColor: veryLightOrange,
          child: Icon(Icons.person, size: 50, color: orange),
        ),
        const SizedBox(height: 12),
        Text(_nom,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF141414))),
        const SizedBox(height: 4),
        Text(_role, style: const TextStyle(color: Colors.grey)),
      ]);

  Widget _option(IconData icon, String titre, VoidCallback onTap,
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
              BoxShadow(color: Color.fromARGB(28, 0, 0, 0), blurRadius: 6)
            ],
          ),
          child: Row(children: [
            CircleAvatar(
                radius: 22,
                backgroundColor: veryLightOrange,
                child: Icon(icon, color: orange)),
            const SizedBox(width: 14),
            Expanded(
                child: Text(titre,
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: color))),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.grey),
          ]),
        ),
      );

  /* ---------- Bottom-sheets stylés ---------- */

  Widget _sheetWrapper({required Widget child, String? title}) => Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF141414))),
              ),
            child
          ]),
        ),
      );

  InputDecoration _fieldDeco(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF6F7F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  ElevatedButton _cta(String txt, VoidCallback cb) => ElevatedButton(
        onPressed: cb,
        style: ElevatedButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        child:
            Text(txt, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  /* ----- Change password sheet ----- */
  void _changePwdSheet() {
    final oldC = TextEditingController();
    final newC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _sheetWrapper(
        title: "Changer le mot de passe",
        child: Column(children: [
          TextField(
              controller: oldC,
              obscureText: true,
              decoration: _fieldDeco("Ancien mot de passe")),
          const SizedBox(height: 14),
          TextField(
              controller: newC,
              obscureText: true,
              decoration: _fieldDeco("Nouveau mot de passe")),
          const SizedBox(height: 20),
          _cta("Valider", () {
            if (oldC.text.isEmpty || newC.text.length < 6) {
              _snack("6 caractères minimum");
              return;
            }
            Navigator.of(context).pop();
            _changePassword(oldC.text.trim(), newC.text.trim());
          }),
        ]),
      ),
    );
  }

  /* ----- Edit profile sheet ----- */
  void _editProfileSheet() {
    final nomC = TextEditingController(text: _nom);
    final emailC = TextEditingController();
    final waC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _sheetWrapper(
        title: "Modifier mon profil",
        child: Column(children: [
          TextField(controller: nomC, decoration: _fieldDeco("Nom")),
          const SizedBox(height: 14),
          TextField(controller: emailC, decoration: _fieldDeco("Email")),
          const SizedBox(height: 14),
          TextField(
              controller: waC, decoration: _fieldDeco("N° WhatsApp")),
          const SizedBox(height: 20),
          _cta("Enregistrer", () {
            final body = <String, String>{};
            if (nomC.text.trim().isNotEmpty) body['nom'] = nomC.text.trim();
            if (emailC.text.trim().isNotEmpty) {
              body['email'] = emailC.text.trim();
            }
            if (waC.text.trim().isNotEmpty) {
              body['numeroWhatsApp'] = waC.text.trim();
            }
            if (body.isEmpty) {
              _snack("Aucun changement");
              return;
            }
            Navigator.of(context).pop();
            _updateProfile(body);
          }),
        ]),
      ),
    );
  }
}
