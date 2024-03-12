import 'dart:convert';
import 'package:http/http.dart' as http;

class Nutricionists {
  String contrasena;
  String descripcion;
  String email;
  String foto;
  String? instagram;
  String nombre;
  String skill1;
  String? skill2;
  String? skill3;
  String nutricionist;
  String? whatsapp;
  String website;

  Nutricionists({
    required this.contrasena,
    required this.descripcion,
    required this.email,
    required this.foto,
    this.instagram,
    required this.nombre,
    required this.skill1,
    this.skill2,
    this.skill3,
    required this.nutricionist,
    this.whatsapp,
    required this.website,
  });

  factory Nutricionists.fromJson(Map<String, dynamic> json) => Nutricionists(
        contrasena: json["contrasena"],
        descripcion: json["descripcion"],
        email: json["email"],
        foto: json["foto"],
        instagram: json["instagram"],
        nombre: json["nombre"],
        skill1: json["skill1"],
        skill2: json["skill2"],
        skill3: json["skill3"],
        nutricionist: json["nutricionist"],
        whatsapp: json["whatsapp"],
        website: json["website"],
      );

  static const String baseUrl =
      'https://unilibremovil2-default-rtdb.firebaseio.com/nutricionistas.json';

  // HTTP: GET
  static Future<List<Nutricionists>> getNutricionists() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<Nutricionists> nutricionistas = [];

      data.forEach((key, value) {
        nutricionistas.add(Nutricionists.fromJson(value));
      });

      return nutricionistas;
    } else {
      throw Exception('Error en get de nutricionistas');
    }
  }

  // HTTP: POST
  static Future<void> postNutricionist(
      Map<String, dynamic> nutricionist) async {
    await http.post(Uri.parse(baseUrl), body: jsonEncode(nutricionist));
  }

  // HTTP: PUT
  static Future<void> putNutricionist(
      String id, Map<String, dynamic> nutricionist) async {
    final url = Uri.parse('$baseUrl/$id');
    await http.put(url, body: jsonEncode(nutricionist));
  }

  // HTTP: DELETE
  static Future<void> deleteNutricionist(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    await http.delete(url);
  }
}
