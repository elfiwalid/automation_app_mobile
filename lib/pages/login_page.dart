import 'dart:convert';
import 'package:ecommerce_app/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
  final username = usernameController.text.trim();
  final password = passwordController.text.trim();

  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Veuillez remplir tous les champs")),
    );
    return;
  }

  setState(() => isLoading = true);

  try {
    final response = await http.post(
      Uri.parse("http://192.168.1.39:8080/api/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "motDePasse": password,
      }),
    );

    if (response.statusCode == 200) {
      final token = response.body;
await SharedPreferences.getInstance().then((prefs) {
  prefs.setString("auth_token", token);
});

      

      // Appel à /me pour récupérer le rôle
      final meResponse = await http.get(
        Uri.parse("http://192.168.1.39:8080/api/auth/me"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (meResponse.statusCode == 200) {
        final userInfo = jsonDecode(meResponse.body);
        final role = userInfo['role'];

        if (role == "ECOMMERCANT") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        } else if (role == "ADMIN") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Accès réservé à l’administrateur. Interface en cours de développement."),
              backgroundColor: Colors.deepOrange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Rôle non reconnu : $role")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible de récupérer le rôle utilisateur")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de la connexion")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur : $e")),
    );
  } finally {
    setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF141414)),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const WelcomePage()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Image.asset('assets/logo.png', height: 150, fit: BoxFit.contain),
              ),
              const SizedBox(height: 30),
              const Text(
                'BIENVENUE !',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF141414),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: 'USERNAME OR EMAIL',
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'MOT DE PASSE',
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Mot de passe oublier ?',
                    style: TextStyle(fontSize: 13, color: Colors.black45),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 107, 48),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SE CONNECTER",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
