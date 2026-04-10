import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String backendUrl = 'http://127.0.0.1:8000/api/investigate';
  static const String orgId = 'hackathon_team_1'; // Matches the Discord bot!

  static Future<Map<String, dynamic>> fetchAIResponse(String question) async {
    try {
      final response = await http
          .post(
            Uri.parse(backendUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'org_id': orgId, 'question': question}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print("API Error: $e");
      return {
        "answer_text":
            "Connection failed. Please ensure the backend is running at $backendUrl.",
        "timeline_events": [],
        "citations": [],
      };
    }
  }

  static Future<Map<String, dynamic>> fetchAnalytics() async {
    final url = backendUrl.replaceAll('/investigate', '/analytics');

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'org_id': orgId}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Analytics API Error: $e");
      return {
        "health_score": 0,
        "status": "Error loading",
        "macro_timeline": [],
      };
    }
  }
}
