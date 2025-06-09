import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../app.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Moovies',
      'subtitle': 'Favori Filmlerini Takip Et',
      'description':
      'Artık hangi filmleri izlediğini ya da izlemek istediğini unutmuyorsun.\nKendi film arşivini oluştur ve sinema yolculuğunu düzenli takip et.',
      'color': Color(0xFF0D1B2A),
      'image': 'assets/onboarding/on1.png',
    },
    {
      'title': 'Moovies',
      'subtitle': 'Film Severlerle Mesajlaş',
      'description':
      'Beğendiğin filmleri seven insanlarla tanış,\ndüşüncelerini paylaş ve film üzerine sohbetlere katıl.',
      'color': const Color.fromARGB(255, 27, 79, 12),
      'image': 'assets/onboarding/on1.png',
    },
    {
      'title': 'Moovies',
      'subtitle': 'Yorum Yap, Öneri Al',
      'description':
      'İzlediğin filmlerle ilgili yorumlarını paylaş,\nbaşkalarının favorilerini keşfet ve ilham al.',
      'color': const Color.fromARGB(255, 109, 66, 9),
      'image': 'assets/onboarding/on2.png',
    },
  ];

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pages[_currentPage]['color'],
      body: Stack(
        children: [
          // Sabit ORTA container
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),

          // PageView içerik
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Resim - Asset kullanımı
                  Container(
                    height: 200,
                    width: 300, // Sabit genişlik ekledik
                    margin: const EdgeInsets.only(bottom: 30),
                    child: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(20), // Oval köşeler için
                      child: Image.asset(
                        _pages[index]['image'],
                        fit: BoxFit
                            .cover, // Resmi tamamen kaplayacak şekilde ayarladık
                      ),
                    ),
                  ),
                  // İçerik Container'ı
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Başlık
                        Text(
                          _pages[index]['title'],
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _pages[index]['color'],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Alt başlık
                        Text(
                          _pages[index]['subtitle'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Açıklama
                        Text(
                          _pages[index]['description'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Dot indicator - DÜZELTİLMİŞ VERSİYON
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.10,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: SlideEffect(
                  dotHeight: 6, // Daha ince noktalar
                  dotWidth: 20, // Daha geniş noktalar
                  spacing: 8, // Daha az boşluk
                  dotColor: Colors.black.withOpacity(0.2), // Daha açık renk
                  activeDotColor: Colors.black,
                  type: SlideType.slideUnder, // Düz kayma efekti
                ),
              ),
            ),
          ),
          // Get Started butonu (sadece son sayfada)
          if (_currentPage == _pages.length - 1)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    _finishOnboarding(); // Onboarding'i tamamla
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Şimdi Başla",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Skip butonu (son sayfa hariç)
          if (_currentPage != _pages.length - 1)
            Positioned(
              top: 60,
              right: 30,
              child: TextButton(
                onPressed: () {
                  _pageController.animateToPage(
                    _pages.length - 1,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                },
                child: const Text(
                  'Atla',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
