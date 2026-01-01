import 'dart:convert';
import 'package:http/http.dart' as http;

class SentimentService {
  static const String apiUrl =
      "https://abcd-1234.ngrok-free.app/analyze";

  static Future<Map<String, dynamic>> analyze(String text) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": text}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Sentiment analysis failed");
    }
  }
}
