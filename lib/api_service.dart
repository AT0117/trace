import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String orgId = 'hackathon_team_1';

  static String get backendBaseUrl {
    if (kIsWeb) {
      // Chrome strictly prefers localhost over 127.0.0.1
      return 'http://localhost:8000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://127.0.0.1:8000';
    }
  }

  static Future<Map<String, dynamic>> fetchAIResponse(String question, String role) async {
    final url = '$backendBaseUrl/api/investigate';

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'org_id': orgId, 'question': question, 'role': role}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        final detail = errorBody['detail'] ?? 'Unknown error';
        return {
          "answer_text": "Server Error (${response.statusCode}): $detail",
          "citations": [],
        };
      }
    } catch (e) {
      print("API Error: $e");
      return {
        "answer_text":
            "Connection failed. Please ensure the backend is running at $url.",
        "citations": [],
      };
    }
  }

  // Restored the missing method!
  static Future<Map<String, dynamic>> fetchAnalytics() async {
    final url = '$backendBaseUrl/api/analytics';

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'org_id': orgId}),
          )
          .timeout(const Duration(seconds: 15));

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

  static Future<Map<String, dynamic>> fetchPulse() async {
    final url = '$backendBaseUrl/api/pulse';

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'org_id': orgId}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Pulse API Error: $e");
      return {
        "total_memories": 0,
        "contributors": [],
        "platforms": [],
        "platform_distribution": {},
      };
    }
  }

  static Future<Map<String, dynamic>> fetchTimeline() async {
    final url = '$backendBaseUrl/api/timeline';

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
      print("Timeline API Error: $e");
      return {"timeline": []};
    }
  }

  static Future<Map<String, dynamic>> fetchConflicts() async {
    final url = '$backendBaseUrl/api/conflicts';

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'org_id': orgId}),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Conflicts API Error: $e");
      return {"conflicts": []};
    }
  }

  static Future<Map<String, dynamic>> fetchDecisionDrift(String topic) async {
    final url = '$backendBaseUrl/api/drift';

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'org_id': orgId, 'topic': topic}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Drift API Error: $e");
      return {"nodes": [], "edges": []};
    }
  }

  static Future<Map<String, dynamic>> fetchCatchUp(int days) async {
    final url = '$backendBaseUrl/api/catchup';

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'org_id': orgId, 'days': days}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print("CatchUp API Error: $e");
      return {"cards": []};
    }
  }
}
