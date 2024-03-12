import 'dart:convert';
import 'package:http/http.dart' as http;

// Modelo Usuario
class Usuario {
  final String nombre;
  final String usuario;
  final String contrasena;
  final String? foto;

  Usuario({
    required this.nombre,
    required this.usuario,
    required this.contrasena,
    this.foto,
  });

  factory Usuario.fromJson(Map<String, dynamic> json, String id) {
    return Usuario(
      nombre: json['nombre'],
      usuario: json['usuario'],
      contrasena: json['contrasena'],
      foto: json['foto'] ?? 'assets/imgs/ProfilePhotos/DefaultUser.jpg',
    );
  }

  static const String baseUrl =
      'https://unilibremovil2-default-rtdb.firebaseio.com/usuarios.json';

  // HTTP: GET
  static Future<List<Usuario>> getUsuarios() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<Usuario> usuarios = [];

      data.forEach((key, value) {
        usuarios.add(Usuario.fromJson(value, key));
      });

      print(usuarios);

      return usuarios;
    } else {
      throw Exception('Error en get de usuarios');
    }
  }

  // HTTP: GET BY ID
  static Future<Map<String, dynamic>> getUsuario(String id) async {
    final response = await http.get(Uri.parse(id));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return data;
      } else {
        throw Exception('Usuario no encontrado');
      }
    } else {
      throw Exception('Error en get de usuario');
    }
  }

  // HTTP: POST
  static Future<void> postUsuario(Map<String, dynamic> usuario) async {
    await http.post(Uri.parse(baseUrl), body: jsonEncode(usuario));
  }

  // HTTP: PUT
  static Future<void> putUsuario(
      String id, Map<String, dynamic> usuario) async {
    final url = Uri.parse('$baseUrl/$id');
    await http.put(url, body: jsonEncode(usuario));
  }

  // HTTP: DELETE
  static Future<void> deleteUsuario(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    await http.delete(url);
  }
}
