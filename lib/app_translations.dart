// lib/app_translations.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // General
      'app_title': 'Elderly Care',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'edit': 'Edit',
      'delete': 'Delete',
      'loading': 'Loading...',
      'retry': 'Retry',
      'logout': 'Logout',
      
      // Profile Page
      'profile': 'Profile',
      'personal_info': 'Personal Information',
      'first_name': 'First Name',
      'last_name': 'Last Name',
      'email': 'Email',
      'phone': 'Phone',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'language': 'Language',
      'english': 'English',
      'arabic': 'Arabic',
      'elderly_under_care': 'Elderly Under Care',
      'alert_settings': 'Alert Settings',
      'privacy_security': 'Privacy & Security',
      'help_center': 'Help Center',
      
      // Home Page
      'hello': 'Hello',
      'elderly_under_care_title': 'Elderly Under Care',
      'no_elderly': 'No Elderly Under Care',
      'no_elderly_subtitle': 'Add elderly members to start monitoring',
      'connection_error': 'Connection Error',
      'view_details': 'View Details',
      'latest_vitals': 'Latest Vitals',
      'updated': 'Updated',
      'critical': 'CRITICAL',
      'alert': 'ALERT',
      
      // Alerts Page
      'alerts_center': 'Alerts Center',
      'active': 'Active',
      'history': 'History',
      'no_active_alerts': 'No Active Alerts',
      'no_active_alerts_subtitle': 'All elderly vitals are normal',
      'filter_by_date': 'Filter by Date',
      'select_date': 'Select Date',
      'reset': 'Reset',
      'alert_details': 'Alert Details',
      'patient': 'Patient',
      'severity': 'Severity',
      'message': 'Message',
      'created': 'Created',
      'details': 'Details',
      'resolve': 'Resolve',
      
      // Notifications Page
      'notifications': 'Notifications',
      'invitations': 'Invitations',
      'medications': 'Medications',
      'no_invitations': 'No Invitations',
      'no_invitations_subtitle': 'Invitations from family members will appear here',
      'no_medication_reminders': 'No Medication Reminders',
      'no_medication_reminders_subtitle': 'Medication reminders for elderly under your care will appear here',
      'accept': 'Accept',
      'reject': 'Reject',
      'accept_invitation': 'Accept Invitation',
      'reject_invitation': 'Reject Invitation',
      'medication_reminder': 'Medication Reminder',
      'dosage': 'Dosage',
      'mark_as_taken': 'Mark as Taken',
      'confirm_medication': 'Confirm Medication',
      'taken': 'Taken',
      
      // View Details Page
      'appointments': 'Appointments',
      'no_appointments': 'No Appointments',
      'no_appointments_subtitle': 'No upcoming or past appointments found',
      'call': 'Call',
      'message_text': 'Message',
      'total': 'total',
      
      // Invite Dialog
      'invite_elderly': 'Invite Elderly Member',
      'email_address': 'Email Address',
      'relationship': 'Relationship',
      'send_invitation': 'Send Invitation',
      'info_note': 'The elderly person must be registered in the system with this email.',
      
      // Status
      'online': 'Online',
      'offline': 'Offline',
      'pending': 'Pending',
      'accepted': 'Accepted',
      'rejected': 'Rejected',

      'no_email': 'No email provided',
      'acknowledge': 'Acknowledge',
      'please_enter_email': 'Please enter email',
      'enter_valid_email': 'Enter a valid email',
      'select_relationship': 'Select relationship',
      'please_select_relationship': 'Please select relationship',
      
      'severe_hypoxia': 'Severe Hypoxia',
      'low_oxygen': 'Low Oxygen',
      'critical_tachycardia': 'Critical Tachycardia',
      'high_heart_rate': 'High Heart Rate',
      'severe_bradycardia': 'Severe Bradycardia',
      'low_heart_rate': 'Low Heart Rate',
      'critical_fever': 'Critical Fever',
      'fever': 'Fever',
      'low_temperature': 'Low Temperature',
      'severe_hypothermia': 'Severe Hypothermia',


      'son': 'Son',
'daughter': 'Daughter',
'grandson': 'Grandson',
'granddaughter': 'Granddaughter',
'nephew': 'Nephew',
'niece': 'Niece',
'cousin': 'Cousin',
'other': 'Other',





'family_user_id_not_found': 'Family user ID not found',
'please_enter_valid_email': 'Please enter a valid email',
'invitation_sent_success': 'Invitation sent successfully!',
'invitation_failed': 'Failed to send invitation',
'elderly_not_found': 'Elderly not found! Please make sure the email is registered as a patient.',
'already_invited': 'This elderly has already been invited.',
'already_connected': 'This elderly is already connected to you.',
'connection_failed': 'Connection failed',

'resolved': 'Resolved',
'warning': 'WARNING',
'heart_rate': 'Heart Rate',
'temperature': 'Temperature',
'oxygen': 'Oxygen',
'blood_pressure': 'Blood Pressure',
'normal': 'Normal',
'close': 'Close',

'no_alerts_on': 'No alerts on',
'no_resolved_alerts': 'No Resolved Alerts',
'try_different_date': 'Try selecting a different date',
'resolved_alerts_subtitle': 'Resolved alerts will appear here',



'seek_medical_attention': 'Seek immediate medical attention!',
'administer_oxygen': 'Administer oxygen if available',
'consult_doctor': 'Consult doctor immediately',
'monitor_vital_signs': 'Monitor vital signs closely',
'provide_warm_clothing': 'Provide warm clothing and blankets',

'severe_tachycardia': 'Severe tachycardia',
'fever_reduction': 'Monitor temperature, ensure hydration, consider fever-reducing medication.',
'monitor_hydration': 'Monitor hydration levels',


'invitation_accepted_success': '✓ Invitation accepted successfully!',
'invitation_rejected': '✗ Invitation rejected',
//'accept_invitation': 'Accept Invitation',
'reject_invitation_question': 'Are you sure you want to reject the invitation from',
'accept_invitation_question': 'Do you want to accept this invitation?',
'can_monitor_vitals': 'You will be able to monitor their health vitals.',
//'reject_invitation': 'Reject Invitation',
//'reject_invitation_question': 'Are you sure you want to reject the invitation from %s?',
'this_person': 'this person',
'family': 'Family',
'just_now': 'Just now',
'min_ago': 'min ago',
'hour_ago': 'hour',
'day_ago': 'day',
'invitation_sent': 'Invitation Sent',
'invitation_received': 'Invitation Received',
//'pending': 'Pending',
'unknown': 'Unknown',
//'confirm_medication': 'Confirm Medication',
'has_taken_medication': 'Has %s taken %s?',
'not_yet': 'Not Yet',
'yes_taken': 'Yes, Taken',
'medication_marked_taken': 'Medication marked as taken!',
//'taken': 'Taken',
//'mark_as_taken': 'Mark as Taken',

    },
    'ar': {
      // General
      'app_title': 'رعاية المسنين',
      'ok': 'موافق',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'edit': 'تعديل',
      'delete': 'حذف',
      'loading': 'جاري التحميل...',
      'retry': 'إعادة المحاولة',
      'logout': 'تسجيل الخروج',
      'acknowledge': 'تأكيد',
      'please_enter_email': 'الرجاء إدخال البريد الإلكتروني',
      'enter_valid_email': 'أدخل بريداً إلكترونياً صحيحاً',
      'select_relationship': 'اختر صلة القرابة',
      'please_select_relationship': 'الرجاء اختيار صلة القرابة',
      // Profile Page
      'profile': 'الملف الشخصي',
      'personal_info': 'المعلومات الشخصية',
      'first_name': 'الاسم الأول',
      'last_name': 'الاسم الأخير',
      'email': 'البريد الإلكتروني',
      'phone': 'رقم الهاتف',
      'settings': 'الإعدادات',
      'dark_mode': 'الوضع الداكن',
      'light_mode': 'الوضع الفاتح',
      'language': 'اللغة',
      'english': 'الإنجليزية',
      'arabic': 'العربية',
      'elderly_under_care': 'المسنين تحت الرعاية',
      'alert_settings': 'إعدادات التنبيهات',
      'privacy_security': 'الخصوصية والأمان',
      'help_center': 'مركز المساعدة',
      
      // Home Page
      'hello': 'مرحباً',
      'elderly_under_care_title': 'المسنين تحت الرعاية',
      'no_elderly': 'لا يوجد مسنين تحت الرعاية',
      'no_elderly_subtitle': 'أضف مسنين لبدء المراقبة',
      'connection_error': 'خطأ في الاتصال',
      'view_details': 'عرض التفاصيل',
      'latest_vitals': 'آخر العلامات الحيوية',
      'updated': 'آخر تحديث',
      'critical': 'حرج',
      'alert': 'تنبيه',
      
      // Alerts Page
      'alerts_center': 'مركز التنبيهات',
      'active': 'نشطة',
      'history': 'السجل',
      'no_active_alerts': 'لا توجد تنبيهات نشطة',
      'no_active_alerts_subtitle': 'جميع العلامات الحيوية طبيعية',
      'filter_by_date': 'تصفية حسب التاريخ',
      'select_date': 'اختر تاريخ',
      'reset': 'إعادة تعيين',
      'alert_details': 'تفاصيل التنبيه',
      'patient': 'المريض',
      'severity': 'الخطورة',
      'message': 'الرسالة',
      'created': 'تاريخ الإنشاء',
      'details': 'تفاصيل',
      'resolve': 'تم الحل',
      
      // Notifications Page
      'notifications': 'الإشعارات',
      'invitations': 'الدعوات',
      'medications': 'الأدوية',
      'no_invitations': 'لا توجد دعوات',
      'no_invitations_subtitle': 'ستظهر دعوات أفراد العائلة هنا',
      'no_medication_reminders': 'لا توجد تذكيرات دوائية',
      'no_medication_reminders_subtitle': 'ستظهر تذكيرات الأدوية للمسنين هنا',
      'accept': 'قبول',
      'reject': 'رفض',
      'accept_invitation': 'قبول الدعوة',
      'reject_invitation': 'رفض الدعوة',
      'medication_reminder': 'تذكير دوائي',
      'dosage': 'الجرعة',
      'mark_as_taken': 'تحديد كتم تناول',
      'confirm_medication': 'تأكيد تناول الدواء',
      'taken': 'تم التناول',
      
      // View Details Page
      'appointments': 'المواعيد',
      'no_appointments': 'لا توجد مواعيد',
      'no_appointments_subtitle': 'لا توجد مواعيد قادمة أو سابقة',
      'call': 'اتصال',
      'message_text': 'رسالة',
      'total': 'إجمالي',
      
      // Invite Dialog
      'invite_elderly': 'دعوة مسن',
      'email_address': 'البريد الإلكتروني',
      'relationship': 'صلة القرابة',
      'send_invitation': 'إرسال الدعوة',
      'info_note': 'يجب أن يكون المسن مسجلاً في النظام بهذا البريد الإلكتروني.',
      
      // Status
      'online': 'متصل',
      'offline': 'غير متصل',
      'pending': 'قيد الانتظار',
      'accepted': 'مقبولة',
      'rejected': 'مرفوضة',
      'no_email': 'لا يوجد بريد إلكتروني',

      'severe_hypoxia': 'نقص أكسجين حاد',
      'low_oxygen': 'نقص الأكسجين',
      'critical_tachycardia': 'تسارع نبضات القلب الحرج',
      'high_heart_rate': 'ارتفاع نبضات القلب',
      'severe_bradycardia': 'بطء نبضات القلب الحاد',
      'low_heart_rate': 'انخفاض نبضات القلب',
      'critical_fever': 'حمى حرجة',
      'fever': 'حمى',
      'low_temperature': 'انخفاض درجة الحرارة',
      'severe_hypothermia': 'انخفاض حاد في درجة الحرارة',

      'son': 'ابن',
'daughter': 'ابنة',
'grandson': 'حفيد',
'granddaughter': 'حفيدة',
'nephew': 'ابن الأخ',
'niece': 'بنت الأخ',
'cousin': 'ابن عم',
'other': 'أخرى',

'family_user_id_not_found': 'لم يتم العثور على معرف المستخدم',
'please_enter_valid_email': 'الرجاء إدخال بريد إلكتروني صحيح',
'invitation_sent_success': 'تم إرسال الدعوة بنجاح!',
'invitation_failed': 'فشل إرسال الدعوة',
'elderly_not_found': 'لم يتم العثور على المسن! تأكد من أن البريد الإلكتروني مسجل كمريض.',
'already_invited': 'تم إرسال دعوة لهذا المسن بالفعل.',
'already_connected': 'هذا المسن مرتبط بك بالفعل.',
'connection_failed': 'فشل الاتصال',

'resolved': 'تم الحل',
'warning': 'تحذير',
'heart_rate': 'معدل ضربات القلب',
'temperature': 'درجة الحرارة',
'oxygen': 'الأكسجين',
'blood_pressure': 'ضغط الدم',
'normal': 'طبيعي',
'close': 'إغلاق',

'no_alerts_on': 'لا توجد تنبيهات في',
'no_resolved_alerts': 'لا توجد تنبيهات محلولة',
'try_different_date': 'حاول اختيار تاريخ مختلف',
'resolved_alerts_subtitle': 'ستظهر التنبيهات المحلولة هنا',


'seek_medical_attention': 'اطلب العناية الطبية الفورية!',
'administer_oxygen': 'قدّم الأكسجين إذا كان متوفراً',
'consult_doctor': 'استشر الطبيب فوراً',
'monitor_vital_signs': 'راقب العلامات الحيوية عن كثب',
'provide_warm_clothing': 'وفّر ملابس دافئة وبطانيات',

'severe_tachycardia': 'تسارع شديد في نبضات القلب',
'fever_reduction': 'راقب درجة الحرارة، تأكد من الترطيب، فكر في استخدام خافض للحرارة.',
'monitor_hydration': 'راقب مستويات الترطيب',


'invitation_accepted_success': '✓ تم قبول الدعوة بنجاح!',
'invitation_rejected': '✗ تم رفض الدعوة',
//'accept_invitation': 'قبول الدعوة',
'accept_invitation_question': 'هل تريد قبول هذه الدعوة؟',
'can_monitor_vitals': 'ستتمكن من مراقبة العلامات الحيوية للمسن.',
//'reject_invitation': 'رفض الدعوة',
//'reject_invitation_question': 'هل أنت متأكد من رفض الدعوة من %s؟',
'this_person': 'هذا الشخص',
'family': 'عائلة',
'just_now': 'الآن',
'min_ago': 'دقيقة',
'hour_ago': 'ساعة',
'day_ago': 'يوم',
'invitation_sent': 'تم إرسال الدعوة',
'invitation_received': 'تم استلام الدعوة',
//'pending': 'قيد الانتظار',
'unknown': 'غير معروف',
//'confirm_medication': 'تأكيد تناول الدواء',
'has_taken_medication': 'هل تناول %s دواء %s؟',
'not_yet': 'ليس بعد',
'yes_taken': 'نعم، تم التناول',
'medication_marked_taken': 'تم تحديد الدواء كمتناول!',
//'taken': 'تم التناول',
//'mark_as_taken': 'تحديد كمتناول',

'reject_invitation_question': 'هل أنت متأكد من رفض الدعوة من',
    }
    
  };
  
  static String translate(String key, String languageCode) {
    return _translations[languageCode]?[key] ?? _translations['en']?[key] ?? key;
  }
}

// ==================== Language Provider ====================
class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'en';
  
  String get currentLanguage => _currentLanguage;
  
  LanguageProvider() {
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language_code') ?? 'en';
    notifyListeners();
  }
  
  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    notifyListeners();
  }
  
  String tr(String key) {
    return AppTranslations.translate(key, _currentLanguage);
  }
}