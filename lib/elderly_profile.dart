import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'custom_bottom_navbar.dart';
import 'config.dart';

  class ProfilePage extends StatefulWidget {

  final String firstName;
  final int patientId;
  final int userId;

  const ProfilePage({
  super.key,
  required this.firstName,
  required this.patientId,
  required this.userId,
});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profileData;

bool isLoading = true;
Future<void> getProfile() async {

  try {

    final response = await http.get(

    Uri.parse(
  "${AppConfig.baseUrl}/api/get_profile.php?patient_id=${widget.patientId}"
),
    );

    final data = jsonDecode(response.body);
    print(response.body);

    if (data["success"]) {

      setState(() {

        profileData = data["data"];
        isLoading = false;
      });

    } else {

      setState(() {
        isLoading = false;
      });
    }

  } catch (e) {

    print(e);

    setState(() {
      isLoading = false;
    });
  }
}

@override
void initState() {
  super.initState();
  getProfile();
}
  @override
  Widget build(BuildContext context) {
    if (isLoading) {

  return const Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );
}
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC), // خلفية هادئة ونظيفة
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar:

    CustomBottomNavBar(

  currentIndex: 3,
firstName: widget.firstName,
patientId: widget.patientId,
userId: widget.userId,
unreadNotifications: 0,
),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- قسم الرأس: الصورة، الاسم، والكرات الملونة ---
            _buildProfileHeader(),
            
            const SizedBox(height: 35),

            // --- قسم قائمة الخيارات ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuTile(Icons.person_outline_rounded, "Personal Information", () {}),
                  _buildMenuTile(Icons.history_rounded, "Appointment History", () {}),
                  _buildMenuTile(Icons.notifications_none_rounded, "Notifications", () {}),
                  _buildMenuTile(Icons.shield_outlined, "Privacy & Security", () {}),
                  _buildMenuTile(Icons.help_outline_rounded, "Help Center", () {}),
                  const SizedBox(height: 20),
                  _buildMenuTile(Icons.logout_rounded, "Logout", () {}, isLogout: true),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
int calculateAge(String birthDate) {

  DateTime birth = DateTime.parse(birthDate);

  DateTime today = DateTime.now();

  int age = today.year - birth.year;

  if (
    today.month < birth.month ||
    (today.month == birth.month &&
        today.day < birth.day)
  ) {
    age--;
  }

  return age;
}
  // ميثود بناء الجزء العلوي (صورة، اسم، كروت)
  Widget _buildProfileHeader() {
    return Column(
      children: [
        // الصورة في المنتصف مع إطار خفيف وأيقونة الكاميرا
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF005B5B), width: 2),
                ),
                child: const CircleAvatar(
                  radius: 55,
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(
  Icons.person,
  size: 60,
  color: Colors.grey,
), // تأكدي من إضافة الصورة في assets
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF005B5B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // الاسم واللقب
        Text(
  "${profileData?["first_name"] ?? ""} ${profileData?["last_name"] ?? ""}", // الاسم المعتمد في السجل
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        Text(
  profileData?["email"] ?? "",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 25),

        // الكرتين الملونين للعمر وزمرة الدم
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInfoCard(
  "Age",
  profileData?["date_of_birth"] != null
      ? calculateAge(
          profileData!["date_of_birth"],
        ).toString()
      : "", const Color(0xFFE8F5F5), const Color(0xFF005B5B)),
            const SizedBox(width: 20),
            _buildInfoCard(
  "Blood",
  profileData?["blood_type"] ?? "", const Color(0xFFFFF0F0), Colors.redAccent),
          ],
        ),
      ],
    );
  }

  // ميثود بناء الكرت الصغير الملون
  Widget _buildInfoCard(String label, String value, Color bgColor, Color textColor) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25), // حواف دائرية فخمة
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ميثود بناء عناصر القائمة (نفس ستايل الحقول التي أعجبتك)
  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    Color mainColor = isLogout ? Colors.red : const Color(0xFF005B5B);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: mainColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: mainColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isLogout ? Colors.red : Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}