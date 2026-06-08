// family_alert.dart (الكامل مع Dark Mode والترجمة)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'family_custom_bottom_navbar.dart';
import 'main.dart';
import 'app_translations.dart';
import 'config.dart';

class FamilyAlertPage extends StatefulWidget {
  final String firstName;
  final int patientId;
  final int? familyUserId;

  const FamilyAlertPage({
    super.key,
    required this.firstName,
    required this.patientId,
    this.familyUserId,
  });

  @override
  State<FamilyAlertPage> createState() => _FamilyAlertPageState();
}

class _FamilyAlertPageState extends State<FamilyAlertPage> 
    with SingleTickerProviderStateMixin {
  
  List<Map<String, dynamic>> _activeAlerts = [];
  List<Map<String, dynamic>> _resolvedAlerts = [];
  List<Map<String, dynamic>> _filteredResolvedAlerts = [];
  bool _isLoading = true;
  bool _isLoadingResolved = true;
  String? _errorMessage;
  
  DateTime? _selectedDate;
  
  late TabController _tabController;
  
  

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAlerts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAlerts() async {
    if (widget.familyUserId == null) return;
    
    setState(() {
      _isLoading = true;
      _isLoadingResolved = true;
    });
    
    await Future.wait([
      _fetchActiveAlerts(),
      _fetchResolvedAlerts(),
    ]);
  }

  Future<void> _fetchActiveAlerts() async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/get_family_alerts.php?family_user_id=${widget.familyUserId}');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['alerts'] != null) {
          setState(() {
            _activeAlerts = List<Map<String, dynamic>>.from(data['alerts']);
            _isLoading = false;
          });
        } else {
          setState(() {
            _activeAlerts = [];
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

  Future<void> _fetchResolvedAlerts() async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/get_resolved_alerts.php?family_user_id=${widget.familyUserId}');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['alerts'] != null) {
          setState(() {
            _resolvedAlerts = List<Map<String, dynamic>>.from(data['alerts']);
            _filteredResolvedAlerts = List.from(_resolvedAlerts);
            _isLoadingResolved = false;
          });
        } else {
          setState(() {
            _resolvedAlerts = [];
            _filteredResolvedAlerts = [];
            _isLoadingResolved = false;
          });
        }
      } else {
        setState(() {
          _resolvedAlerts = [];
          _filteredResolvedAlerts = [];
          _isLoadingResolved = false;
        });
      }
    } catch (e) {
      print('Error fetching resolved alerts: $e');
      setState(() {
        _resolvedAlerts = [];
        _filteredResolvedAlerts = [];
        _isLoadingResolved = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedDate == null) {
        _filteredResolvedAlerts = List.from(_resolvedAlerts);
      } else {
        _filteredResolvedAlerts = _resolvedAlerts.where((alert) {
          DateTime alertDate = DateTime.parse(alert['created_at']);
          return alertDate.year == _selectedDate!.year &&
                 alertDate.month == _selectedDate!.month &&
                 alertDate.day == _selectedDate!.day;
        }).toList();
      }
    });
  }

  void _resetFilter() {
    setState(() {
      _selectedDate = null;
      _filteredResolvedAlerts = List.from(_resolvedAlerts);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    await Future.delayed(Duration.zero);
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: Locale(lang.currentLanguage == 'ar' ? 'ar' : 'en'),
      builder: (context, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme(
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
              primary: const Color(0xFF005B5B),
              onPrimary: Colors.white,
              secondary: const Color(0xFF005B5B),
              onSecondary: Colors.white,
              error: Colors.red,
              onError: Colors.white,
              background: isDarkMode ? const Color(0xFF121212) : Colors.white,
              onBackground: isDarkMode ? Colors.white : Colors.black,
              surface: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              onSurface: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _applyFilter();
    }
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
      if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateTime;
    }
  }

  String _formatDateOnly(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return '⚠️';
      case 'warning':
        return '⚡';
      default:
        return 'ℹ️';
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, {bool isResolved = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<LanguageProvider>(context);
    final bool isCritical = alert['severity'] == 'critical';
    final String patientName = alert['patient_name'] ?? 'Unknown Patient';
    final String message = alert['message'] ?? 'Abnormal vital sign detected';
    final String createdAt = alert['created_at'];
    final String? resolvedAt = alert['resolved_at'] ?? alert['acknowledged_at'];
    final String? recommendedAction = alert['recommended_action'];
    final String? vitalSign = alert['vital_sign'];
    final String? vitalValue = alert['vital_value'];
    final String? normalRange = alert['normal_range'];
    
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
              color: _getSeverityColor(alert['severity']).withOpacity(0.1),
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
                    color: _getSeverityColor(alert['severity']),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _getSeverityIcon(alert['severity']),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            patientName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(alert['severity']),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _translateSeverity(alert['severity'], lang),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isResolved && resolvedAt != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          lang.tr('resolved'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
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
                Text(
                   _translateAlertMessage(message, lang),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
                
                if (vitalSign != null && vitalValue != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getVitalIcon(vitalSign),
                          size: 20,
                          color: isCritical ? Colors.red.shade700 : Colors.orange.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getVitalName(vitalSign, lang),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$vitalValue (${lang.tr('normal')}: $normalRange)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isCritical ? Colors.red.shade700 : Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                if (recommendedAction != null && recommendedAction.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCritical ? Colors.red.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 18,
                          color: isCritical ? Colors.red.shade700 : Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _translateRecommendedAction(recommendedAction, lang),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isCritical ? Colors.red.shade700 : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                if (!isResolved) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => _buildAlertDetailsDialog(alert),
                            );
                          },
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: Text(lang.tr('details')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            side: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (resolvedAt != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 14, color: Colors.green.shade600),
                        const SizedBox(width: 6),
                        Text(
                          '${lang.tr('resolved')} ${_formatDate(resolvedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w500,
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

  String _translateSeverity(String severity, LanguageProvider lang) {
    switch (severity.toLowerCase()) {
      case 'critical': return lang.tr('critical');
      case 'warning': return lang.tr('warning');
      default: return severity.toUpperCase();
    }
  }

  String _translateAlertMessage(String message, LanguageProvider lang) {
  if (message.contains('Severe hypoxia')) {
    return lang.tr('severe_hypoxia');
  }
  if (message.contains('Critical tachycardia')) {
    return lang.tr('critical_tachycardia');
  }
  if (message.contains('Fever')) {
    return lang.tr('fever');
  }
  if (message.contains('Low oxygen')) {
    return lang.tr('low_oxygen');
  }
  if (message.contains('High heart rate')) {
    return lang.tr('high_heart_rate');
  }
  if (message.contains('Low temperature')) {
    return lang.tr('low_temperature');
  }
  if (message.contains('Severe Hypothermia')) {
    return lang.tr('severe_hypothermia');
  }
  if (message.contains('Severe Bradycardia')) {
    return lang.tr('severe_bradycardia');
  }
  return message;
}

String _translateRecommendedAction(String action, LanguageProvider lang) {
  if (action.contains('Seek immediate medical attention')) {
    return lang.tr('seek_medical_attention');
  }
  if (action.contains('Administer oxygen')) {
    return lang.tr('administer_oxygen');
  }
  if (action.contains('Consult doctor')) {
    return lang.tr('consult_doctor');
  }
  if (action.contains('Monitor vital signs')) {
    return lang.tr('monitor_vital_signs');
  }
  if (action.contains('Provide warm clothing')) {
    return lang.tr('provide_warm_clothing');
  }
  return action;
}

  IconData _getVitalIcon(String vitalSign) {
    switch (vitalSign.toLowerCase()) {
      case 'heart_rate':
        return Icons.favorite_rounded;
      case 'temperature':
        return Icons.thermostat_rounded;
      case 'spo2':
      case 'oxygen':
        return Icons.air_rounded;
      case 'blood_pressure':
        return Icons.speed_rounded;
      default:
        return Icons.monitor_heart_rounded;
    }
  }

  String _getVitalName(String vitalSign, LanguageProvider lang) {
    switch (vitalSign.toLowerCase()) {
      case 'heart_rate':
        return lang.tr('heart_rate');
      case 'temperature':
        return lang.tr('temperature');
      case 'spo2':
      case 'oxygen':
        return lang.tr('oxygen');
      case 'blood_pressure':
        return lang.tr('blood_pressure');
      default:
        return vitalSign;
    }
  }

  Widget _buildAlertDetailsDialog(Map<String, dynamic> alert) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<LanguageProvider>(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).cardColor,
      title: Row(
        children: [
          Text(
            _getSeverityIcon(alert['severity']),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              lang.tr('alert_details'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow(lang.tr('patient'), alert['patient_name'] ?? 'Unknown', isDarkMode),
            const SizedBox(height: 12),
            _buildDetailRow(lang.tr('severity'), _translateSeverity(alert['severity'] ?? 'unknown', lang), isDarkMode),
            const SizedBox(height: 12),
            _buildDetailRow(lang.tr('message'), alert['message'] ?? 'No message', isDarkMode),
            const SizedBox(height: 12),
            _buildDetailRow(lang.tr('created'), _formatDate(alert['created_at']), isDarkMode),
            if (alert['vital_sign'] != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(lang.tr('vital_sign'), _getVitalName(alert['vital_sign'], lang), isDarkMode),
            ],
            if (alert['vital_value'] != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(lang.tr('vital_value'), alert['vital_value'], isDarkMode),
            ],
            if (alert['normal_range'] != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(lang.tr('normal_range'), alert['normal_range'], isDarkMode),
            ],
            if (alert['recommended_action'] != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(lang.tr('recommended_action'), alert['recommended_action'], isDarkMode),
            ],
            if (alert['resolved_at'] != null || alert['acknowledged_at'] != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(lang.tr('resolved_at'), _formatDate(alert['resolved_at'] ?? alert['acknowledged_at']), isDarkMode),
            ],
            if (alert['resolved_by'] != null || alert['acknowledged_by'] != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(lang.tr('resolved_by'), alert['resolved_by'] ?? alert['acknowledged_by'] ?? 'System', isDarkMode),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(lang.tr('close')),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
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

  Widget _buildActiveAlertsList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50),
          child: CircularProgressIndicator(color: Color(0xFF005B5B)),
        ),
      );
    }
    
    final lang = Provider.of<LanguageProvider>(context);
    
    if (_activeAlerts.isEmpty) {
      return _buildEmptyState(
        lang.tr('no_active_alerts'),
        lang.tr('no_active_alerts_subtitle'),
        icon: Icons.check_circle_outline_rounded,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _activeAlerts.length,
      itemBuilder: (context, index) {
        return _buildAlertCard(_activeAlerts[index]);
      },
    );
  }

  Widget _buildFilterSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<LanguageProvider>(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt_rounded, size: 20, color: const Color(0xFF005B5B)),
              const SizedBox(width: 8),
              Text(
                lang.tr('filter_by_date'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              if (_selectedDate != null)
                TextButton(
                  onPressed: _resetFilter,
                  child: Text(
                    lang.tr('reset'),
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: _selectedDate != null 
                    ? const Color(0xFF005B5B).withOpacity(0.1) 
                    : (isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey.shade50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedDate != null 
                      ? const Color(0xFF005B5B) 
                      : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: _selectedDate != null ? const Color(0xFF005B5B) : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? _formatDateOnly(_selectedDate)
                          : lang.tr('select_date'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                        color: _selectedDate != null 
                            ? const Color(0xFF005B5B) 
                            : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                    ),
                  ),
                  if (_selectedDate != null)
                    Icon(Icons.check_circle, size: 16, color: const Color(0xFF005B5B)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolvedAlertsList() {
    final lang = Provider.of<LanguageProvider>(context);
    
    if (_isLoadingResolved) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50),
          child: CircularProgressIndicator(color: Color(0xFF005B5B)),
        ),
      );
    }
    
    return Column(
      children: [
        _buildFilterSection(),
        
        Expanded(
          child: _filteredResolvedAlerts.isEmpty
              ? _buildEmptyState(
                  _selectedDate != null
                      ? '${lang.tr('no_alerts_on')} ${_formatDateOnly(_selectedDate)}'
                      : lang.tr('no_resolved_alerts'),
                  _selectedDate != null
                      ? lang.tr('try_different_date')
                      : lang.tr('resolved_alerts_subtitle'),
                  icon: _selectedDate != null
                      ? Icons.calendar_today_rounded
                      : Icons.history_rounded,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filteredResolvedAlerts.length,
                  itemBuilder: (context, index) {
                    return _buildAlertCard(_filteredResolvedAlerts[index], isResolved: true);
                  },
                ),
        ),
      ],
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
          lang.tr('alerts_center'),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF005B5B),
          labelColor: const Color(0xFF005B5B),
          unselectedLabelColor: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
          tabs: [
            Tab(child: Text(lang.tr('active'))),
            Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.history, size: 16),
              const SizedBox(width: 4),
              Text(lang.tr('history')),
            ])),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: _fetchAlerts,
            child: _buildActiveAlertsList(),
          ),
          RefreshIndicator(
            onRefresh: _fetchAlerts,
            child: _buildResolvedAlertsList(),
          ),
        ],
      ),
      bottomNavigationBar: FamilyCustomBottomNavBar(
        currentIndex: 1,
        firstName: widget.firstName,
        patientId: widget.patientId,
        familyUserId: widget.familyUserId,
      ),
    );
  }
}