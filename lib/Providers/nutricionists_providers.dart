import 'dart:convert';
import 'package:http/http.dart' as http;

class Nutricionistas {
  final String id;
  String contrasena;
  String descripcion;
  String email;
  String foto;
  String? instagram;
  String nombre;
  String skill_1;
  String? skill_2;
  String? skill_3;
  String? whatsapp;
  String web_site;
  double calificacion;

  Nutricionistas({
    required this.id,
    required this.contrasena,
    required this.descripcion,
    required this.email,
    required this.foto,
    this.instagram,
    required this.nombre,
    required this.skill_1,
    this.skill_2,
    this.skill_3,
    this.whatsapp,
    required this.web_site,
    required this.calificacion,
  });

  factory Nutricionistas.fromJson(Map<String, dynamic> json, String id) {
    return Nutricionistas(
      id: id,
      contrasena: json["contrasena"],
      descripcion: json["descripcion"],
      email: json["email"],
      foto: json["foto"],
      instagram: json["instagram"],
      nombre: json["nombre"],
      skill_1: json["skill_1"],
      skill_2: json["skill_2"],
      skill_3: json["skill_3"],
      whatsapp: json["whatsapp"],
      web_site: json["web_site"],
      calificacion: json["calificacion"].toDouble(),
    );
  }

  static const String baseUrl =
      'https://unilibremovil2-default-rtdb.firebaseio.com/nutricionistas.json';

  // HTTP: GET
  static Future<List<Nutricionistas>> getNutricionistas() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<Nutricionistas> nutricionists = [];

      data.forEach((key, value) {
        nutricionists.add(Nutricionistas.fromJson(value, key));
      });

      print("Nutricionistas cargados correctamente");

      return nutricionists;
    } else {
      throw Exception('Error en get de nutricionistas');
    }
  }

  // HTTP: GET BY ID
  static Future<Map<String, dynamic>> getNutricionista(String id) async {
    final response = await http.get(Uri.parse(id));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return data;
      } else {
        throw Exception('Nutricionista no encontrado');
      }
    } else {
      throw Exception('Error en get de nutricionista');
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
