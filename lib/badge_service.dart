// badge_service.dart (الكامل المصحح)

import 'dart:convert';
import 'package:http/http.dart' as http;

class BadgeService {
  static const String _baseUrl = 'http://192.168.43.71';
  
  // المتغيرات العامة للعدادات
  static int alertCount = 0;
  static int notificationCount = 0;
  
  // ✅ دالة واحدة لتحديث كلا العدادين
  static Future<void> refreshBadgeCounts(int patientId) async {
    try {
      print('🟢 Refreshing badge counts for patientId: $patientId');
      
      // 1️⃣ جلب عدد التنبيهات النشطة
      final alertsUrl = Uri.parse('$_baseUrl/api/get_active_alerts_count.php?patient_id=$patientId');
      final alertsResponse = await http.get(alertsUrl);
      
      if (alertsResponse.statusCode == 200) {
        final alertsData = json.decode(alertsResponse.body);
        if (alertsData['success'] == true) {
          alertCount = alertsData['alerts']?.length ?? 0;
          print('🟢 Alert count: $alertCount');
        }
      }
      
      // 2️⃣ جلب عدد الإشعارات (الدعوات المعلقة)
      final notifUrl = Uri.parse('$_baseUrl/api/get_unread_notification_count.php?family_user_id=$patientId');
      final notifResponse = await http.get(notifUrl);
      
      if (notifResponse.statusCode == 200) {
        final notifData = json.decode(notifResponse.body);
        if (notifData['success'] == true) {
          notificationCount = notifData['count'] ?? 0;
          print('🟢 Notification count: $notificationCount');
        }
      }
      
    } catch (e) {
      print('❌ BadgeService error: $e');
    }
  }
  
  // دالة لتحديث عدد التنبيهات فقط
  static Future<void> updateAlertCount(int patientId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/get_active_alerts_count.php?patient_id=$patientId');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          alertCount = data['alerts']?.length ?? 0;
          print('🟢 Alert count updated: $alertCount');
        }
      }
    } catch (e) {
      print('❌ Error updating alert count: $e');
    }
  }
  
  // دالة لتحديث عدد الإشعارات فقط
  static Future<void> updateNotificationCount(int familyUserId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/get_unread_notification_count.php?family_user_id=$familyUserId');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          notificationCount = data['count'] ?? 0;
          print('🟢 Notification count updated: $notificationCount');
        }
      }
    } catch (e) {
      print('❌ Error updating notification count: $e');
    }
  }
  
  // لعمل mark as viewed وتحديث العداد
  static Future<void> markAlertsAsViewed(int patientId) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/api/update_last_viewed.php'),
        body: {
          'user_id': patientId.toString(),
          'type': 'alerts',
        },
      );
      alertCount = 0;
      print('✅ Alerts marked as viewed, count reset to 0');
    } catch (e) {
      print('❌ Error marking alerts: $e');
    }
  }
  
  static Future<void> markNotificationsAsViewed(int patientId) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/api/update_last_viewed.php'),
        body: {
          'user_id': patientId.toString(),
          'type': 'notifications',
        },
      );
      notificationCount = 0;
      print('✅ Notifications marked as viewed, count reset to 0');
    } catch (e) {
      print('❌ Error marking notifications: $e');
    }
  }

  static Future<void> checkVitalsAndUpdateAlerts() async {
    try {
      final url = Uri.parse('$_baseUrl/api/check_vitals_and_alert.php');
      final response = await http.get(url);
      print('🔍 Vitals check: ${response.body}');
    } catch (e) {
      print('❌ Error checking vitals: $e');
    }
  }

  static Future<int> fetchActiveAlertsCount(int familyUserId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/get_active_alerts_count.php?family_user_id=$familyUserId');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['alerts']?.length ?? 0;
        }
      }
    } catch (e) {
      print('❌ Error fetching active alerts: $e');
    }
    return 0;
  }
}