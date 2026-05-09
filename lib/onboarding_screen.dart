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

  List onboardingData = [

    {
      "image": "assets/doctor.png",
      "title": "Doctor Monitoring",
      "description":
          "Doctors can monitor elderly patients remotely and efficiently."
    },

    {
      "image": "assets/elderly-pic.png",
      "title": "Health Tracking",
      "description":
          "Track heart rate, blood pressure, and health status in real time."
    },

    {
      "image": "assets/family_member.png",
      "title": "Family Connection",
      "description":
          "Family members stay updated and connected with their loved ones."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,

      body: SafeArea(

        child: Column(

          children: [

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

                    padding: const EdgeInsets.all(20),

                    child: Column(

                      children: [

                        Expanded(

                          flex: 6,

                          child: ClipRRect(

                            borderRadius: BorderRadius.circular(25),

                            child: Image.asset(
                              onboardingData[index]['image'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        Text(
                          onboardingData[index]['title'],
                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          onboardingData[index]['description'],
                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
            ),

            // النقاط
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: List.generate(
                onboardingData.length,

                (index) => Container(

                  margin: const EdgeInsets.symmetric(horizontal: 5),

                  width: currentIndex == index ? 20 : 8,
                  height: 8,

                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? Colors.blue
                        : Colors.grey.shade300,

                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Padding(

              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: SizedBox(

                width: double.infinity,
                height: 60,

                child: ElevatedButton(

                  onPressed: () {

                    if (currentIndex == onboardingData.length - 1) {

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                  );

                    } else {

                      _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  child: Text(

                    currentIndex == onboardingData.length - 1
                        ? "Get Started"
                        : "Next",

                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}