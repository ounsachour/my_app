// family_view_details.dart (الكامل مع Dark Mode)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class FamilyViewDetailsPage extends StatefulWidget {
  final String elderlyName;
  final int elderlyId;
  final String temperature;
  final String heartRate;
  final String oxygen;

  const FamilyViewDetailsPage({
    super.key,
    required this.elderlyName,
    required this.elderlyId,
    required this.temperature,
    required this.heartRate,
    required this.oxygen,
  });

  @override
  State<FamilyViewDetailsPage> createState() => _FamilyViewDetailsPageState();
}

class _FamilyViewDetailsPageState extends State<FamilyViewDetailsPage> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoadingAppointments = true;

  

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/get_elderly_appointments.php?elderly_user_id=${widget.elderlyId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['appointments'] != null) {
          setState(() {
            _appointments = List<Map<String, dynamic>>.from(data['appointments']);
            _isLoadingAppointments = false;
          });
        } else {
          setState(() => _isLoadingAppointments = false);
        }
      } else {
        setState(() => _isLoadingAppointments = false);
      }
    } catch (e) {
      setState(() => _isLoadingAppointments = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDarkMode ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.elderlyName,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PROFILE HEADER
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF005B5B), width: 3),
                      ),
                      child: const CircleAvatar(
                        radius: 60,
                        backgroundColor: Color(0xFFE0E0E0),
                        backgroundImage: AssetImage("assets/elderly-pic.png"),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      widget.elderlyName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Online",
                        style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // APPOINTMENTS SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Appointments",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  if (_appointments.isNotEmpty)
                    Text(
                      "${_appointments.length} total",
                      style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              if (_isLoadingAppointments)
                const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(color: Color(0xFF005B5B))))
              else if (_appointments.isEmpty)
                _buildEmptyAppointments()
              else
                ..._appointments.map((appointment) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAppointmentCard(appointment),
                )),

              const SizedBox(height: 30),

              // ACTION BUTTONS
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.call_rounded, color: Colors.white),
                      label: const Text("Call", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005B5B),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.message_rounded, color: Color(0xFF005B5B)),
                      label: const Text("Message", style: TextStyle(color: Color(0xFF005B5B), fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF005B5B)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyAppointments() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 50, color: isDarkMode ? Colors.grey.shade600 : Colors.grey),
          const SizedBox(height: 12),
          Text(
            "No Appointments",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "No upcoming or past appointments found",
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey.shade500 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final String type = appointment['type'] ?? 'N/A';
    final String typeIcon = appointment['typeIcon'] ?? 'event_note';
    final String doctor = appointment['doctor'] ?? 'N/A';
    final String specialization = appointment['specialization'] ?? 'General';
    final String date = appointment['date'] ?? '';
    final String time = appointment['time'] ?? '';
    final String status = appointment['status'] ?? '';
    final String statusColor = appointment['statusColor'] ?? '#888';
    final String duration = appointment['duration'] ?? '';
    final String notes = appointment['notes'] ?? '';

    IconData iconData;
    switch (typeIcon) {
      case 'health_and_safety': iconData = Icons.health_and_safety_rounded; break;
      case 'loop': iconData = Icons.loop_rounded; break;
      case 'videocam': iconData = Icons.videocam_rounded; break;
      case 'warning': iconData = Icons.warning_rounded; break;
      default: iconData = Icons.event_note_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF005B5B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(iconData, color: const Color(0xFF005B5B), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(int.parse('0xFF${statusColor.replaceAll('#', '')}')).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(int.parse('0xFF${statusColor.replaceAll('#', '')}')),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.calendar_today_rounded, date),
              const SizedBox(width: 16),
              _buildInfoChip(Icons.access_time_rounded, time),
              const SizedBox(width: 16),
              _buildInfoChip(Icons.timer_rounded, duration),
            ],
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notes_rounded, size: 14, color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    notes,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (specialization.isNotEmpty && specialization != 'General') ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.indigo.shade900.withOpacity(0.3) : Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                specialization,
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.indigo.shade300 : Colors.indigo.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Icon(icon, size: 14, color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}