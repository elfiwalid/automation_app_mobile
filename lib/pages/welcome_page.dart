import 'package:ecommerce_app/pages/login_page.dart';
import 'package:ecommerce_app/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // 🔶 Logo
              Center(
                child: Image.asset(
                  'assets/connecte.png',
                  height: 240,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),

              // 🔶 Texte de présentation
              const Text(
                'Gérez vos ventes intelligemment avec\n IA Confirm.\nAutomatisez, répondez et suivez vos commandes en toute simplicité.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF141414),
                ),
              ),

              const SizedBox(height: 60),

              // 🔘 Bouton SE CONNECTER
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 107, 48),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "SE CONNECTER",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🔘 Bouton REGISTER
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF141414), width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: const Color(0xFF141414),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "S'INSCRIRE",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const Spacer(),

              // Optionnel : footer version ou copyright
              const Text(
                '© 2025 IA Confirm',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black38,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
