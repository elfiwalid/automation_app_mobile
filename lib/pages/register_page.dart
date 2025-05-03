import 'package:ecommerce_app/pages/login_page.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  bool _acceptTerms = false;
  bool _acceptPrivacy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // 🔶 Titre
                const Center(
                  child: Text(
                    "Créer un compte",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF141414),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 🔶 Nom
                _buildTextField(label: "Nom"),

                const SizedBox(height: 16),

                // 🔶 Prénom
                _buildTextField(label: "Prénom"),

                const SizedBox(height: 16),

                // 🔶 Email
                _buildTextField(label: "Email", inputType: TextInputType.emailAddress),

                const SizedBox(height: 16),

                // 🔶 Téléphone WhatsApp
                _buildTextField(label: "Téléphone WhatsApp", inputType: TextInputType.phone),

                const SizedBox(height: 16),

                // 🔶 Mot de passe
                _buildTextField(label: "Mot de passe", isPassword: true),

                const SizedBox(height: 16),

                // 🔶 Confirmer mot de passe
                _buildTextField(label: "Confirmer mot de passe", isPassword: true),

                const SizedBox(height: 20),

                // 🔶 Coche 1
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acceptTerms,
                  onChanged: (value) => setState(() => _acceptTerms = value ?? false),
                  title: const Text(
                    "J'accepte les termes et conditions.",
                    style: TextStyle(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                // 🔶 Coche 2
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acceptPrivacy,
                  onChanged: (value) => setState(() => _acceptPrivacy = value ?? false),
                  title: const Text(
                    "J'accepte la politique de confidentialité.",
                    style: TextStyle(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                const SizedBox(height: 20),

                // 🔴 Bouton s'inscrire
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _acceptTerms &&
                          _acceptPrivacy) {
                        // TODO: Envoyer au backend
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 107, 48),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "S'INSCRIRE",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔗 Lien vers login
                Center(
                  child: GestureDetector(
                    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    },
                    child: const Text(
                      "Vous avez déjà un compte ? Connectez-vous",
                      style: TextStyle(
                        color: Color(0xFF141414),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      keyboardType: inputType,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.grey.shade300,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? "Ce champ est requis" : null,
    );
  }
}
