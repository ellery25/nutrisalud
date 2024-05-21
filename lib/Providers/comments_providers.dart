import 'dart:convert';
import 'package:http/http.dart' as http;


// Comment Model
class Comment {
  final String id;
  final String content;
  final String? photo;
  final String timestamp;
  final String user_id;

  Comment({
    required this.id,
    required this.content,
    this.photo,
    required this.timestamp,
    required this.user_id,
  });

  factory Comment.fromJson(Map<String, dynamic> json, String id) {
    return Comment(
      id: id,
      content: json['content'],
      photo: json['photo'],
      timestamp: json['timestamp'],
      user_id: json['user_id'],
    );
  }


  // HTTP: GET - Bearer token for authorization
  static Future<List<Comment>> getComments(String token) async {
    final response = await http.get(Uri.parse('https://flask-jwt-flutter.onrender.com/api/comments'),
    headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if(response.statusCode == 200){
      final List<dynamic> data = jsonDecode(response.body);

      if(data.isNotEmpty){
        return data.map((e) => Comment.fromJson(e, e['id'])).toList();
      } else {
        throw Exception('No Comments Found');
      }

    } else {
      throw Exception('Failed to load Comments');
    }

  }

  //HTTP: GET by ID - bearer token for authorization
  static Future<Map<String, dynamic>> getCommentById(String token, String id) async {
    final response = await http.get(Uri.parse('https://flask-jwt-flutter.onrender.com/api/comments/$id'),
    headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if(response.statusCode == 200){
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to load Comment');
    }

  }

  // HTTP: POST - Bearer token for authorization
  static Future<http.Response> postComment(Map<String, dynamic> comment, String token) async {
    final response = await http.post(Uri.parse('https://flask-jwt-flutter.onrender.com/api/comments'),
    headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(comment),
    );

    return response;
    
  }
  
  // HTTP: DELETE - Bearer token for authorization
  static Future<void> deleteComment(String id, String token) async {
    final url = Uri.parse('https://flask-jwt-flutter.onrender.com/api/comments/$id');
    await http.delete(url, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
  }

}
