import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'welcome_page.dart';
import 'elderly_home_page.dart';

class RegisterElderly extends StatefulWidget {
  const RegisterElderly({super.key});

  @override
  State<RegisterElderly> createState() => _RegisterElderlyState();
}

class _RegisterElderlyState extends State<RegisterElderly> {
  final PageController _pageController = PageController();

  int currentStep = 0;

  // Controllers
  final TextEditingController firstNameController =
      TextEditingController();

  final TextEditingController lastNameController =
      TextEditingController();

  final TextEditingController dobController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController emergencyContactController =
      TextEditingController();

  final TextEditingController emergencyPhoneController =
      TextEditingController();

  final TextEditingController deviceIdController =
    TextEditingController();

  final TextEditingController passwordController =
    TextEditingController();

  final TextEditingController confirmPasswordController =
    TextEditingController();

  String? selectedGender;
  String? selectedBloodType;
  String? emailError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;
  Future<void> registerElderly() async {

  // EMPTY FIELDS CHECK

if (

    firstNameController.text.isEmpty ||
    lastNameController.text.isEmpty ||
    dobController.text.isEmpty ||
    selectedGender == null ||
    phoneController.text.isEmpty ||
    emailController.text.isEmpty ||
    passwordController.text.isEmpty ||
    confirmPasswordController.text.isEmpty ||
    selectedBloodType == null ||
    emergencyContactController.text.isEmpty ||
    emergencyPhoneController.text.isEmpty ||
    deviceIdController.text.isEmpty
) {

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Please fill all fields"),
      backgroundColor: Colors.red,
    ),
  );

  return;
}


// EMAIL VALIDATION

if (!emailController.text.contains("@")) {

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Enter a valid email"),
      backgroundColor: Colors.red,
    ),
  );

  return;
}


// PHONE VALIDATION

if (phoneController.text.length < 10) {

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Enter a valid phone number"),
      backgroundColor: Colors.red,
    ),
  );

  return;
}


// PASSWORD LENGTH

if (passwordController.text.length < 8) {

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Password must be at least 8 characters",
      ),
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
        "http://192.168.1.40/api/register_elderly.php",
      ),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({

        "first_name":
            firstNameController.text,

        "last_name":
            lastNameController.text,

        "date_of_birth":
            dobController.text,

        "gender":
            selectedGender,

        "blood_type":
            selectedBloodType,

        "phone":
            phoneController.text,

        "email":
            emailController.text,

        "password":
            passwordController.text,

        "emergency_contact_name":
            emergencyContactController.text,

        "emergency_contact_phone":
            emergencyPhoneController.text,
        
        "device_id":
            deviceIdController.text,
      }),
    );

    final data = jsonDecode(response.body);

    if (data["success"] == true) {

  Navigator.push(

    context,

    MaterialPageRoute(
      builder: (context) =>
          WelcomePage(
        nextPage: ElderlyHomePage(),
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
    if (currentStep < 2) {
      currentStep++;

      _pageController.animateToPage(
        currentStep,
        duration: const Duration(milliseconds: 300),
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      setState(() {});
    }
  }

  // DATE PICKER
Future<void> pickDate() async {

  DateTime? pickedDate = await showDatePicker(

    context: context,

    initialDate: DateTime(1960),

    firstDate: DateTime(1940),

    lastDate: DateTime.now(),

    builder: (context, child) {

      return Theme(

        data: Theme.of(context).copyWith(

          colorScheme: const ColorScheme.light(

            primary: Color(0xFF005B5B),

            onPrimary: Colors.white,

            onSurface: Colors.black87,
          ),

          datePickerTheme: DatePickerThemeData(

            backgroundColor: Colors.white,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),

        child: child!,
      );
    },
  );

  if (pickedDate != null) {

    dobController.text =
        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 10),

                  const Text(
                    "Create Elderly Account",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    currentStep == 0
                        ? "Step 1 of 3: Personal Information"
                        : currentStep == 1
                            ? "Step 2 of 3: Contact Information"
                            : "Step 3 of 3: Medical & Emergency",

                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // PROGRESS BAR
                  LinearProgressIndicator(
                    value: (currentStep + 1) / 3,
                    minHeight: 8,

                    borderRadius: BorderRadius.circular(10),

                    backgroundColor: Colors.grey.shade300,

                    valueColor: const AlwaysStoppedAnimation(
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
                physics: const NeverScrollableScrollPhysics(),

                children: [

                  // STEP 1
                  buildStepOne(),

                  // STEP 2
                  buildStepTwo(),

                  // STEP 3
                  buildStepThree(),
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
      height: MediaQuery.of(context).size.height * 0.72,

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

          // DATE OF BIRTH
            buildTextField(
              controller: dobController,
              label: "Date of Birth",
              hint: "DD/MM/YYYY",
              icon: Icons.calendar_month,

              onTap: () async {
                await pickDate();
              },
            ),

          const SizedBox(height: 20),

          // GENDER
         // GENDER

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    const Text(
      "Gender",
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),

    const SizedBox(height: 12),

    Row(
      children: [

        // MALE
        Expanded(
          child: GestureDetector(

            onTap: () {
              setState(() {
                selectedGender = "Male";
              });
            },

            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 18,
              ),

              decoration: BoxDecoration(

                color: selectedGender == "Male"
                    ? const Color(0xFF005B5B)
                    : const Color(0xFFF1F4F9),

                borderRadius: BorderRadius.circular(18),

                border: Border.all(
                  color: selectedGender == "Male"
                      ? const Color(0xFF005B5B)
                      : Colors.transparent,
                ),
              ),

              child: Column(
                children: [

                  Icon(
                    Icons.male,
                    size: 32,

                    color: selectedGender == "Male"
                        ? Colors.white
                        : Colors.black54,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Male",

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,

                      color: selectedGender == "Male"
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 15),

        // FEMALE
        Expanded(
          child: GestureDetector(

            onTap: () {
              setState(() {
                selectedGender = "Female";
              });
            },

            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 18,
              ),

              decoration: BoxDecoration(

                color: selectedGender == "Female"
                    ? const Color(0xFF005B5B)
                    : const Color(0xFFF1F4F9),

                borderRadius: BorderRadius.circular(18),

                border: Border.all(
                  color: selectedGender == "Female"
                      ? const Color(0xFF005B5B)
                      : Colors.transparent,
                ),
              ),

              child: Column(
                children: [

                  Icon(
                    Icons.female,
                    size: 32,

                    color: selectedGender == "Female"
                        ? Colors.white
                        : Colors.black54,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Female",

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,

                      color: selectedGender == "Female"
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  ],
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
      height: MediaQuery.of(context).size.height * 0.72,

      child: Column(
        children: [

          buildTextField(
          controller: phoneController,
          label: "Phone",
          hint: "Enter phone number",
          keyboardType: TextInputType.phone,

          errorText: phoneError,

          onChanged: (value) {

            setState(() {

              if (value.length < 10) {
                phoneError = "Invalid phone number";
              } else {
                phoneError = null;
              }
            });
          },
        ),

          const SizedBox(height: 20),

          buildTextField(
          controller: emailController,
          label: "Email",
          hint: "Enter email",
          keyboardType: TextInputType.emailAddress,

          errorText: emailError,

          onChanged: (value) {

            setState(() {

              if (!value.contains("@")) {
                emailError = "Enter a valid email";
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
            controller: confirmPasswordController,
            label: "Confirm Password",
            hint: "Confirm password",
            obscureText: true,
            icon: Icons.lock_outline,

            errorText: confirmPasswordError,

            onChanged: (value) {

              setState(() {

                if (value != passwordController.text) {

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
                  onPressed: nextStep,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
  // ================= STEP 3 =================

  Widget buildStepThree() {
    return SingleChildScrollView(
  padding: const EdgeInsets.all(25),

  child: SizedBox(
    height: MediaQuery.of(context).size.height * 0.82,

    child: Column(
      
        children: [

          // BLOOD TYPE

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    const Text(
      "Blood Type",
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),

    const SizedBox(height: 15),

    Wrap(
      spacing: 12,
      runSpacing: 12,

      children: [

        "A+",
        "A-",
        "B+",
        "B-",
        "AB+",
        "AB-",
        "O+",
        "O-",

      ].map((bloodType) {

        bool isSelected =
            selectedBloodType == bloodType;

        return GestureDetector(

          onTap: () {
            setState(() {
              selectedBloodType = bloodType;
            });
          },

          child: AnimatedContainer(

            duration: const Duration(
              milliseconds: 200,
            ),

            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 16,
            ),

            decoration: BoxDecoration(

              color: isSelected
                  ? const Color(0xFF005B5B)
                  : const Color(0xFFF1F4F9),

              borderRadius: BorderRadius.circular(18),

              border: Border.all(
                color: isSelected
                    ? const Color(0xFF005B5B)
                    : Colors.transparent,
              ),
            ),

            child: Text(

              bloodType,

              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,

                color: isSelected
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
        );

      }).toList(),
    ),
  ],
),

          const SizedBox(height: 20),

          buildTextField(
            controller: emergencyContactController,
            label: "Emergency Contact",
            hint: "Enter contact name",
          ),

          const SizedBox(height: 20),

          buildTextField(
            controller: emergencyPhoneController,
            label: "Emergency Contact Phone",
            hint: "Enter emergency phone",
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 20),

          buildTextField(
            controller: deviceIdController,
            label: "Device ID",
            hint: "Enter device ID",
            icon: Icons.devices,
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
                  onPressed: registerElderly,
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
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    bool obscureText = false,
    VoidCallback? onTap,
    String? errorText,
  Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }

  // ================= DROPDOWN =================

  Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),

          decoration: BoxDecoration(
            color: const Color(0xFFF1F4F9),
            borderRadius: BorderRadius.circular(18),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: const Text("Select"),

              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),

              onChanged: onChanged,
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
          backgroundColor: const Color(0xFF005B5B),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
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
            borderRadius: BorderRadius.circular(18),
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