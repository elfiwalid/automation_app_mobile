import 'package:flutter/material.dart';
import 'welcome_page.dart'; // ⚠️ assure-toi que ce fichier est bien importé

class IntroSlider extends StatefulWidget {
  const IntroSlider({super.key});

  @override
  State<IntroSlider> createState() => _IntroSliderState();
}

class _IntroSliderState extends State<IntroSlider> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "assets/slide1.png",
      "text": "Gérez facilement vos commandes avec IA Confirm. Une solution intelligente et rapide."
    },
    {
      "image": "assets/slide2.png",
      "text": "Répondez automatiquement à vos clients WhatsApp, sans perdre de temps."
    },
    {
      "image": "assets/slide3.png",
      "text": "Enregistrez les commandes automatiquement et suivez vos livraisons efficacement."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        pages[index]["image"]!,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        pages[index]["text"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),

                      // 🎯 Bouton visible SEULEMENT sur la dernière page
                      if (_currentPage == pages.length - 1) ...[
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WelcomePage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 255, 107, 48),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 40,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Commencer',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ]
                    ],
                  ),
                );
              },
            ),
          ),

          // 🔘 Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 24),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Colors.black
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
