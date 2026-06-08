import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class AlertService {
  
  
  static Future<List<Map<String, dynamic>>> fetchAlerts(int familyUserId) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/get_family_alerts.php?family_user_id=$familyUserId');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['alerts'] != null) {
          return List<Map<String, dynamic>>.from(data['alerts']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching alerts: $e');
      return [];
    }
  }
  
  static Future<bool> acknowledgeAlert(int alertId) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/acknowledge_alert.php');
      final response = await http.post(
        url,
        body: json.encode({'alert_id': alertId}),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error acknowledging alert: $e');
      return false;
    }
  }
}