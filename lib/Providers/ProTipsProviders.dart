// ignore: file_names
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'NutricionistsProviders.dart';

// Modelo ProTip
class ProTip {
  final String id;
  final String contenido;
  final String titulo;
  final String nutricionistaId;
  late final String foto;

  ProTip({
    required this.id,
    required this.contenido,
    required this.titulo,
    required this.nutricionistaId,
  });

  factory ProTip.fromJson(Map<String, dynamic> json, String id) {
    return ProTip(
      id: id,
      contenido: json['contenido'],
      titulo: json['titulo'],
      nutricionistaId: json['foto'],
    );
  }

  static const String baseUrl =
      'https://unilibremovil2-default-rtdb.firebaseio.com/profesionalTips.json';

  // HTTP: GET
  static Future<List<ProTip>> getProTips() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<ProTip> proTips = [];

      data.forEach((key, value) {
        proTips.add(ProTip.fromJson(value, key));
      });

      // Imprimir proTips
      for (var proTip in proTips) {
        print('ID: ${proTip.id}');
        print('Titulo: ${proTip.titulo}');
        print('Contenido: ${proTip.contenido}');
        print('Nutricionista ID: ${proTip.nutricionistaId}');
        print('----------------------');
      }

      for (var proTip in proTips) {
        try {
          // Obtener el foto que hizo el proTip
          final foto =
              await Nutricionistas.getNutricionista(proTip.nutricionistaId);
          proTip.foto = foto['foto'];
        } catch (e) {
          print('Error obteniendo foto para proTip ${proTip.id}: $e');
        }
      }

      return proTips;
    } else {
      throw Exception('Error en get de proTips');
    }
  }

  // HTTP: POST
  static Future<void> postProTip(Map<String, dynamic> proTip) async {
    await http.post(Uri.parse(baseUrl), body: jsonEncode(proTip));
  }

  // HTTP: PUT
  static Future<void> putProTip(String id, Map<String, dynamic> proTip) async {
    final url = Uri.parse('$baseUrl/$id');
    await http.put(url, body: jsonEncode(proTip));
  }

  // HTTP: DELETE
  static Future<void> deleteProTip(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    await http.delete(url);
  }
}
