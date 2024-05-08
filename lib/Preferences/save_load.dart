import 'package:shared_preferences/shared_preferences.dart';

/// Clase que proporciona métodos para interactuar con SharedPreferences.
class SharedPreferencesHelper {
  /// Guarda un valor en SharedPreferences asociado a una clave específica.
  ///
  /// Parámetros:
  ///   - key: La clave con la que se asociará el valor.
  ///   - value: El valor a guardar.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// await SharedPreferencesHelper.saveData('mi_clave', 'mi_valor');
  /// ```
  static Future<void> saveData(String key, String value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, value);
  }

  /// Obtiene un valor de SharedPreferences asociado a una clave específica.
  ///
  /// Parámetros:
  ///   - key: La clave del valor a recuperar.
  ///
  /// Retorna:
  ///   El valor asociado a la clave, o null si no se encuentra.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// String? valor = await SharedPreferencesHelper.loadData('mi_clave');
  /// ```
  static Future<String?> loadData(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(key);
  }

  /// Elimina un valor de SharedPreferences asociado a una clave específica.
  ///
  /// Parámetros:
  ///   - key: La clave del valor a eliminar.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// await SharedPreferencesHelper.deleteData('mi_clave');
  /// ```
  static Future<void> deleteData(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove(key);
  }
}
