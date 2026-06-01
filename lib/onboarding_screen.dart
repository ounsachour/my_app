import 'package:flutter/material.dart';
import 'login_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/doctor.png",
      "title": "Doctor Monitoring",
      "description": "Doctors can monitor elderly patients remotely and efficiently."
    },
    {
      "image": "assets/elderly-pic.png",
      "title": "Health Tracking",
      "description": "Track heart rate, blood pressure, and health status in real time."
    },
    {
      "image": "assets/family_member.png",
      "title": "Family Connection",
      "description": "Family members stay updated and connected with their loved ones."
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // خلفية بيضاء مائلة للزرقة مريحة جداً للعين
      body: SafeArea(
        child: Column(
          children: [
            // زر التخطي (Skip) في الأعلى
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                child: TextButton(
                  onPressed: _navigateToLogin,
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // محتوى السلايدر
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // الصورة بتصميم عصري وظل خفيف
                        Expanded(
                          flex: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                onboardingData[index]['image']!,
                                fit: BoxFit.contain, // لجعل الصورة تظهر بالكامل بدون قص احترافي
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // العنوان
                        Text(
                          onboardingData[index]['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B), // كحلي غامق بدلاً من الأسود الحاد
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // الوصف
                        Text(
                          onboardingData[index]['description']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey.shade500,
                            height: 1.5, // مسافة بين الأسطر لتسهيل القراءة
                          ),
                        ),
                        const Expanded(flex: 1, child: SizedBox()),
                      ],
                    ),
                  );
                },
              ),
            ),

            // الجزء السفلي (النقاط + الزر)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // نقاط المؤشر المتحركة (Animated Dots)
                  Row(
                    children: List.generate(
                      onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentIndex == index ? 24 : 8, // يتمدد عند التحديد
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? Colors.blue.shade600
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // زر التالي / البدء بشكل دائري/بيضاوي عصري
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: currentIndex == onboardingData.length - 1 ? 160 : 60,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentIndex == onboardingData.length - 1) {
                          _navigateToLogin();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic, // حركة أنعم للتبديل
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.blue.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: currentIndex == onboardingData.length - 1
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Get Started",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            )
                          : const Icon(Icons.arrow_forward_rounded, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}