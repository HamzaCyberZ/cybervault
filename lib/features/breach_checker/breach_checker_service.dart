import 'dart:convert';
import 'package:http/http.dart' as http;

class BreachModel {
  final String title;
  final String name;
  final String breachDate;
  final String description;
  final List<String> dataClasses;

  BreachModel({
    required this.title,
    required this.name,
    required this.breachDate,
    required this.description,
    required this.dataClasses,
  });

  factory BreachModel.fromJson(Map<String, dynamic> json) {
    return BreachModel(
      title: json['Title'] ?? 'Unknown',
      name: json['Name'] ?? 'unknown',
      breachDate: json['BreachDate'] ?? '',
      description: json['Description'] ?? '',
      dataClasses: List<String>.from(json['DataClasses'] ?? []),
    );
  }
}

class BreachCheckerService {
  static Future<List<BreachModel>> checkEmail(String email) async {
    final url = Uri.parse('https://haveibeenpwned.com/api/v3/breachedaccount/$email?truncateResponse=false');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'CyberVault-Flutter-App',
          // Agar aapke paas HIBP API Key hai, toh yahan add kar sakte hain:
          // 'hibp-api-key': 'YOUR_API_KEY',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => BreachModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        // 404 matlab email breach mein nahi mili (Good news!)
        return [];
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to check email (Code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error checking breaches: ${e.toString()}');
    }
  }
}