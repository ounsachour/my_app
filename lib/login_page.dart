import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'role_selection_page.dart';
import 'elderly_home_page.dart';
import 'family_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

bool obscurePassword = true;
String passwordError = "";

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  Future<void> login() async {

    final response = await http.post(

      Uri.parse('http://192.168.137.187/api/login.php'),

      body: {
        "email": emailController.text,
        "password": passwordController.text,
      },
    );

    final data = json.decode(response.body);

    if (data["success"] == true) {

 setState(() {
  passwordError = "";
});

int roleId =
    int.parse(data["role_id"].toString());

// ELDERLY

if (roleId == 4) {

  Navigator.pushReplacement(

    context,

    MaterialPageRoute(

     builder: (context) =>

    ElderlyHomePage(

  firstName:
      data["first_name"],

  patientId:
      int.parse(
        data["patient_id"].toString(),
      ),
),
    ),
  );
}

// FAMILY MEMBER

else if (roleId == 3) {

  Navigator.pushReplacement(

    context,

    MaterialPageRoute(

      builder: (context) =>

          FamilyHomePage(),
    ),
  );
}

} else {

  if (data["message"] == "Wrong password") {

    setState(() {
      passwordError = "Incorrect password";
    });

  } else {

    setState(() {
      passwordError = "";
    });

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(
        backgroundColor: Colors.red,

        content: Text(
          data["message"],

          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Container(
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
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
                  const Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  

                  const SizedBox(height: 35),

                  // EMAIL FIELD
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "E-mail",

                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFF005B5B),
                      ),

                      filled: true,
                      fillColor: const Color(0xFFF1F1F1),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD FIELD
                  

                   TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,

                  decoration: InputDecoration(
                    hintText: "Password",

                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF005B5B),
                    ),

                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),

                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),

                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                  const SizedBox(height: 15),
                  if (passwordError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),

                    child: Align(
                      alignment: Alignment.centerLeft,

                      child: Text(
                        passwordError,

                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  // FORGOT PASSWORD
                  TextButton(
                    onPressed: () {
                    login();
                                  },

                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(
                        color: Color(0xFF005B5B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // CONTINUE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 60,

                    child: ElevatedButton(
                    onPressed: () {
                      login();
                    },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005B5B),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      child: const Text(
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
                          color: Colors.grey.shade300,
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Don't have an account yet?",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
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
                        backgroundColor: const Color(0xFFF1F1F1),
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      child: const Text(
                        "Create an account",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                 

                  const SizedBox(height: 18),

                  // GOOGLE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton.icon(
                      onPressed: () {},

                      icon: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                        height: 22,
                      ),

                      label: const Text(
                        "Sign in with Google",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F1F1),
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // TERMS
                  const Text(
                    "By clicking “Continue”, I have read and agree\nwith the Term Sheet, Privacy Policy",
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.grey,
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
}