import 'package:flutter/material.dart';
import 'custom_bottom_navbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ElderlyHomePage extends StatefulWidget {

  final String firstName;
  final int patientId;

  const ElderlyHomePage({
    super.key,
    required this.firstName,
    required this.patientId,
  });

  @override
  State<ElderlyHomePage> createState() =>
      _ElderlyHomePageState();
}

class _ElderlyHomePageState
    extends State<ElderlyHomePage> {
      String temperature = "--";
      String heartRate = "--";
      String oxygen = "--";
      Timer? timer;
      @override
void initState() {
  super.initState();

  getVitals();
  timer = Timer.periodic(

  const Duration(seconds: 5),

  (timer) {

    getVitals();
  },
);
}
Future<void> getVitals() async {

  final response = await http.get(

    Uri.parse(

      "http://192.168.137.187/api/get_patient_vitals.php?patient_id=${widget.patientId}",
    ),
  );

  if (response.statusCode == 200) {

    final data = json.decode(response.body);

    if (data["success"] == true) {

      setState(() {

        temperature =
            data["data"]["temperature"]
                .toString();

        heartRate =
            data["data"]["heart_rate"]
                .toString();

        oxygen =
            data["data"]["spo2"]
                .toString();
      });
    }
  }
}
@override
void dispose() {

  timer?.cancel();

  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // لون خلفية هادئ جداً (Neutral Grey) كما تطبيقات Apple Health
      backgroundColor: const Color(0xFFFBFBFC), 
      body: SafeArea(
        child: SingleChildScrollView( // أضفنا هذا السطر لجعل الصفحة تتحرك للأعلى والأسفل
          physics: const BouncingScrollPhysics(), // تعطي حركة ناعمة عند الوصول للنهاية (مثل الآيفون)
          child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24, // زيادة الهامش تعطي فخامة أكثر
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP HEADER
              Row(
                children: [
                  // PROFILE IMAGE مع ظل ناعم
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 26,
                      backgroundImage: AssetImage("assets/elderly-pic.png"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // HELLO TEXT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, ${widget.firstName}!",
                          style: const TextStyle(
                            fontSize: 22, // تكبير الخط قليلاً
                            fontWeight: FontWeight.w800, // خط أغلظ (Bold)
                            color: Color(0xFF1A1A1A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Welcome back",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SEARCH BUTTON (بدون حدود، فقط ظل ناعم جداً)
                  _buildHeaderButton(Icons.search_rounded),
                  const SizedBox(width: 12),
                  // NOTIFICATION BUTTON
                  _buildHeaderButton(Icons.notifications_none_rounded, showBadge: true),
                ],
              ),

              const SizedBox(height: 35),

              // HEALTH SCORE CARD (تدرج لوني أفخم)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF005B5B), // اللون الأساسي تاعك
                      Color(0xFF007A7A), // درجة أفتح قليلاً للتدرج
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32), // حواف دائرية أكثر (Modern)
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF005B5B).withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Health Score",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "95%",
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            "Excellent condition",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: CircularProgressIndicator(
                            value: 0.95,
                            strokeWidth: 10,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                            strokeCap: StrokeCap.round, // جعل نهاية الخط دائرية (مهم جداً للـ UI)
                          ),
                        ),
                        const Column(
                          children: [
                            Text(
                              "95",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Score",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              

              const SizedBox(height: 30),

              // HEALTH STATUS CARDS
              Row(
                children: [
                  Expanded(
                    child: buildHealthCard(
                      icon: Icons.thermostat_rounded,
                      value: "$temperature°C",
                      color: const Color(0xFF3A86FF), // أزرق عصري أكثر
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: buildHealthCard(
                      icon: Icons.favorite_rounded,
                      value: "$heartRate bpm",
                      color: const Color(0xFFFF006E), // بينك/أحمر بريميوم
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: buildHealthCard(
                      icon: Icons.air_rounded,
                      value: "$oxygen %",
                      color: const Color(0xFF38B000), // أخضر حيوي
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32), // مسافة تفصل الكروت عن المواعيد

              // عنوان قسم المواعيد
              // --- بداية قسم الشريط الزمني الجديد ---
              // --- سطر العنوان مع زر الحجز ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Schedule",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  // زر Book الأنيق
                  InkWell(
                    onTap: () => _showBookingDialog(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF005B5B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_rounded, color: Color(0xFF005B5B), size: 18),
                          SizedBox(width: 4),
                          Text(
                            "Book",
                            style: TextStyle(
                              color: Color(0xFF005B5B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // --- نهاية قسم العنوان ---

              const SizedBox(height: 16),

              // عرض قائمة المواعيد بنمط الشريط الزمني
              _buildTimelineItem(
                title: "Dr. Sarah Mansouri",
                subtitle: "Cardiologist • Checkup",
                time: "10:30 AM",
                accentColor: const Color(0xFF005B5B),
                icon: Icons.favorite_rounded,
              ),
              
              _buildTimelineItem(
                title: "Medicine Time",
                subtitle: "After Lunch • 2 Pills",
                time: "01:00 PM",
                accentColor: Colors.orange,
                icon: Icons.medication_rounded,
              ),
              
              _buildTimelineItem(
                title: "Daily Walk",
                subtitle: "Park • 30 Minutes",
                time: "05:00 PM",
                accentColor: Colors.blue,
                icon: Icons.directions_walk_rounded,
              ),
              // --- نهاية قسم الشريط الزمني الجديد ---
            ],
          ),
        ),
      ),
      ),
      
      bottomNavigationBar: CustomBottomNavBar(
  currentIndex: 0,
  firstName: widget.firstName,
  patientId: widget.patientId,
),
    );
    
  }

  // ميثود المساعدة للأزرار العلوية (للحفاظ على نظافة الكود)
  Widget _buildHeaderButton(IconData icon, {bool showBadge = false}) {
    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF005B5B)),
        ),
        if (showBadge)
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget buildHealthCard({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        // إضافة الحواف بنفس لون الأيقونة بصح بـ Opacity خفيف باش ما تبانش قاصحة بزاف
        border: Border.all(
          color: color.withOpacity(0.4), // 40% شفافية تعطي مظهر زجاجي عصري
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05), // ظل خفيف جداً من نفس اللون
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة داخل دائرة بخلفية باهتة جداً
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800, // خط سميك للقراءات
              color: color.withOpacity(0.9), // جعل النص يميل للون الكرت لزيادة التناسق
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required String time,
    required Color accentColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: IntrinsicHeight( // لجعل الخط الجانبي يتمدد حسب محتوى الكرت
        child: Row(
          children: [
            // عمود الوقت والخط الزمني
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 4)],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: accentColor.withOpacity(0.2),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // كرت الموعد
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: accentColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        ],
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // وظيفة إظهار نافذة الحجز المنبثقة
  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // العودة للون الأبيض
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Column(
            children: [
              const Icon(Icons.calendar_today_rounded, color: Color(0xFF005B5B), size: 40),
              const SizedBox(height: 10),
              const Text(
                "Book Appointment",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // حقل اسم الطبيب
                _buildLabel("Doctor Name", isDark: false),
                _buildInputField("Select Doctor Name", Icons.person_pin_rounded),
                
                // حقل التاريخ
                _buildLabel("Date", isDark: false),
                _buildInputField("jj/mm/aaaa", Icons.calendar_today_rounded),
                
                // حقل الوقت
                _buildLabel("Time", isDark: false),
                _buildInputField("--:--", Icons.access_time_filled_rounded),
                
                // حقل النوع
                _buildLabel("Type", isDark: false),
                _buildInputField("Select Appointment Type", Icons.add_box_rounded),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Booking Successful!")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005B5B), // لونك الأخضر الأساسي
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ميثود العنوان (تم تعديل لون النص ليناسب الخلفية البيضاء)
  Widget _buildLabel(String label, {bool isDark = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF666666), 
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ميثود الحقل الأبيض مع ظل خفيف ليعطي شكلاً جمالياً
  Widget _buildInputField(String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F9), // رمادي فاتح جداً للحقول
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        readOnly: true, // لكي يفتح Picker عند الضغط (اختياري)
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          suffixIcon: Icon(icon, color: const Color(0xFF005B5B), size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }
  // ميثود مساعدة لبناء حقول الإدخال في الـ Popup
  Widget _buildPopupField(String hint, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF005B5B), size: 20),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF5F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}