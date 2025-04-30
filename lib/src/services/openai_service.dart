import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _apiKey = 'API GOES HERE'; 
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<Map<String, List<String>>> getDietPlan(String bmiCategory) async {
    final prompt = '''
    Provide a diet plan for a person who falls under the "$bmiCategory" BMI category. 
    Return the response in a structured JSON format like:
    {
      "Breakfast": ["item1", "item2"],
      "Lunch": ["item1", "item2"],
      "Dinner": ["item1", "item2"],
      "Snacks": ["item1", "item2"]
    }
    ''';

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "You are a dietitian assistant."},
          {"role": "user", "content": prompt}
        ],
        "max_tokens": 200,
        "temperature": 0.3,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];

      try {
        return Map<String, List<String>>.from(
            jsonDecode(content).map((key, value) => MapEntry(key, List<String>.from(value))));
      } catch (e) {
        print("Error parsing diet plan: $e");
        return {};
      }
    } else {
      print("Failed to fetch diet plan: ${response.body}");
      return {};
    }
  }
}
