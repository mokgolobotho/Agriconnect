import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ApiService {
  //static const String baseUrl = 'http://192.168.0.117:8000/api';
  static const String baseUrl = 'http://192.168.50.140:8000/api';


  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String first_name,
    required String last_name,
    required String email,
    required String cellNumber,
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
        "password": password,
      }),
    );

    if (response.statusCode == 201) {
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      return {"success": false, "error": jsonDecode(response.body)};
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
    required String harvestDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addCrop/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "farm_id": farmId,
          "name": name,
          "quantity": quantity,
          //"planting_date": plantingDate,
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
}
