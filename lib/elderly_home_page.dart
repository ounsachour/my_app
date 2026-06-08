import 'package:flutter/material.dart';
import 'custom_bottom_navbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'search_page.dart';
import 'vitals_chart_page.dart';
import 'config.dart';

class ElderlyHomePage extends StatefulWidget {

  final String firstName;
  final int patientId;
  final int userId;


  const ElderlyHomePage({
    super.key,
    required this.firstName,
    required this.patientId,
    required this.userId,
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
      int healthScore = 0;

String healthStatus =
    "Normal";

Color healthColor =
    Colors.green;
      Timer? timer;

      String? selectedDoctorId;

      String? selectedDate;

      String? selectedTime;

      String? selectedType;
      final TextEditingController inviteEmailController =
    TextEditingController();

String? selectedRelation;
      List doctors = [];
      List appointments = [];

      final TextEditingController
    doctorController =
        TextEditingController();

final TextEditingController
    dateController =
        TextEditingController();

final TextEditingController
    timeController =
        TextEditingController();

final TextEditingController
    typeController =
        TextEditingController();
      @override
@override
void initState() {
  super.initState();

  getVitals();

  getDoctors();

  getAppointments();

  generateMedicationNotifications();

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
  "${AppConfig.baseUrl}/api/get_patient_vitals.php?patient_id=${widget.patientId}",
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
      
calculateHealthScore();
    }
  }
}
Future<void> getDoctors() async {

  final response = await http.get(

    Uri.parse(
  "${AppConfig.baseUrl}/api/get_patient_doctors.php?patient_id=${widget.patientId}",
),
  );

  if (response.statusCode == 200) {

    final data =
        json.decode(response.body);

    if (data["success"] == true) {

      setState(() {

        doctors = data["data"];
      });
    }
  }
}
Future<void> getAppointments() async {

  final response = await http.get(

    Uri.parse(
  "${AppConfig.baseUrl}/api/get_appointments.php?patient_id=${widget.patientId}",
),
  );

  if (response.statusCode == 200) {

    final data =
        json.decode(response.body);

    if (data["success"] == true) {

      setState(() {

        appointments =
            data["data"];
      });
    }
    await http.get(

  Uri.parse(
    "${AppConfig.baseUrl}/api/generate_appointment_notifications.php?patient_id=${widget.patientId}",
  ),
);
  }
}
Future<void>
generateMedicationNotifications()
async {

  await http.get(

    Uri.parse(
      "${AppConfig.baseUrl}/api/generate_medication_notifications_elderly.php?patient_id=${widget.patientId}",
    ),
  );
}
void calculateHealthScore() {

  int score = 0;

  double hr =
      double.tryParse(
            heartRate,
          ) ??
          0;

  double spo2 =
      double.tryParse(
            oxygen,
          ) ??
          0;

  double temp =
      double.tryParse(
            temperature,
          ) ??
          0;

  // HEART RATE

  if (hr <= 40) {

    score += 3;

  } else if (hr <= 50) {

    score += 1;

  } else if (hr <= 90) {

    score += 0;

  } else if (hr <= 110) {

    score += 1;

  } else if (hr <= 130) {

    score += 2;

  } else {

    score += 3;
  }

  // SPO2

  if (spo2 <= 91) {

    score += 3;

  } else if (spo2 <= 93) {

    score += 2;

  } else if (spo2 <= 95) {

    score += 1;
  }

  // TEMPERATURE

  if (temp <= 35.0) {

    score += 3;

  } else if (temp <= 36.0) {

    score += 1;

  } else if (temp <= 38.0) {

    score += 0;

  } else if (temp <= 39.0) {

    score += 1;

  } else {

    score += 2;
  }

  setState(() {

    healthScore = score;

    if (score >= 7) {

      healthStatus =
          "High Risk";

      healthColor =
          Colors.red;

    } else if (score >= 5) {

      healthStatus =
          "Medium Risk";

      healthColor =
          Colors.orange;

    } else if (score >= 3) {

      healthStatus =
          "Low Risk";

      healthColor =
          Colors.blue;

    } else if (score >= 1) {

      healthStatus =
          "Slightly Elevated";

      healthColor =
          Colors.green;

    } else {

      healthStatus =
          "Normal";

      healthColor =
          Colors.teal;
    }
  });
}
@override
void dispose() {

  timer?.cancel();

  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
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
                  GestureDetector(

  onTap: () {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) =>
            SearchPage(
              patientId: widget.patientId,
            ),
      ),
    );
  },

  child: _buildHeaderButton(
    Icons.search_rounded,
  ),
),
                  const SizedBox(width: 12),
                  // NOTIFICATION BUTTON
                  // INVITATION BUTTON
GestureDetector(

  onTap: () {

    _showInvitationDialog();
  },

  child: _buildHeaderButton(
    Icons.person_add_alt_1_rounded,
  ),
),
                ],
              ),

              const SizedBox(height: 35),
// HEALTH SCORE CARD - يتغير لونه حسب الحالة
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        healthColor,
        healthColor.withOpacity(0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(32),
    boxShadow: [
      BoxShadow(
        color: healthColor.withOpacity(0.3),
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
            Text(
              "$healthScore / 9" ,
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              healthStatus,
              style: const TextStyle(
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
              value: (healthScore / 10).clamp(0.0, 1.0),
              strokeWidth: 10,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            children: [
              Text(
                "$healthScore / 9",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                "Score",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
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

  child: GestureDetector(

    onTap: () {

      Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) =>

              VitalsChartPage(

            patientId:
                widget.patientId,

            vitalType:
                "temperature",
          ),
        ),
      );
    },

    child: buildHealthCard(

      icon:
          Icons.thermostat_rounded,

      value:
          "$temperature°C",

      color:
          const Color(
        0xFF3A86FF,
      ),
    ),
  ),
),
                  const SizedBox(width: 16),
                  Expanded(

  child: GestureDetector(

    onTap: () {

      Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) =>

              VitalsChartPage(

            patientId:
                widget.patientId,

            vitalType:
                "heart_rate",
          ),
        ),
      );
    },

    child: buildHealthCard(

      icon:
          Icons.favorite_rounded,

      value:
          "$heartRate bpm",

      color:
          const Color(
        0xFFFF006E,
      ),
    ),
  ),
),
                  const SizedBox(width: 16),
                  Expanded(

  child: GestureDetector(

    onTap: () {

      Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) =>

              VitalsChartPage(

            patientId:
                widget.patientId,

            vitalType:
                "spo2",
          ),
        ),
      );
    },

    child: buildHealthCard(

      icon:
          Icons.air_rounded,

      value:
          "$oxygen %",

      color:
          const Color(
        0xFF38B000,
      ),
    ),
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
                    "Upcoming Appointments",
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
              appointments.isEmpty

? const Center(

    child: Padding(

      padding: EdgeInsets.only(
        top: 40,
      ),

      child: Text(

        "No appointments yet",

        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
    ),
  )

: Column(

    children:

        appointments.map((appointment) {

      DateTime parsedDate =

    DateTime.parse(

  appointment[
      "appointment_date"],
);

DateTime appointmentDate = DateTime(

  parsedDate.year,
  parsedDate.month,
  parsedDate.day,
);

      DateTime now =
    DateTime.now();

DateTime today = DateTime(

  now.year,
  now.month,
  now.day,
);

      int difference =

            appointmentDate
        .difference(today)
        .inHours ~/ 24;

      Color accentColor;

      if (difference <= 0) {

        accentColor =
            const Color(
          0xFF005B5B,
        );

      } else if (difference == 1) {

        accentColor =
            Colors.blue;

      } else {

        accentColor =
            Colors.orange;
      }

      return _buildTimelineItem(

        title:

            "Dr. ${appointment["first_name"]} ${appointment["last_name"]}",

        subtitle:

            "${appointment["type"]} • ${appointment["status"]}",

        time:

    "${appointment["appointment_date"]}\n${appointment["appointment_time"]}",

        accentColor:
            accentColor,

        icon:
            Icons.calendar_today_rounded,
      );

    }).toList(),
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
  userId: widget.userId,
  unreadNotifications: 0,
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
                DropdownButtonFormField<String>(

  value: selectedDoctorId,

  decoration: InputDecoration(

    filled: true,

    fillColor:
        const Color(0xFFF5F7F9),

    border: OutlineInputBorder(

      borderRadius:
          BorderRadius.circular(
        15,
      ),

      borderSide: BorderSide.none,
    ),

    suffixIcon: const Icon(
      Icons.person_pin_rounded,
      color: Color(0xFF005B5B),
    ),
  ),

  hint: const Text(
    "Select Doctor",
  ),

  items: doctors.map((doctor) {

    return DropdownMenuItem<String>(

      value: doctor["id"].toString(),

      child: Text(

        "Dr. ${doctor["first_name"]} ${doctor["last_name"]}",
      ),
    );
  }).toList(),

  onChanged: (value) {

    setState(() {

      selectedDoctorId = value;
    });
  },
),


                
                // حقل التاريخ
                _buildLabel("Date", isDark: false),
                TextField(

  controller: dateController,

  readOnly: true,

  onTap: () async {

    DateTime? pickedDate =
        await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime.now(),

      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {

      String formattedDate =

          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

      setState(() {

        selectedDate =
            formattedDate;

        dateController.text =
            formattedDate;
      });
    }
  },

  decoration: InputDecoration(

    hintText: "Select Date",

    suffixIcon: const Icon(
      Icons.calendar_today_rounded,
      color: Color(0xFF005B5B),
    ),

    filled: true,

    fillColor:
        const Color(0xFFF5F7F9),

    border: OutlineInputBorder(

      borderRadius:
          BorderRadius.circular(
        15,
      ),

      borderSide: BorderSide.none,
    ),
  ),
),
                
                // حقل الوقت
                _buildLabel("Time", isDark: false),
                TextField(

  controller: timeController,

  readOnly: true,

  onTap: () async {

    TimeOfDay? pickedTime =
        await showTimePicker(

      context: context,

      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {

      final hour =
          pickedTime.hour
              .toString()
              .padLeft(2, '0');

      final minute =
          pickedTime.minute
              .toString()
              .padLeft(2, '0');

      String formattedTime =
          "$hour:$minute:00";

      setState(() {

        selectedTime =
            formattedTime;

        timeController.text =
            formattedTime;
      });
    }
  },

  decoration: InputDecoration(

    hintText: "Select Time",

    suffixIcon: const Icon(
      Icons.access_time_filled_rounded,
      color: Color(0xFF005B5B),
    ),

    filled: true,

    fillColor:
        const Color(0xFFF5F7F9),

    border: OutlineInputBorder(

      borderRadius:
          BorderRadius.circular(
        15,
      ),

      borderSide: BorderSide.none,
    ),
  ),
),
                
                // حقل النوع
                _buildLabel("Type", isDark: false),
                DropdownButtonFormField<String>(

  value: selectedType,

  decoration: InputDecoration(

    filled: true,

    fillColor:
        const Color(0xFFF5F7F9),

    border: OutlineInputBorder(

      borderRadius:
          BorderRadius.circular(
        15,
      ),

      borderSide: BorderSide.none,
    ),

    suffixIcon: const Icon(
      Icons.add_box_rounded,
      color: Color(0xFF005B5B),
    ),
  ),

  hint: const Text(
    "Select Appointment Type",
  ),

  items: const [

    DropdownMenuItem(
      value: "Checkup",
      child: Text("Checkup"),
    ),

    DropdownMenuItem(
      value: "Consultation",
      child: Text("Consultation"),
    ),

    DropdownMenuItem(
      value: "Emergency",
      child: Text("Emergency"),
    ),

    DropdownMenuItem(
      value: "Follow-up",
      child: Text("Follow-up"),
    ),
  ],

  onChanged: (value) {

    setState(() {

      selectedType = value;
    });
  },
),
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
                    onPressed: () async {

  final response = await http.post(

    Uri.parse(
  "${AppConfig.baseUrl}/api/book_appointment.php",
),

    headers: {

      "Content-Type":
          "application/json",
    },

    body: jsonEncode({

      "doctor_id":
          selectedDoctorId,

      "patient_id":
          widget.patientId,

      "appointment_date":
          selectedDate,

      "appointment_time":
          selectedTime,

      "type":
          selectedType,
    }),
  );

  final data =
      jsonDecode(response.body);
      if (data["success"] == true) {

  await http.get(

    Uri.parse(
      "${AppConfig.baseUrl}/api/generate_appointment_notifications.php?patient_id=${widget.patientId}",
    ),
  );
  await getAppointments();
}

  Navigator.pop(context);
  

  ScaffoldMessenger.of(context)
      .showSnackBar(

    SnackBar(

      content:
          Text(data["message"]),

      backgroundColor:

          data["success"] == true

              ? Colors.green

              : Colors.red,
    ),
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
  void _showInvitationDialog() {

  inviteEmailController.clear();

  selectedRelation = null;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {

      return AlertDialog(

        backgroundColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),

        title: Column(
          children: [

            const Icon(
              Icons.person_add_alt_1_rounded,
              color: Color(0xFF005B5B),
              size: 40,
            ),

            const SizedBox(height: 10),

            const Text(
              "Invite Family Member",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),

        content: SingleChildScrollView(

          child: Column(

            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              _buildLabel(
                "Email",
                isDark: false,
              ),

              TextField(

                controller:
                    inviteEmailController,

                decoration: InputDecoration(

                  hintText:
                      "Enter Email",

                  suffixIcon: const Icon(
                    Icons.email_rounded,
                    color: Color(0xFF005B5B),
                  ),

                  filled: true,

                  fillColor:
                      const Color(0xFFF5F7F9),

                  border: OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),

                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              _buildLabel(
                "Relationship",
                isDark: false,
              ),

              DropdownButtonFormField<String>(

                value: selectedRelation,

                decoration: InputDecoration(

                  filled: true,

                  fillColor:
                      const Color(0xFFF5F7F9),

                  border: OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),

                    borderSide:
                        BorderSide.none,
                  ),

                  suffixIcon: const Icon(
                    Icons.family_restroom_rounded,
                    color: Color(0xFF005B5B),
                  ),
                ),

                hint: const Text(
                  "Select Relationship",
                ),

                items: const [

                  DropdownMenuItem(
                    value: "Son",
                    child: Text("Son"),
                  ),

                  DropdownMenuItem(
                    value: "Daughter",
                    child: Text("Daughter"),
                  ),

                  DropdownMenuItem(
                    value: "Brother",
                    child: Text("Brother"),
                  ),

                  DropdownMenuItem(
                    value: "Sister",
                    child: Text("Sister"),
                  ),

                  DropdownMenuItem(
                    value: "Spouse",
                    child: Text("Spouse"),
                  ),
                ],

                onChanged: (value) {

                  setState(() {

                    selectedRelation =
                        value;
                  });
                },
              ),
            ],
          ),
        ),

        actionsPadding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),

        actions: [

          Row(

            children: [

              Expanded(

                child: TextButton(

                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(

                child: ElevatedButton(

                  onPressed: () async {

                    if (inviteEmailController
                            .text
                            .isEmpty ||
                        selectedRelation ==
                            null) {

                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(

                        const SnackBar(
                          content: Text(
                            "Please fill all fields",
                          ),
                        ),
                      );

                      return;
                    }

                    final response =
                        await http.post(

                      Uri.parse(
                        "${AppConfig.baseUrl}/api/send_invitation.php",
                      ),

                      headers: {
                        "Content-Type":
                            "application/json",
                      },

                      body: jsonEncode({

                        "email":
                            inviteEmailController
                                .text
                                .trim(),

                        "relationship":
                            selectedRelation,

                        "sender_id":
                            widget.userId,
                      }),
                    );

                    final data =
                        jsonDecode(
                      response.body,
                    );

                    Navigator.pop(
                      context,
                    );

                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(

                      SnackBar(

                        content: Text(
                          data["message"],
                        ),

                        backgroundColor:

                            data["success"] ==
                                    true
                                ? Colors.green
                                : Colors.red,
                      ),
                    );
                  },

                  style:
                      ElevatedButton.styleFrom(

                    backgroundColor:
                        const Color(
                      0xFF005B5B,
                    ),

                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),

                    elevation: 0,
                  ),

                  child: const Text(
                    "Invite",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
  
}