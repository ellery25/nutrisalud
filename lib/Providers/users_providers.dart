import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nutrisalud/Preferences/save_load.dart';

// User Model

class User {
  final String id;
  final String name;
  final String username;
  final String password;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
  });
  


  factory User.fromJson(Map<String, dynamic> json, String id) {
    return User(
      id: id,
      name: json['name'],
      username: json['username'],
      password: json['password'],
    );
  }

  // HTTP: GET - Bearer token for authorization
  static Future<Map<String, dynamic>> getUsers(String token) async {
    final response = await http.get(
      Uri.parse('https://flask-jwt-flutter.onrender.com/api/users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Si el servidor devuelve una respuesta OK, parseamos el JSON.
      final Map<String, dynamic> data = jsonDecode(response.body);
      if(data.isNotEmpty) {
        return data;
      } else {
        throw Exception('No users found');
      }
    } else {
      // Si la respuesta no es OK, lanzamos un error.
      throw Exception('Failed to load users');
    }
  }

  // HTTP: GET by ID
  static Future<Map<String, dynamic>> getUserById(String token, String id) async {
    final response = await http.get(
      Uri.parse('https://flask-jwt-flutter.onrender.com/api/users/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Si el servidor devuelve una respuesta OK, parseamos el JSON.
      final Map<String, dynamic> data = jsonDecode(response.body);
      if(data.isNotEmpty) {
        return data;
      } else {
        throw Exception('No user found');
      }
    } else {
      // Si la respuesta no es OK, lanzamos un error.
      throw Exception('Failed to load user');
    }
  }

  // HTTP: POST without token
  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> usuario) async {
    final response = await http.post(
      Uri.parse('https://flask-jwt-flutter.onrender.com/api/users/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(usuario),
    );

    if (response.statusCode == 201) {
      // Si el servidor devuelve una respuesta OK, parseamos el JSON.
      final Map<String, dynamic> data = jsonDecode(response.body);
      if(data.isNotEmpty) {
        return data;
      } else {
        throw Exception('User not created');
      }
    } else {
      // Si la respuesta no es OK, lanzamos un error.
      throw Exception('Failed to create user');
    }
  }

  // HTTP: PUT
  static Future<Map<String, dynamic>> updateUser(String token, String id, Map<String, dynamic> usuario) async {
    final response = await http.put(
      Uri.parse('https://flask-jwt-flutter.onrender.com/api/users/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(usuario),
    );

    if (response.statusCode == 200) {
      // Si el servidor devuelve una respuesta OK, parseamos el JSON.
      final Map<String, dynamic> data = jsonDecode(response.body);
      if(data.isNotEmpty) {
        return data;
      } else {
        throw Exception('User not updated');
      }
    } else {
      // Si la respuesta no es OK, lanzamos un error.
      throw Exception('Failed to update user');
    }
  }

  // HTTP: DELETE
  static Future<Map<String, dynamic>> deleteUser(String token, String id) async {
    final response = await http.delete(
      Uri.parse('https://flask-jwt-flutter.onrender.com/api/users/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Si el servidor devuelve una respuesta OK, parseamos el JSON.
      final Map<String, dynamic> data = jsonDecode(response.body);
      if(data.isNotEmpty) {
        return data;
      } else {
        throw Exception('User not deleted');
      }
    } else {
      // Si la respuesta no es OK, lanzamos un error.
      throw Exception('Failed to delete user');
    }
  }

  // LOGIN
  static Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('https://flask-jwt-flutter.onrender.com/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Si el servidor devuelve una respuesta OK, parseamos el JSON.
      await SharedPreferencesHelper.saveData(
          'access_token', jsonDecode(response.body)['access_token']);
      await SharedPreferencesHelper.saveData(
          'type', jsonDecode(response.body)['type']);
      await SharedPreferencesHelper.saveData('userId', jsonDecode(response.body)['user_id']);
    } else {
      // Si la respuesta no es OK, lanzamos un error.
      throw Exception('Failed to login');
    }
  }



}