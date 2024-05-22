// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:http/http.dart' as http;

class Nutritionist {
  final String id;
  final String name;
  final String username;
  final String password;
  final String email;
  final String description;
  final String rating;
  final String photo;
  final String? instagram;
  final String? website;
  final String? whatsapp;
  final String skill1;
  final String? skill2;
  final String? skill3;

  Nutritionist({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.email,
    required this.description,
    required this.rating,
    required this.photo,
    this.instagram,
    this.website,
    this.whatsapp,
    required this.skill1,
    this.skill2,
    this.skill3,
  });

  factory Nutritionist.fromJson(Map<String, dynamic> json, String id) {
    return Nutritionist(
      id: id,
      name: json['name'],
      username: json['username'],
      password: json['password'],
      email: json['email'],
      description: json['description'],
      rating: json['rating'],
      photo: json['photo'],
      instagram: json['instagram'],
      website: json['website'],
      whatsapp: json['whatsapp'],
      skill1: json['skill1'],
      skill2: json['skill2'],
      skill3: json['skill3'],
    );
  }

  // HTTP: GET - Bearer token for authorization
  static Future<List<Nutritionist>> getNutricionists(String token) async {
    final response = await http.get(
      Uri.parse('https://flask-jwt-flutter.onrender.com/api/nutritionists'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Si el servidor devuelve una respuesta OK, parseamos el JSON.
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return data.map((e) => Nutritionist.fromJson(e, e['id'])).toList();
      } else {
        throw Exception('No nutricionists found');
      }
    } else {
      // Si la respuesta no es OK, lanzamos un error.
      throw Exception('Failed to load nutricionists');
    }
  }

  //HTTP: GET by ID
  static Future<Map<String, dynamic>> getNutritionistById(
      String id, String token) async {
    final response = await http.get(
      Uri.parse('https://flask-jwt-flutter.onrender.com/api/nutritionists/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Si el servidor devuelve una respuesta OK, parseamos el JSON.
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return data;
      } else {
        throw Exception('No nutricionist found');
      }
    } else {
      // Si la respuesta no es OK, lanzamos un error.
      throw Exception('Failed to load nutricionist');
    }
  }

  // HTTP: POST - Without Token

  /*
  static Future<void> createNutritionist(Nutritionist nutritionist) async {
    final response = await http.post(
      Uri.parse('https://flask-jwt-flutter.onrender.com/api/nutritionists'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': nutritionist.name,
        'username': nutritionist.username,
        'password': nutritionist.password,
        'email': nutritionist.email,
        'description': nutritionist.description,
        'rating': nutritionist.rating,
        'photo': nutritionist.photo,
        'instagram': nutritionist.instagram,
        'website': nutritionist.website,
        'whatsapp': nutritionist.whatsapp,
        'skill1': nutritionist.skill1,
        'skill2': nutritionist.skill2,
        'skill3': nutritionist.skill3,
      }),
    );

    if (response.statusCode != 200) {
      // Si la respuesta no es OK, lanzamos un error.
      throw Exception('Failed to create nutricionist');
    }
  }
*/

// HTTP: POST without token
  static Future<Map<String, dynamic>> createNutricionist(
      Map<String, dynamic> nutricionista) async {
    final response = await http.post(
      Uri.parse(
          'https://flask-jwt-flutter.onrender.com/api/nutritionists/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(nutricionista),
    );

    if (response.statusCode == 201) {
      // Si el servidor devuelve una respuesta OK, parseamos el JSON.
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        print('user creado');
        print(response.body);
        return data;
      } else {
        print(response.body);
        throw Exception('User not created');
      }
    } else {
      // Si la respuesta no es OK, lanzamos un error.
      print(response.body);

      throw Exception('Failed to create usere');
    }
  }

  // HTTP: PUT - Bearer token for authorization
  static Future<void> updateNutricionist(
      Nutritionist nutritionist, String token) async {
    final response = await http.put(
      Uri.parse(
          'https://flask-jwt-flutter.onrender.com/api/nutritionists/${nutritionist.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'name': nutritionist.name,
        'username': nutritionist.username,
        'password': nutritionist.password,
        'email': nutritionist.email,
        'description': nutritionist.description,
        'rating': nutritionist.rating,
        'photo': nutritionist.photo,
        'instagram': nutritionist.instagram,
        'website': nutritionist.website,
        'whatsapp': nutritionist.whatsapp,
        'skill1': nutritionist.skill1,
        'skill2': nutritionist.skill2,
        'skill3': nutritionist.skill3,
      }),
    );

    if (response.statusCode != 200) {
      // Si la respuesta no es OK, lanzamos un error.
      throw Exception('Failed to update nutricionist');
    }
  }

  // HTTP: DELETE - Bearer token for authorization
  static Future<void> deleteNutricionist(String id, String token) async {
    final response = await http.delete(
      Uri.parse('https://flask-jwt-flutter.onrender.com/api/nutritionists/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      // Si la respuesta no es OK, lanzamos un error.
      throw Exception('Failed to delete nutricionist');
    }
  }
}
