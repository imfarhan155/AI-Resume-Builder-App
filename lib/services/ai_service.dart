import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/app_config.dart';

class AIService {
  static const String _url = "https://api.groq.com/openai/v1/chat/completions";

  Future<String> suggestCareerObjective({
    required String fullName,
    required String roleHint,
  }) async {
    return _generate(
      "Write a professional 2-3 line ATS-friendly career objective for $fullName targeting the role of $roleHint. Return only plain text.",
    );
  }

  Future<String> suggestSkills({
    required String roleHint,
  }) async {
    return _generate(
      "Generate 10 professional resume skills for a $roleHint. Return comma-separated values only.",
    );
  }

  Future<String> suggestSummary({
    required String experience,
  }) async {
    return _generate(
      "Write a professional 3-4 line resume summary using this experience:\n$experience\nReturn only plain text.",
    );
  }

  Future<String> improveExperience({
    required String experience,
  }) async {
    return _generate(
      "Rewrite the following resume experience professionally using action verbs and measurable impact:\n$experience\nReturn only plain text.",
    );
  }

  Future<String> _generate(String prompt) async {
    final key = AppConfig.groqApiKey.trim();

    if (key.isEmpty) {
      throw Exception("Groq API Key is missing.");
    }

    try {
      final response = await http
          .post(
            Uri.parse(_url),
            headers: {
              "Authorization": "Bearer $key",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "model": "llama-3.3-70b-versatile",
              "messages": [
                {
                  "role": "system",
                  "content": "You are an expert resume writing assistant."
                },
                {"role": "user", "content": prompt}
              ],
              "temperature": 0.8,
              "max_tokens": 300
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data["choices"][0]["message"]["content"];
      }

      throw Exception(
        data["error"]?["message"] ?? "Unknown Groq Error",
      );
    } on SocketException {
      throw Exception("No Internet Connection.");
    } on TimeoutException {
      throw Exception("Request Timeout.");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
