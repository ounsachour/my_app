// family_profile.dart (الكامل مع Dark Mode والترجمة)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'family_custom_bottom_navbar.dart';
import 'login_page.dart';
import 'main.dart';
import 'app_translations.dart';

class FamilyProfilePage extends StatefulWidget {
  final String firstName;
  final int patientId;
  final int? familyUserId;

  const FamilyProfilePage({
    super.key,
    required this.firstName,
    required this.patientId,
    this.familyUserId,
  });

  @override
  State<FamilyProfilePage> createState() => _FamilyProfilePageState();
}

class _FamilyProfilePageState extends State<FamilyProfilePage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  static const String _baseUrl = 'http://192.168.43.71';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (widget.familyUserId == null) {
      setState(() {
        _errorMessage = 'User ID not found';
        _isLoading = false;
      });
      return;
    }

    try {
      final url = Uri.parse('$_baseUrl/api/get_family_profile.php?user_id=${widget.familyUserId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _profile = Map<String, dynamic>.from(data['profile'] ?? {});
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'User not found';
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

  Future<void> _updateProfile(String field, String value) async {
    if (widget.familyUserId == null) return;

    try {
      final url = Uri.parse('$_baseUrl/api/update_family_profile.php');
      final response = await http.post(url, body: {
        'user_id': widget.familyUserId.toString(),
        'field': field,
        'value': value,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
          );
          _fetchProfile();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? 'Update failed'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showEditDialog(String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    String fieldKey = field.toLowerCase().replaceAll(' ', '_');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: 'Enter new $field',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _updateProfile(fieldKey, controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005B5B)),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final lang = languageProvider;
        
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
              lang.tr('profile'),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          bottomNavigationBar: FamilyCustomBottomNavBar(
            currentIndex: 3,
            firstName: widget.firstName,
            patientId: widget.patientId,
            familyUserId: widget.familyUserId,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF005B5B)))
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 60, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _fetchProfile,
                            icon: const Icon(Icons.refresh),
                            label: Text(lang.tr('retry')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005B5B),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildProfileHeader(lang),
                          const SizedBox(height: 35),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8, bottom: 15),
                                  child: Text(
                                    lang.tr('personal_info'),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ),
                                _buildInfoRow(lang.tr('first_name'), _profile?['first_name'] ?? 'N/A', 
                                    onEdit: () => _showEditDialog(lang.tr('first_name'), _profile?['first_name'] ?? '')),
                                const SizedBox(height: 10),
                                _buildInfoRow(lang.tr('last_name'), _profile?['last_name'] ?? 'N/A',
                                    onEdit: () => _showEditDialog(lang.tr('last_name'), _profile?['last_name'] ?? '')),
                                const SizedBox(height: 10),
                                _buildInfoRow(lang.tr('email'), _profile?['email'] ?? 'N/A'),
                                const SizedBox(height: 10),
                                _buildInfoRow(lang.tr('phone'), _profile?['phone'] ?? 'N/A',
                                    onEdit: () => _showEditDialog(lang.tr('phone'), _profile?['phone'] ?? '')),
                                const SizedBox(height: 20),
                                
                                Padding(
                                  padding: const EdgeInsets.only(left: 8, bottom: 15),
                                  child: Text(
                                    lang.tr('settings'),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ),
                                _buildThemeTile(themeProvider, lang),
                                _buildLanguageTile(languageProvider, lang),
                                _buildMenuTile(Icons.people_rounded, lang.tr('elderly_under_care'), () {}, isDarkMode: isDarkMode),
                                _buildMenuTile(Icons.notifications_none_rounded, lang.tr('alert_settings'), () {}, isDarkMode: isDarkMode),
                                _buildMenuTile(Icons.shield_outlined, lang.tr('privacy_security'), () {}, isDarkMode: isDarkMode),
                                _buildMenuTile(Icons.help_outline_rounded, lang.tr('help_center'), () {}, isDarkMode: isDarkMode),
                                const SizedBox(height: 20),
                                _buildMenuTile(
                                  Icons.logout_rounded, 
                                  lang.tr('logout'),
                                  () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => const LoginPage()),
                                      (route) => false,
                                    );
                                  },
                                  isLogout: true,
                                  isDarkMode: isDarkMode,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildThemeTile(ThemeProvider themeProvider, LanguageProvider lang) {
    final isDarkMode = themeProvider.isDarkMode;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF005B5B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: const Color(0xFF005B5B),
            size: 22,
          ),
        ),
        title: Text(
          isDarkMode ? lang.tr('dark_mode') : lang.tr('light_mode'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: Switch(
          value: isDarkMode,
          onChanged: (value) {
            themeProvider.toggleTheme();
          },
          activeColor: const Color(0xFF005B5B),
          activeTrackColor: const Color(0xFF005B5B).withOpacity(0.5),
        ),
        onTap: () {
          themeProvider.toggleTheme();
        },
      ),
    );
  }

  Widget _buildLanguageTile(LanguageProvider languageProvider, LanguageProvider lang) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF005B5B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.language_rounded, color: Color(0xFF005B5B), size: 22),
        ),
        title: Text(
          lang.tr('language'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          languageProvider.currentLanguage == 'en' 
              ? lang.tr('english') 
              : lang.tr('arabic'),
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        trailing: DropdownButton<String>(
          value: languageProvider.currentLanguage,
          icon: Icon(Icons.arrow_drop_down, color: isDarkMode ? Colors.white : Colors.grey),
          underline: const SizedBox(),
          dropdownColor: Theme.of(context).cardColor,
          items: [
            DropdownMenuItem(
              value: 'en',
              child: Text(
                lang.tr('english'),
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
            DropdownMenuItem(
              value: 'ar',
              child: Text(
                lang.tr('arabic'),
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              languageProvider.setLanguage(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(LanguageProvider lang) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    String firstName = _profile?['first_name'] ?? '';
    String lastName = _profile?['last_name'] ?? '';
    
    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    if (initials.isEmpty) {
      initials = '?';
    }

    return Column(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF005B5B), width: 2),
            ),
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFD700),
                    Color(0xFFFFF176),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005B5B),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          '${_profile?['first_name'] ?? ''} ${_profile?['last_name'] ?? ''}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _profile?['email'] ?? lang.tr('no_email'),
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
            fontSize: 14,
          ),
        ),
        if (_profile?['phone'] != null && _profile?['phone'] != '')
          Text(
            _profile?['phone'] ?? '',
            style: TextStyle(
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
              fontSize: 13,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {VoidCallback? onEdit}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF005B5B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_rounded, color: Color(0xFF005B5B), size: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {
    bool isLogout = false,
    required bool isDarkMode,
  }) {
    Color mainColor = isLogout ? Colors.red : const Color(0xFF005B5B);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
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
            color: isLogout 
                ? Colors.red 
                : (isDarkMode ? Colors.white : Colors.black87),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: isDarkMode ? Colors.grey.shade600 : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}