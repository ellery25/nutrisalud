// ignore: file_names
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'UsersProviders.dart';

// Modelo Comentario
class Comentario {
  final String id;
  final String contenido;
  final String? foto;
  final String horas;
  final String usuarioId;
  late final String usuario;
  late final String nombre;

  Comentario({
    required this.id,
    required this.contenido,
    this.foto,
    required this.horas,
    required this.usuarioId,
  });

  factory Comentario.fromJson(Map<String, dynamic> json, String id) {
    return Comentario(
      id: id,
      contenido: json['contenido'],
      foto: json['foto'],
      horas: json['horas'],
      usuarioId: json['usuario'],
    );
  }

  static const String baseUrl =
      'https://unilibremovil2-default-rtdb.firebaseio.com/comentarios.json';

  // HTTP: GET
  static Future<List<Comentario>> getComentarios() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<Comentario> comentarios = [];

      data.forEach((key, value) {
        comentarios.add(Comentario.fromJson(value, key));
      });

      // Imprimir comentarios
      /*
      for (var comentario in comentarios) {
        print('ID: ${comentario.id}');
        print('Contenido: ${comentario.contenido}');
        print('Foto: ${comentario.foto ?? 'No hay foto'}');
        print('Horas: ${comentario.horas}');
        print('Usuario ID: ${comentario.usuarioId}');
        print('----------------------');
      }
      */

      for (var comentario in comentarios) {
        try {
          // Obtener el usuario que hizo el comentario
          final usuario = await Usuario.getUsuario(comentario.usuarioId);
          comentario.usuario = usuario['usuario'];
          comentario.nombre = usuario['nombre'];
        } catch (e) {
          print(
              'Error obteniendo usuario para comentario ${comentario.id}: $e');
        }
      }

      return comentarios;
    } else {
      throw Exception('Error en get de comentarios');
    }
  }

  // HTTP: POST
  static Future<void> postComentario(Map<String, dynamic> comentario) async {
    await http.post(Uri.parse(baseUrl), body: jsonEncode(comentario));
  }

  // HTTP: PUT
  static Future<void> putComentario(
      String id, Map<String, dynamic> comentario) async {
    final url = Uri.parse('$baseUrl/$id');
    await http.put(url, body: jsonEncode(comentario));
  }

  // HTTP: DELETE
  static Future<void> deleteComentario(String id) async {
    final url = Uri.parse(id);
    await http.delete(url);
  }
}
