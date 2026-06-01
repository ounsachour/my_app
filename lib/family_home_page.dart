// family_home_page.dart (الكامل مع Dark Mode والترجمة)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'family_custom_bottom_navbar.dart';
import 'family_view_details.dart';
import 'badge_service.dart';
import 'alert_service.dart';
import 'main.dart';
import 'app_translations.dart';
import 'family_notification.dart';

class FamilyHomePage extends StatelessWidget {
  const FamilyHomePage({super.key});




class FamilyHomePage extends StatefulWidget {
  final String firstName;
  final int patientId;
  final int? familyUserId;

  const FamilyHomePage({
    super.key,
    required this.firstName,
    required this.patientId,
    this.familyUserId,
  });

  @override
  State<FamilyHomePage> createState() => _FamilyHomePageState();
}

class _FamilyHomePageState extends State<FamilyHomePage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _elderlyList = [];
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = true;
  bool _isLoadingAlerts = true;
  String? _errorMessage;
  bool _showAlertsPanel = false;

  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  static const String _baseUrl = 'http://192.168.43.71';

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _shakeAnimation = Tween<double>(begin: 0, end: 5).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _fetchElderly();
    _fetchAlerts();
    _refreshBadgeCounts();
    
    // تحديث التنبيهات كل 10 ثواني
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 10));
      if (mounted) {
        _fetchAlerts();
        _refreshBadgeCounts();
        return true;
      }
      return false;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _refreshBadgeCounts() async {
    await BadgeService.refreshBadgeCounts(widget.familyUserId ?? widget.patientId);
    if (mounted) {
      setState(() {});
    }
  }

  bool _hasCriticalAlertForPatient(int patientId) {
    return _alerts.any((alert) => 
      alert['patient_id'] == patientId && 
      alert['severity'] == 'critical'
    );
  }
  
  void _triggerCriticalAlert() {
    if (_shakeController.isCompleted) {
      _shakeController.reset();
    }
    _shakeController.forward();
  }
  
  Widget _buildAnimatedElderlyCard(Map<String, dynamic> elderly) {
    final int elderlyId = int.tryParse(_get(elderly, 'id', defaultVal: '0')) ?? 0;
    bool hasCriticalAlert = _hasCriticalAlertForPatient(elderlyId);
    final String temperature = _get(elderly, 'temperature');
    final String heartRate = _get(elderly, 'heart_rate');
    final String oxygen = _get(elderly, 'oxygen');
    
    bool tempAbnormal = _isVitalAbnormal('temperature', temperature);
    bool hrAbnormal = _isVitalAbnormal('heart_rate', heartRate);
    bool oxygenAbnormal = _isVitalAbnormal('oxygen', oxygen);
    bool hasAbnormal = tempAbnormal || hrAbnormal || oxygenAbnormal;
    
    if (hasCriticalAlert || hasAbnormal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
         _triggerCriticalAlert();
      });
    }
    
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _shakeController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _shakeAnimation.value * (hasCriticalAlert ? 1 : 0),
            0,
          ),
          child: Transform.scale(
            scale: hasAbnormal ? _pulseAnimation.value : 1.0,
            child: Container(
              margin: EdgeInsets.only(
                bottom: 16,
                left: _shakeAnimation.value > 0 ? 3 : 0,
                right: _shakeAnimation.value > 0 ? 3 : 0,
              ),
              child: child,
            ),
          ),
        );
      },
      child: _buildElderlyCard(elderly, hasCriticalAlert),
    );
  }

  Future<void> _fetchAlerts() async {
    if (widget.familyUserId == null) return;
    
    final alerts = await AlertService.fetchAlerts(widget.familyUserId!);
    if (mounted) {
      setState(() {
        _alerts = alerts;
        _isLoadingAlerts = false;
      });
      
      BadgeService.alertCount = alerts.length;
      _refreshBadgeCounts();
    }
  }

  Future<void> _fetchElderly() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse('$_baseUrl/api/get_family_elderly.php?family_user_id=${widget.familyUserId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['elderly'] != null) {
          List<dynamic> elderlyJson = data['elderly'];
          setState(() {
            _elderlyList = elderlyJson.map((e) => Map<String, dynamic>.from(e)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _elderlyList = [];
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

  Future<void> _sendInvitation(String email, String relationship, LanguageProvider lang) async {
    if (widget.familyUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.tr('family_user_id_not_found')), backgroundColor: Colors.red),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.tr('please_enter_valid_email')), backgroundColor: Colors.red),
      );
      return;
    }

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
      final url = Uri.parse('$_baseUrl/api/invite_elderly.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender_id': widget.familyUserId,
          'email': email,
          'relationship': relationship,
        }),
      );

      final data = json.decode(response.body);
      Navigator.pop(context);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(lang.tr('invitation_sent_success'))),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        _fetchElderly();
        _refreshBadgeCounts();
      } else {
        String errorMessage = data['message'] ?? 'invitation_failed';
        if (errorMessage.contains('Elderly not found')) {
          errorMessage = lang.tr('elderly_not_found');
        } else if (errorMessage.contains('already invited')) {
          errorMessage = lang.tr('already_invited');
        } else if (errorMessage.contains('already connected')) {
          errorMessage = lang.tr('already_connected');
        } else {
          errorMessage = lang.tr('invitation_failed');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${lang.tr('connection_failed')}: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showInviteDialog() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController relationshipController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final lang = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 16,
          backgroundColor: Theme.of(context).cardColor,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Theme.of(context).cardColor,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF005B5B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Color(0xFF005B5B),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              lang.tr('invite_elderly'),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      Text(
                        lang.tr('email_address'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                        decoration: InputDecoration(
                          hintText: "elderly@example.com",
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
                          ),
                          prefixIcon: Icon(
                            Icons.email_rounded,
                            color: const Color(0xFF005B5B),
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF005B5B), width: 2),
                          ),
                          filled: true,
                          fillColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return lang.tr('please_enter_email');
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return lang.tr('enter_valid_email');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      Text(
                        lang.tr('relationship'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: null,
                        hint: Text(
                          lang.tr('select_relationship'),
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
                          ),
                        ),
                        dropdownColor: Theme.of(context).cardColor,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.family_restroom_rounded,
                            color: const Color(0xFF005B5B),
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF005B5B), width: 2),
                          ),
                          filled: true,
                          fillColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
                        ),
                        items: [
                          DropdownMenuItem(value: "Son", child: Text(lang.tr('son'))),
                          DropdownMenuItem(value: "Daughter", child: Text(lang.tr('daughter'))),
                          DropdownMenuItem(value: "Grandson", child: Text(lang.tr('grandson'))),
                          DropdownMenuItem(value: "Granddaughter", child: Text(lang.tr('granddaughter'))),
                          DropdownMenuItem(value: "Nephew", child: Text(lang.tr('nephew'))),
                          DropdownMenuItem(value: "Niece", child: Text(lang.tr('niece'))),
                          DropdownMenuItem(value: "Cousin", child: Text(lang.tr('cousin'))),
                          DropdownMenuItem(value: "Other", child: Text(lang.tr('other'))),
                        ],
                        onChanged: (value) {
                          relationshipController.text = value ?? '';
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return lang.tr('please_select_relationship');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              String email = emailController.text.trim();
                              String relationship = relationshipController.text.trim();
                              Navigator.pop(context);
                              await _sendInvitation(email, relationship, lang);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005B5B),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            lang.tr('send_invitation'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                lang.tr('info_note'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _get(Map<String, dynamic> map, String key, {String defaultVal = '--'}) {
    if (map.containsKey(key) && map[key] != null) {
      return map[key].toString();
    }
    return defaultVal;
  }

  bool _isOnline(Map<String, dynamic> elderly) {
    return _get(elderly, 'status').toLowerCase() == 'online';
  }
  
  bool _isVitalAbnormal(String vitalType, String value) {
    if (value == '--' || value.isEmpty) return false;
    
    double numValue = double.tryParse(value) ?? 0;
    
    switch (vitalType) {
      case 'temperature':
        return numValue < 36.0 || numValue > 37.5;
      case 'heart_rate':
        return numValue < 60 || numValue > 100;
      case 'oxygen':
        return numValue < 95;
      default:
        return false;
    }
  }
  
  String _getAbnormalReason(String vitalType, String value, LanguageProvider lang) {
    if (!_isVitalAbnormal(vitalType, value)) return '';
    
    double numValue = double.tryParse(value) ?? 0;
    
    switch (vitalType) {
      case 'temperature':
        if (numValue < 35.0) return ' ${lang.tr('severe_hypothermia')}';
        if (numValue < 36.0) return ' ${lang.tr('low_temperature')}';
        if (numValue > 39.0) return ' ${lang.tr('critical_fever')}';
        if (numValue > 37.5) return ' ${lang.tr('fever')}';
        break;
      case 'heart_rate':
        if (numValue < 50) return ' ${lang.tr('severe_bradycardia')}';
        if (numValue < 60) return ' ${lang.tr('low_heart_rate')}';
        if (numValue > 120) return ' ${lang.tr('critical_tachycardia')}';
        if (numValue > 100) return ' ${lang.tr('high_heart_rate')}';
        break;
      case 'oxygen':
        if (numValue < 90) return ' ${lang.tr('severe_hypoxia')}';
        if (numValue < 95) return ' ${lang.tr('low_oxygen')}';
        break;
    }
    return ' Abnormal';
  }
>>>>>>> e1e9044f60742b3ef5318ebd73c159dc19864415

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final lang = languageProvider;
        
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: _buildHeader(isDarkMode, lang),
                ),
                
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await _fetchElderly();
                      await _fetchAlerts();
                      await _refreshBadgeCounts();
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.tr('elderly_under_care_title'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          if (_isLoading)
                            const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: Color(0xFF005B5B))))
                          else if (_errorMessage != null)
                            _buildErrorCard(isDarkMode, lang)
                          else if (_elderlyList.isEmpty)
                            _buildEmptyCard(isDarkMode, lang)
                          else
                            ..._elderlyList.map((elderly) => _buildAnimatedElderlyCard(elderly)),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: FamilyCustomBottomNavBar(
            currentIndex: 0,
            firstName: widget.firstName,
            patientId: widget.patientId,
            familyUserId: widget.familyUserId,
          ),
        );
      },
    );
  }
  
  Widget _buildHeader(bool isDarkMode, LanguageProvider lang) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: const CircleAvatar(
            radius: 26,
            backgroundImage: AssetImage("assets/elderly-pic.png"),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${lang.tr('hello')}, ${widget.firstName}!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _isLoading ? lang.tr('loading') : "${_elderlyList.length} ${lang.tr('elderly_under_care').toLowerCase()}",
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _buildHeaderButton(
          Icons.person_add_alt_1_rounded,
          showBadge: false,
          onTap: _showInviteDialog,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }
  
  Widget _buildHeaderButton(
    IconData icon, {
    bool showBadge = false,
    int badgeCount = 0,
    VoidCallback? onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: showBadge 
              ? Colors.red.shade50 
              : (isDarkMode ? const Color(0xFF2C2C2C) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                color: showBadge 
                    ? Colors.red 
                    : (isDarkMode ? Colors.white : const Color(0xFF1A1A1A)),
                size: 22,
              ),
            ),
            if (showBadge)
              Positioned(
                right: 8, top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFFFF4848), shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } catch (e) {
      return dateTime;
    }
  }

  Widget _buildElderlyCard(Map<String, dynamic> elderly, [bool hasCriticalAlert = false]) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<LanguageProvider>(context);
    final bool online = _isOnline(elderly);
    final String name = _get(elderly, 'name');
    final String relationship = _get(elderly, 'relationship');
    final String status = _get(elderly, 'status', defaultVal: 'Offline');
    final String temperature = _get(elderly, 'temperature');
    final String heartRate = _get(elderly, 'heart_rate');
    final String oxygen = _get(elderly, 'oxygen');
    final String lastUpdate = _get(elderly, 'last_update', defaultVal: 'N/A');
    final int elderlyId = int.tryParse(_get(elderly, 'id', defaultVal: '0')) ?? 0;
    
    bool tempAbnormal = _isVitalAbnormal('temperature', temperature);
    bool hrAbnormal = _isVitalAbnormal('heart_rate', heartRate);
    bool oxygenAbnormal = _isVitalAbnormal('oxygen', oxygen);
    bool hasAbnormal = tempAbnormal || hrAbnormal || oxygenAbnormal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasCriticalAlert 
              ? Colors.red.shade600 
              : (hasAbnormal ? Colors.red.shade300 : Colors.transparent),
          width: hasCriticalAlert ? 2.5 : (hasAbnormal ? 1.5 : 0),
        ),
        boxShadow: [
          BoxShadow(
            color: hasCriticalAlert 
                ? Colors.red.withOpacity(0.4) 
                : (hasAbnormal ? Colors.red.withOpacity(0.15) : Colors.black.withOpacity(0.06)),
            blurRadius: hasCriticalAlert ? 25 : (hasAbnormal ? 20 : 15),
            spreadRadius: hasCriticalAlert ? 2 : 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hasCriticalAlert 
                  ? _buildAnimatedPatientAvatar(online, hasCriticalAlert)
                  : Container(
                      width: 55, 
                      height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: online ? const Color(0xFF4CAF50) : Colors.grey.shade400, 
                          width: 2,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 25, 
                        backgroundColor: Color(0xFFE0E0E0), 
                        backgroundImage: AssetImage("assets/elderly-pic.png"),
                      ),
                    ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          name, 
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.w700, 
                            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                        if (hasCriticalAlert) ...[
                          _buildBlinkingText(lang.tr('critical'), Colors.red),
                        ] else if (hasAbnormal) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red, 
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              lang.tr('alert'),
                              style: const TextStyle(
                                fontSize: 10, 
                                color: Colors.white, 
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle, 
                              size: 8, 
                              color: online ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              online ? lang.tr('online') : lang.tr('offline'),
                              style: TextStyle(
                                fontSize: 13, 
                                color: online ? const Color(0xFF4CAF50) : Colors.grey.shade500, 
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (relationship.isNotEmpty && relationship != 'N/A') ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF005B5B).withOpacity(0.1), 
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _translateRelationship(relationship, lang),
                              style: const TextStyle(
                                fontSize: 11, 
                                color: Color(0xFF005B5B), 
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => FamilyViewDetailsPage(
                        elderlyName: name, 
                        elderlyId: elderlyId, 
                        temperature: temperature, 
                        heartRate: heartRate, 
                        oxygen: oxygen,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF005B5B).withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lang.tr('view_details'),
                    style: const TextStyle(
                      fontSize: 12, 
                      color: Color(0xFF005B5B), 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
          const SizedBox(height: 20),
          
          Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Color(0xFF005B5B), size: 18),
              const SizedBox(width: 8),
              Text(
                lang.tr('latest_vitals'),
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w600, 
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHealthCard(
                  icon: Icons.thermostat_rounded,
                  value: "$temperature°C",
                  color: tempAbnormal ? Colors.red : const Color(0xFF3A86FF),
                  isAbnormal: tempAbnormal,
                  abnormalReason: _getAbnormalReason('temperature', temperature, lang),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHealthCard(
                  icon: Icons.favorite_rounded,
                  value: "$heartRate bpm",
                  color: hrAbnormal ? Colors.red : const Color(0xFFFF006E),
                  isAbnormal: hrAbnormal,
                  abnormalReason: _getAbnormalReason('heart_rate', heartRate, lang),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHealthCard(
                  icon: Icons.air_rounded,
                  value: "$oxygen%",
                  color: oxygenAbnormal ? Colors.red : const Color(0xFF38B000),
                  isAbnormal: oxygenAbnormal,
                  abnormalReason: _getAbnormalReason('oxygen', oxygen, lang),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500),
              const SizedBox(width: 5),
              Text(
                "${lang.tr('updated')} $lastUpdate",
                style: TextStyle(
                  fontSize: 12, 
                  color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500, 
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  Widget _buildAnimatedPatientAvatar(bool online, bool hasCriticalAlert) {
    if (!hasCriticalAlert) {
      return Container(
        width: 55, height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: online ? const Color(0xFF4CAF50) : Colors.grey.shade400, width: 2),
        ),
        child: const CircleAvatar(radius: 25, backgroundColor: Color(0xFFE0E0E0), backgroundImage: AssetImage("assets/elderly-pic.png")),
      );
    }
    
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 55 + (1 - _pulseAnimation.value) * 10,
          height: 55 + (1 - _pulseAnimation.value) * 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.6 * (1 - _pulseAnimation.value)),
                blurRadius: 15 * (1 - _pulseAnimation.value),
                spreadRadius: 5 * (1 - _pulseAnimation.value),
              ),
            ],
          ),
          child: Container(
            width: 55, height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red, width: 3),
            ),
            child: const CircleAvatar(radius: 25, backgroundColor: Color(0xFFE0E0E0), backgroundImage: AssetImage("assets/elderly-pic.png")),
          ),
        );
      },
    );
  }

  Widget _buildBlinkingText(String text, Color color) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.7 + (_pulseAnimation.value - 1) * 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5 * (1 - (_pulseAnimation.value - 0.5).abs())),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
          ),
        );
      },
    );
  }

  Widget _buildHealthCard({
    required IconData icon,
    required String value,
    required Color color,
    required bool isAbnormal,
    required String abnormalReason,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAbnormal ? Colors.red : color.withOpacity(0.4),
          width: isAbnormal ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isAbnormal ? Colors.red.withOpacity(0.2) : color.withOpacity(0.05),
            blurRadius: isAbnormal ? 20 : 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAbnormal ? Colors.red.withOpacity(0.15) : color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isAbnormal ? Colors.red : color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isAbnormal ? Colors.red : color.withOpacity(0.9),
            ),
          ),
          if (isAbnormal) ...[
            const SizedBox(height: 4),
            Text(
              abnormalReason,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorCard(bool isDarkMode, LanguageProvider lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 70, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(lang.tr('connection_error'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.redAccent)),
          const SizedBox(height: 8),
          Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.grey.shade400 : Colors.black54)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _fetchElderly,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(lang.tr('retry')),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005B5B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(bool isDarkMode, LanguageProvider lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline_rounded, size: 70, color: isDarkMode ? Colors.grey.shade600 : Colors.grey),
          const SizedBox(height: 16),
          Text(
            lang.tr('no_elderly'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.grey.shade400 : Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            lang.tr('no_elderly_subtitle'),
            style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.grey.shade500 : Colors.black45),
          ),
        ],
      ),
    );
  }
}