import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.0.117:8000/api';

  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String first_name,
    required String last_name,
    required String email,
    required String cellNumber,
    required String gender,
    required String title,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": first_name,
        "last_name": last_name,
        "username": email,
        "email": email,
        "cell_number": cellNumber,
        "gender": gender,
        "title": title,
        "password": password,
      }),
    );

    if (response.statusCode == 201) {
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      return {"success": false, "error": jsonDecode(response.body)};
    }
  }
}
