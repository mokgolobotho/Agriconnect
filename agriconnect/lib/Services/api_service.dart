import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl = 'http://192.168.0.189:8000/api';
  //static const String baseUrl = 'http://192.168.254.140:8000/api';


  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String first_name,
    required String last_name,
    required String email,
    required String cellNumber,
    required String password,
    required String dob,
    required String gender,
    required String title,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "first_name": first_name,
          "last_name": last_name,
          "username": username,
          "email": email,
          "cell_number": cellNumber,
          "password": password,
          "dob": dob,
          "gender": gender,
          "title": title,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "error": "Server returned status code ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      return {
        "success": false,
        "error": jsonDecode(response.body)['error'] ?? 'Login failed'
      };
    }
  }

  static Future<Map<String, dynamic>> AddFarm({
    required int owner_id,
    required String name,
    required String suburb,
    required String city,
    required String province,
    required String country,
    required int code,
    required double latitude,
    required double longitude,
    required double length,
    required double width,
    required double approximate_size,
  })async{
    final response = await http.post(
      Uri.parse('$baseUrl/addFarm/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "owner_id": owner_id,
        "name": name,
        "suburb": suburb,
        "city": city,
        "province": province,
        "country": country,
        "code": code,
        "latitude": latitude,
        "longitude": longitude,
        "length": length,
        "width": width,
        "approximate_size": approximate_size,
      }),
    );

    if (response.statusCode == 201){
      return {"success": true, "data": jsonDecode(response.body)};
    }else{
      return {"success": false, "data": jsonDecode(response.body)};
    }
  }

  static Future<Map<String, dynamic>> getUserFarms({
    required int owner_id,
  })async{
    final response = await http.get(
      Uri.parse('$baseUrl/users/farms/$owner_id'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200){
    return {"success": true, "data": jsonDecode(response.body)};
    }else{
    return {"success": false, "data": jsonDecode(response.body)};
    }
  }

  static Future<Map<String, dynamic>> getFarmCrops({
    required int farm_id,
  })async{
    final response = await http.get(
      Uri.parse('$baseUrl/getFarmCrops/$farm_id'),
      headers: {"content-type": "application/json"}
    );

    if(response.statusCode == 200){
      return{"success": true, "data": jsonDecode(response.body)};
    }else{
      return {"success": false, "data": jsonDecode(response.body)};
    }
  }

  static Future<Map<String, dynamic>> AddCrops({
    required int farmId,
    required String name,
    required int quantity,
    required String plantingDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addCrop/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "farm_id": farmId,
          "name": name,
          "quantity": quantity,
          "planting_date": plantingDate,
          //"harvest_date": harvestDate,
          "created_at": DateTime.now().toIso8601String(),
          "updated_at": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {"success": false, "data": jsonDecode(response.body)};
      }
    } catch (e) {
      return {"success": false, "data": {"error": e.toString()}};
    }
  }

  static Future<Map<String, dynamic>> saveFcmToken({
    required int userId,
    required String fcmToken,
    String deviceName = "",
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/saveFcmToken/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "fcm_token": fcmToken,
          "device_name": deviceName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "error": jsonDecode(response.body)["error"] ?? "Failed to save token"
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
  static Future<Map<String, dynamic>> getFarmAlerts({required int farmId}) async {
    final url = Uri.parse("$baseUrl/farms/$farmId/fertility-alerts/");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch farm alerts");
    }
  }

  static Future<Map<String, dynamic>> logoutUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      if (userId == null) {
        return {"success": false, "message": "User ID not found in cache."};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/logout/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId}),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {"success": false, "message": "Logout failed: $e"};
    }
  }

  static Future<Map<String, dynamic>> getCropSensorData(int cropId) async {
    final url = Uri.parse('$baseUrl/sensorData/$cropId/');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load sensor data");
      }
    } catch (e) {
      throw Exception("Error fetching sensor data: $e");
    }
  }
  static Future<Map<String, dynamic>> submitFeedback({
    required int userId,
    required String message,
    required int rating,
  }) async {
    final url = Uri.parse('$baseUrl/feedback/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'message': message,
        'rating': rating,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {'success': false, 'message': 'Failed to send feedback'};
    }
  }

  static Future<Map<String, dynamic>> getUserProfile({required int userId}) async {
    final response = await http.get(Uri.parse('$baseUrl/profile/$userId/'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    required String firstName,
    required String lastName,
    required String phone,
    File? profileImage,
  }) async {
    var uri = Uri.parse('$baseUrl/profile/$userId/');
    var request = http.MultipartRequest('PUT', uri);

    request.fields['first_name'] = firstName;
    request.fields['last_name'] = lastName;
    request.fields['cell_number'] = phone;

    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        profileImage.path,
      ));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      print('Error: ${response.statusCode} ${response.body}');
      return {'success': false, 'message': 'Failed to update profile'};
    }
  }
  static Future<Map<String, dynamic>> getCropRecommendations({required int cropId}) async {
    final url = Uri.parse('$baseUrl/crops/$cropId/fertility-recommendations/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false};
      }
    } catch (e) {
      print("API error: $e");
      return {"success": false};
    }
  }

  static Future<Map<String, dynamic>> getFarmHarvestedCrops({
    required int farm_id,
  })async{
    final response = await http.get(
        Uri.parse('$baseUrl/getFarmHarvestedCrops/$farm_id'),
        headers: {"content-type": "application/json"}
    );

    if(response.statusCode == 200){
      return{"success": true, "data": jsonDecode(response.body)};
    }else{
      return {"success": false, "data": jsonDecode(response.body)};
    }
  }
}
