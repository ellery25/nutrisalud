import 'dart:convert';
import 'package:http/http.dart' as http;

// ProTip Model

class ProTip {
  final String id;
  final String title;
  final String content;
  final String nutritionist_id;

  ProTip({
    required this.id,
    required this.title,
    required this.content,
    required this.nutritionist_id,
  });

  factory ProTip.fromJson(Map<String, dynamic> json, String id) {
    return ProTip(
      id: id,
      title: json['title'],
      content: json['content'],
      nutritionist_id: json['nutritionist_id'],
    );
  }

  // HTTP: GET - Bearer token for authorization
  static Future<List<ProTip>> getProTips(String? token) async {
    final response = await http.get(Uri.parse('https://flask-jwt-flutter.onrender.com/api/professional_tips'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    });

    if(response.statusCode == 200){
      final List<dynamic> data = jsonDecode(response.body);

      if(data.isNotEmpty){
        return data.map((e) {
          if (e['id'] != null) {
            return ProTip.fromJson(e, e['id']);
          } else {
            throw Exception('ProTip id is null');
          }
        }).toList();
      } else {
        throw Exception('No ProTips Found');
      }

    } else {
      throw Exception('Failed to load ProTips');
    }

  }

  //HTTP: GET by ID
  static Future<Map<String, dynamic>> getProTipById(String token, String id) async {
    final response = await http.get(Uri.parse('https://flask-jwt-flutter.onrender.com/api/professional_tips/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    });

    if(response.statusCode == 200){
      final Map<String, dynamic> data = jsonDecode(response.body);
      if(data.isNotEmpty){
        return data;
      } else {
        throw Exception('No ProTip Found');
      }
    } else {
      throw Exception('Failed to load ProTip');
    }

  }

  // HTTP: POST - Bearer token for authorization
  static Future<void> postProTip(String token, ProTip proTip) async {
    final response = await http.post(Uri.parse('https://flask-jwt-flutter.onrender.com/api/professional_tips'),
    headers: <String, String> {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      'title' : proTip.title,
      'content' : proTip.content,
      'nutritionist_id' : proTip.nutritionist_id,
    }));

    if(response.statusCode != 200){
      throw Exception('Failed to post ProTip');
    } else {
      print('ProTip posted');
    }

  }

  // HTTP: DELETE - Bearer token for authorization
  static Future<void> deleteProTip(String token, String id) async {
    final response = await http.delete(Uri.parse('https://flask-jwt-flutter.onrender.com/api/professional_tips/$id'),
    headers: <String, String> {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    });

    if(response.statusCode != 200){
      throw Exception('Failed to delete ProTip');
    } else {
      print('ProTip deleted');
    }

  }

}