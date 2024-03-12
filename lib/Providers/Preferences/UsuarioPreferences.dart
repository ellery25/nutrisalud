// ignore: file_names
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../UsersProviders.dart';

class UsuarioPreferences {
  static const _keyUsuario = 'usuario';

  // Guardar un usuario en SharedPreferences
  static Future<void> guardarUsuario(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = usuarioToJson(usuario);
    await prefs.setString(_keyUsuario, usuarioJson);
  }

  // Obtener un usuario desde SharedPreferences
  static Future<Usuario?> obtenerUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = prefs.getString(_keyUsuario);

    if (usuarioJson != null) {
      return usuarioFromJson(usuarioJson);
    }

    return null;
  }

  // Convertir un usuario a JSON
  static String usuarioToJson(Usuario usuario) {
    return jsonEncode({
      'nombre': usuario.nombre,
      'usuario': usuario.usuario,
      'contrasena': usuario.contrasena,
      'foto': usuario.foto,
    });
  }

  // Convertir JSON a un usuario
  static Usuario usuarioFromJson(String usuarioJson) {
    final Map<String, dynamic> data = jsonDecode(usuarioJson);
    return Usuario(
      id: data['id'],
      nombre: data['nombre'],
      usuario: data['usuario'],
      contrasena: data['contrasena'],
      foto: data['foto'],
    );
  }
}
