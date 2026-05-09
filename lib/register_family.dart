import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'welcome_page.dart';
import 'family_home_page.dart';

class RegisterFamily extends StatefulWidget {
  const RegisterFamily({super.key});

  @override
  State<RegisterFamily> createState() =>
      _RegisterFamilyState();
}

class _RegisterFamilyState
    extends State<RegisterFamily> {

  final PageController _pageController =
      PageController();

  int currentStep = 0;

  // CONTROLLERS

  final TextEditingController firstNameController =
      TextEditingController();

  final TextEditingController lastNameController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  // VALIDATION

  String? emailError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;
  Future<void> registerFamily() async {

  // EMPTY CHECK

  if (

      firstNameController.text.isEmpty ||
      lastNameController.text.isEmpty ||
      phoneController.text.isEmpty ||
      emailController.text.isEmpty ||
      passwordController.text.isEmpty ||
      confirmPasswordController.text.isEmpty

  ) {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text("Please fill all fields"),
        backgroundColor: Colors.red,
      ),
    );

    return;
  }

  // PASSWORD MATCH

  if (passwordController.text !=
      confirmPasswordController.text) {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text("Passwords do not match"),
        backgroundColor: Colors.red,
      ),
    );

    return;
  }

  try {

    final response = await http.post(

      Uri.parse(
        "http://192.168.1.40/api/register_family.php",
      ),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({

        "first_name":
            firstNameController.text,

        "last_name":
            lastNameController.text,

        "phone":
            phoneController.text,

        "email":
            emailController.text,

        "password":
            passwordController.text,
      }),
    );

    final data = jsonDecode(response.body);

    if (data["success"] == true) {

  Navigator.pushReplacement(

    context,

    MaterialPageRoute(
      builder: (context) =>
          WelcomePage(
          nextPage: FamilyHomePage(),
        ),
    ),
  );
} else {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text(data["message"]),
          backgroundColor: Colors.red,
        ),
      );
    }

  } catch (e) {

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(
        content: Text("Error: $e"),
      ),
    );
  }
}

  // NEXT STEP

 void nextStep() {

  // STEP 1 VALIDATION

  if (currentStep == 0) {

    if (

        firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        phoneController.text.isEmpty

    ) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );

      return;
    }

    // PHONE ERROR

    if (phoneError != null) {
      return;
    }
  }

  // NEXT PAGE

  if (currentStep < 1) {

    currentStep++;

    _pageController.animateToPage(

      currentStep,

      duration: const Duration(
        milliseconds: 300,
      ),

      curve: Curves.easeInOut,
    );

    setState(() {});
  }
}

  // PREVIOUS STEP

  void previousStep() {

    if (currentStep > 0) {

      currentStep--;

      _pageController.animateToPage(
        currentStep,

        duration: const Duration(
          milliseconds: 300,
        ),

        curve: Curves.easeInOut,
      );

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(

        child: Column(
          children: [

            // HEADER

            Container(

              padding: const EdgeInsets.all(25),

              decoration: const BoxDecoration(

                color: Colors.white,

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const SizedBox(height: 10),

                  const Text(
                    "Create Family Account",

                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(

                    currentStep == 0
                        ? "Step 1 of 2: Personal Information"
                        : "Step 2 of 2: Account Information",

                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // PROGRESS BAR

                  LinearProgressIndicator(

                    value: (currentStep + 1) / 2,

                    minHeight: 8,

                    borderRadius:
                        BorderRadius.circular(10),

                    backgroundColor:
                        Colors.grey.shade300,

                    valueColor:
                        const AlwaysStoppedAnimation(
                      Color(0xFF005B5B),
                    ),
                  ),
                ],
              ),
            ),

            // PAGES

            Expanded(

              child: PageView(

                controller: _pageController,

                physics:
                    const NeverScrollableScrollPhysics(),

                children: [

                  buildStepOne(),

                  buildStepTwo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= STEP 1 =================

  Widget buildStepOne() {

    return SingleChildScrollView(

      padding: const EdgeInsets.all(25),

      child: SizedBox(

        height:
            MediaQuery.of(context).size.height * 0.72,

        child: Column(
          children: [

            buildTextField(
              controller: firstNameController,
              label: "First Name",
              hint: "Enter first name",
            ),

            const SizedBox(height: 20),

            buildTextField(
              controller: lastNameController,
              label: "Last Name",
              hint: "Enter last name",
            ),

            const SizedBox(height: 20),

            buildTextField(

              controller: phoneController,

              label: "Phone",

              hint: "Enter phone number",

              keyboardType:
                  TextInputType.phone,

              errorText: phoneError,

              onChanged: (value) {

                setState(() {

                  if (value.length < 10) {

                    phoneError =
                        "Invalid phone number";

                  } else {

                    phoneError = null;
                  }
                });
              },
            ),

            const SizedBox(height: 40),

            buildContinueButton(
              onPressed: nextStep,
            ),
          ],
        ),
      ),
    );
  }

  // ================= STEP 2 =================

  Widget buildStepTwo() {

    return SingleChildScrollView(

      padding: const EdgeInsets.all(25),

      child: SizedBox(

        height:
            MediaQuery.of(context).size.height * 0.72,

        child: Column(
          children: [

            buildTextField(

              controller: emailController,

              label: "Email",

              hint: "Enter email",

              keyboardType:
                  TextInputType.emailAddress,

              errorText: emailError,

              onChanged: (value) {

                setState(() {

                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) { 

                    emailError =
                        "Enter a valid email";

                  } else {

                    emailError = null;
                  }
                });
              },
            ),

            const SizedBox(height: 20),

            buildTextField(

              controller: passwordController,

              label: "Password",

              hint: "Enter password",

              obscureText: true,

              icon: Icons.lock,

              errorText: passwordError,

              onChanged: (value) {

                setState(() {

                  if (value.length < 8) {

                    passwordError =
                        "Minimum 8 characters";

                  } else {

                    passwordError = null;
                  }
                });
              },
            ),

            const SizedBox(height: 20),

            buildTextField(

              controller:
                  confirmPasswordController,

              label: "Confirm Password",

              hint: "Confirm password",

              obscureText: true,

              icon: Icons.lock_outline,

              errorText: confirmPasswordError,

              onChanged: (value) {

                setState(() {

                  if (value !=
                      passwordController.text) {

                    confirmPasswordError =
                        "Passwords do not match";

                  } else {

                    confirmPasswordError = null;
                  }
                });
              },
            ),

            const SizedBox(height: 40),

            Row(
              children: [

                Expanded(
                  child: buildSecondaryButton(
                    text: "Back",
                    onPressed: previousStep,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: buildContinueButton(
                    text: "Create",
                    onPressed: registerFamily,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= TEXT FIELD =================

  Widget buildTextField({

    required TextEditingController controller,

    required String label,

    required String hint,

    TextInputType keyboardType =
        TextInputType.text,

    IconData? icon,

    bool obscureText = false,

    VoidCallback? onTap,

    String? errorText,

    Function(String)? onChanged,
  }) {

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(

          label,

          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        TextField(

          controller: controller,

          keyboardType: keyboardType,

          obscureText: obscureText,

          onTap: onTap,

          onChanged: onChanged,

          decoration: InputDecoration(

            hintText: hint,

            errorText: errorText,

            suffixIcon:
                icon != null ? Icon(icon) : null,

            filled: true,

            fillColor: const Color(0xFFF1F4F9),

            border: OutlineInputBorder(

              borderRadius:
                  BorderRadius.circular(18),

              borderSide: BorderSide.none,
            ),

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }

  // ================= MAIN BUTTON =================

  Widget buildContinueButton({

    required VoidCallback onPressed,

    String text = "Continue",
  }) {

    return SizedBox(

      width: double.infinity,

      height: 58,

      child: ElevatedButton(

        onPressed: onPressed,

        style: ElevatedButton.styleFrom(

          backgroundColor:
              const Color(0xFF005B5B),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
        ),

        child: Text(

          text,

          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ================= SECONDARY BUTTON =================

  Widget buildSecondaryButton({

    required String text,

    required VoidCallback onPressed,
  }) {

    return SizedBox(

      height: 58,

      child: OutlinedButton(

        onPressed: onPressed,

        style: OutlinedButton.styleFrom(

          side: const BorderSide(
            color: Color(0xFF005B5B),
          ),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
        ),

        child: Text(

          text,

          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF005B5B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}