import 'dart:convert';
import 'package:http/http.dart' as http;

class ValidateJWT {
  final bool valid;

  ValidateJWT({
    required this.valid,
  });

  factory ValidateJWT.fromJson(Map<String, dynamic> json, String valid) {
    return ValidateJWT(valid: json['valid']);
  }

  // HTTP: GET - Bearer token for authorization
  static Future<bool> getValidateJWT(String? token) async {
    final response = await http.get(
        Uri.parse('https://flask-jwt-flutter.onrender.com/api/token'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        });

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);

      if (data['valid'] != null) {
        return data['valid'];
      } else {
        throw Exception('ValidateJWT valid is null');
      }
    } else {
      throw Exception('Failed to load ValidateJWT');
    }
  }
}
