// family_notification.dart (الكامل مع Dark Mode والترجمة)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'family_custom_bottom_navbar.dart';
import 'main.dart';
import 'app_translations.dart';

import 'badge_service.dart';
import 'config.dart';

class FamilyNotificationPage extends StatefulWidget {
  final String firstName;
  final int patientId;
  final int? familyUserId;

  const FamilyNotificationPage({
    super.key,
    required this.firstName,
    required this.patientId,
    this.familyUserId,
  });

  @override
  State<FamilyNotificationPage> createState() => _FamilyNotificationPageState();
}

class _FamilyNotificationPageState extends State<FamilyNotificationPage> 
    with SingleTickerProviderStateMixin {
  
  List<Map<String, dynamic>> _invitations = [];
  List<Map<String, dynamic>> _medicationReminders = [];
  List<Map<String, dynamic>> _elderlyList = [];
  bool _isLoading = true;
  bool _isLoadingMedications = true;
  String? _errorMessage;
  
  late TabController _tabController;
  
  

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (widget.familyUserId == null) return;
    
    setState(() {
      _isLoading = true;
      _isLoadingMedications = true;
    });
    
    await Future.wait([
      _fetchInvitations(),
      _fetchMedicationReminders(),
      _fetchElderlyList(),
    ]);
  }

  Future<void> _fetchElderlyList() async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/get_family_elderly.php?family_user_id=${widget.familyUserId}');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['elderly'] != null) {
          setState(() {
            _elderlyList = List<Map<String, dynamic>>.from(data['elderly']);
          });
        }
      }
    } catch (e) {
      print('Error fetching elderly list: $e');
    }
  }

  Future<void> _fetchInvitations() async {
  try {
    final url = Uri.parse('${AppConfig.baseUrl}/api/get_family_invitations.php?family_user_id=${widget.familyUserId}');
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['invitations'] != null) {
        setState(() {
          _invitations = List<Map<String, dynamic>>.from(data['invitations']);
          _isLoading = false;
        });
        
        // ✅ تحديث عدد الإشعارات في BadgeService
        await BadgeService.updateNotificationCount(widget.familyUserId!);
        
      } else {
        setState(() {
          _invitations = [];
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Server error: ${response.statusCode}';
        _isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Connection failed: $e';
      _isLoading = false;
    });
  }
}

  Future<void> _fetchMedicationReminders() async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/get_medication_reminders.php?family_user_id=${widget.familyUserId}');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['reminders'] != null) {
          setState(() {
            _medicationReminders = List<Map<String, dynamic>>.from(data['reminders']);
            _isLoadingMedications = false;
          });
        } else {
          setState(() {
            _medicationReminders = [];
            _isLoadingMedications = false;
          });
        }
      } else {
        setState(() {
          _medicationReminders = [];
          _isLoadingMedications = false;
        });
      }
    } catch (e) {
      print('Error fetching medication reminders: $e');
      setState(() {
        _medicationReminders = [];
        _isLoadingMedications = false;
      });
    }
  }

  Future<void> _respondToInvitation(int invitationId, String status, LanguageProvider lang) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF005B5B)),
        );
      },
    );

    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/respond_invitation.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'invitation_id': invitationId,
          'status': status,
          'family_user_id': widget.familyUserId,
        }),
      );
      
      if (mounted) Navigator.pop(context);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
  await _fetchInvitations();
  
  // ✅ تحديث عدد الإشعارات بعد قبول/رفض الدعوة
  await BadgeService.updateNotificationCount(widget.familyUserId!);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                status == 'accepted' 
                    ? lang.tr('invitation_accepted_success') 
                    : lang.tr('invitation_rejected'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: status == 'accepted' ? Colors.green : Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
          
          if (status == 'accepted') {
            _fetchElderlyList();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? lang.tr('invitation_failed')),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      
      print('Error responding to invitation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${lang.tr('connection_failed')}: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _confirmAcceptInvitation(Map<String, dynamic> invitation, LanguageProvider lang) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            lang.tr('accept_invitation'),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang.tr('accept_invitation_question'),
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.family_restroom, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invitation['person_name'] ?? lang.tr('unknown'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            invitation['relationship'] ?? lang.tr('family'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lang.tr('can_monitor_vitals'),
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(lang.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _respondToInvitation(invitation['id'], 'accepted', lang);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(lang.tr('accept')),
            ),
          ],
        );
      },
    );
  }

  void _confirmRejectInvitation(Map<String, dynamic> invitation, LanguageProvider lang) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            lang.tr('reject_invitation'),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          content: Text(
            '${lang.tr('reject_invitation_question')} ${invitation['person_name'] ?? lang.tr('this_person')}?',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(lang.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _respondToInvitation(invitation['id'], 'rejected', lang);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(lang.tr('reject')),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String? dateTime, LanguageProvider lang) {
    if (dateTime == null) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inMinutes < 1) return lang.tr('just_now');
      if (diff.inMinutes < 60) return '${diff.inMinutes} ${lang.tr('min_ago')}';
      if (diff.inHours < 24) return '${diff.inHours} ${lang.tr('hour_ago')}${diff.inHours > 1 ? 's' : ''}';
      if (diff.inDays < 7) return '${diff.inDays} ${lang.tr('day_ago')}${diff.inDays > 1 ? 's' : ''}';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateTime;
    }
  }

  String _formatTime(String? time) {
    if (time == null) return 'N/A';
    try {
      if (time.length >= 5) {
        return time.substring(0, 5);
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return '✅';
      case 'pending':
        return '⏳';
      case 'rejected':
        return '❌';
      default:
        return '📧';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getRelationIcon(String relationship) {
    switch (relationship.toLowerCase()) {
      case 'son':
        return '👨';
      case 'daughter':
        return '👩';
      case 'mother':
        return '👵';
      case 'father':
        return '👴';
      case 'grandmother':
        return '👵';
      case 'grandfather':
        return '👴';
      default:
        return '👤';
    }
  }

  String _translateRelationship(String relationship, LanguageProvider lang) {
    switch (relationship.toLowerCase()) {
      case 'son': return lang.tr('son');
      case 'daughter': return lang.tr('daughter');
      case 'grandson': return lang.tr('grandson');
      case 'granddaughter': return lang.tr('granddaughter');
      case 'nephew': return lang.tr('nephew');
      case 'niece': return lang.tr('niece');
      case 'cousin': return lang.tr('cousin');
      case 'other': return lang.tr('other');
      default: return relationship;
    }
  }

  Widget _buildInvitationCard(Map<String, dynamic> invitation) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<LanguageProvider>(context);
    final bool isPending = invitation['status'] == 'pending';
    final bool isSent = invitation['type'] == 'sent';
    final String title = isSent ? lang.tr('invitation_sent') : lang.tr('invitation_received');
    final String personName = invitation['person_name'] ?? lang.tr('unknown');
    final String relationship = invitation['relationship'] ?? lang.tr('family');
    final String status = invitation['status'] ?? 'pending';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _getStatusIcon(status),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(invitation['created_at'], lang),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _translateStatus(status, lang),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getRelationIcon(relationship),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            personName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            _translateRelationship(relationship, lang),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                if (isPending && !isSent) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmAcceptInvitation(invitation, lang),
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(lang.tr('accept')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmRejectInvitation(invitation, lang),
                          icon: const Icon(Icons.close, size: 18),
                          label: Text(lang.tr('reject')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _translateStatus(String status, LanguageProvider lang) {
    switch (status.toLowerCase()) {
      case 'accepted': return lang.tr('accepted').toUpperCase();
      case 'pending': return lang.tr('pending').toUpperCase();
      case 'rejected': return lang.tr('rejected').toUpperCase();
      default: return status.toUpperCase();
    }
  }

  Widget _buildMedicationReminderCard(Map<String, dynamic> reminder) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<LanguageProvider>(context);
    final bool isTaken = reminder['taken'] == 1;
    final String elderlyName = reminder['elderly_name'] ?? lang.tr('unknown');
    final String medicationName = reminder['medication_name'] ?? lang.tr('unknown');
    final String dosage = reminder['dosage'] ?? '';
    final String reminderTime = reminder['reminder_time'] ?? '';
    final String instructions = reminder['instructions'] ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isTaken ? Colors.green.shade50 : Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isTaken ? Colors.green : Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isTaken ? Icons.check : Icons.access_time,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.tr('medication_reminder'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        elderlyName,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isTaken ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatTime(reminderTime),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medication,
                        size: 20,
                        color: Color(0xFF005B5B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicationName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                          if (dosage.isNotEmpty)
                            Text(
                              '${lang.tr('dosage')}: $dosage',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                if (instructions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            instructions,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                if (!isTaken) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            backgroundColor: Theme.of(context).cardColor,
                            title: Text(
                              lang.tr('confirm_medication'),
                              style: TextStyle(color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A)),
                            ),
                            content: Text(
                              '$elderlyName ${lang.tr('has_taken_medication')} $medicationName?',
                              style: TextStyle(color: isDarkMode ? Colors.grey.shade300 : Colors.black87),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(lang.tr('not_yet')),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(lang.tr('medication_marked_taken')),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF005B5B),
                                ),
                                child: Text(lang.tr('yes_taken')),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(lang.tr('mark_as_taken')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005B5B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
                        const SizedBox(width: 6),
                        Text(
                          '${lang.tr('taken')} ${_formatDate(reminder['taken_at'], lang)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, String subtitle, {IconData? icon}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.notifications_off_rounded,
              size: 50,
              color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationsList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50),
          child: CircularProgressIndicator(color: Color(0xFF005B5B)),
        ),
      );
    }
    
    final lang = Provider.of<LanguageProvider>(context);
    
    if (_invitations.isEmpty) {
      return _buildEmptyState(
        lang.tr('no_invitations'),
        lang.tr('no_invitations_subtitle'),
        icon: Icons.mail_outline_rounded,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _invitations.length,
      itemBuilder: (context, index) {
        return _buildInvitationCard(_invitations[index]);
      },
    );
  }

  Widget _buildMedicationsList() {
    if (_isLoadingMedications) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50),
          child: CircularProgressIndicator(color: Color(0xFF005B5B)),
        ),
      );
    }
    
    final lang = Provider.of<LanguageProvider>(context);
    
    if (_medicationReminders.isEmpty) {
      return _buildEmptyState(
        lang.tr('no_medication_reminders'),
        lang.tr('no_medication_reminders_subtitle'),
        icon: Icons.medication_outlined,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _medicationReminders.length,
      itemBuilder: (context, index) {
        return _buildMedicationReminderCard(_medicationReminders[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          lang.tr('notifications'),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF005B5B),
          labelColor: const Color(0xFF005B5B),
          unselectedLabelColor: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
          tabs: [
            Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.mail_outline, size: 16),
              const SizedBox(width: 4),
              Text(lang.tr('invitations')),
            ])),
            Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.medication_outlined, size: 16),
              const SizedBox(width: 4),
              Text(lang.tr('medications')),
            ])),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: _fetchData,
            child: _buildInvitationsList(),
          ),
          RefreshIndicator(
            onRefresh: _fetchData,
            child: _buildMedicationsList(),
          ),
        ],
      ),
      bottomNavigationBar: FamilyCustomBottomNavBar(
        currentIndex: 2,
        firstName: widget.firstName,
        patientId: widget.patientId,
        familyUserId: widget.familyUserId,
      ),
    );
  }
}