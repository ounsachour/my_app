// lib/login_page.dart (بدون زر تبديل ثيم منفصل)

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'role_selection_page.dart';
import 'elderly_home_page.dart';
import 'family_home_page.dart';
import 'welcome_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscurePassword = true;
  String passwordError = "";
  String emailError = "";
  bool isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Validation method
  bool validateInputs() {
    setState(() {
      emailError = "";
      passwordError = "";
    });

    bool isValid = true;

    if (emailController.text.trim().isEmpty) {
      setState(() {
        emailError = "Email is required";
      });
      isValid = false;
    } else if (!emailController.text.contains('@')) {
      setState(() {
        emailError = "Enter a valid email address";
      });
      isValid = false;
    }

    if (passwordController.text.isEmpty) {
      setState(() {
        passwordError = "Password is required";
      });
      isValid = false;
    }

    return isValid;
  }

  Future<void> login() async {
    if (isLoading) return;

    if (!validateInputs()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.43.71/api/login.php'),
        body: {
          "email": emailController.text.trim(),
          "password": passwordController.text,
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      final data = json.decode(response.body);
      print('📦 Login Response: $data');

      if (data["success"] == true) {
        int roleId = int.parse(data["role_id"]?.toString() ?? "0");
        int userId = int.parse(data["user_id"]?.toString() ?? "0");

        if (roleId == 4) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomePage(
                nextPage: ElderlyHomePage(
                  firstName: data["first_name"] ?? "",
                  patientId: userId,
                ),
              ),
            ),
          );
        }
        else if (roleId == 3) {
          print('🔍 Family Login Debug:');
          print('   - firstName: ${data["first_name"]}');
          print('   - familyUserId: $userId');
          print('   - patientId: 0 (no specific patient yet)');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomePage(
                nextPage: FamilyHomePage(
                  firstName: data["first_name"] ?? "",
                  patientId: 0,
                  familyUserId: userId,
                ),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orange,
              content: Text("Role not recognized"),
            ),
          );
          setState(() {
            isLoading = false;
          });
        }
      } else {
        if (data["message"] == "Wrong password") {
          setState(() {
            passwordError = "Incorrect password";
          });
        } else if (data["message"] == "Email not found") {
          setState(() {
            emailError = "Email not registered";
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                data["message"] ?? "Login failed",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error: $e"),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // LOGO
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: const Color(0xFF005B5B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // TITLE
                  Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Welcome back! Please sign in to continue.",
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 35),
                  
                  // EMAIL FIELD
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                    decoration: InputDecoration(
                      hintText: "E-mail",
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                      ),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFF005B5B),
                      ),
                      filled: true,
                      fillColor: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF1F1F1),
                      errorText: emailError.isEmpty ? null : emailError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // PASSWORD FIELD
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF005B5B),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF1F1F1),
                      errorText: passwordError.isEmpty ? null : passwordError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // FORGOT PASSWORD
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Password reset feature coming soon'),
                            backgroundColor: isDarkMode ? Colors.orange.shade700 : Colors.orange,
                          ),
                        );
                      },
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                          color: const Color(0xFF005B5B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // CONTINUE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => login(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005B5B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // DIVIDER
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Don't have an account yet?",
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  
                  // CREATE ACCOUNT
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RoleSelectionPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF1F1F1),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        "Create an account",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  
                  // GOOGLE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Google Sign In coming soon'),
                            backgroundColor: isDarkMode ? Colors.orange.shade700 : Colors.orange,
                          ),
                        );
                      },
                      icon: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                        height: 22,
                      ),
                      label: Text(
                        "Sign in with Google",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF1F1F1),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // TERMS
                  Text(
                    "By clicking \"Continue\", I have read and agree\nwith the Term Sheet, Privacy Policy",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey.shade500 : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}