import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ServerConfig {
  static const defaultUrl =
      'https://direfully-unreasonable-tomika.ngrok-free.dev/api';
  static const preferenceKey = 'api_server_url';
  static String _baseUrl = defaultUrl;
  static String get baseUrl => _baseUrl;

  static String normalize(String value) {
    var text = value.trim();
    if (text.isEmpty) {
      throw const FormatException('Escribe la dirección del servidor.');
    }
    if (!text.contains('://')) text = 'http://$text';
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        RegExp(r'\s').hasMatch(text) ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.hasPort && (uri.port < 1 || uri.port > 65535))) {
      throw const FormatException(
          'Usa una dirección HTTP o HTTPS válida, sin usuario, parámetros ni #.');
    }
    var path = uri.path.replaceFirst(RegExp(r'/+$'), '');
    if (path.isEmpty) path = '/api';
    return uri.replace(path: path).toString();
  }

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(preferenceKey);
    _baseUrl = defaultUrl;
    if (saved != null) {
      try {
        _baseUrl = normalize(saved);
      } on FormatException {
        // A damaged preference must not prevent the login from opening.
      }
    }
  }

  static Future<void> save(String value) async {
    final url = normalize(value);
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(preferenceKey, url)) {
      throw StateError('No se pudo guardar la dirección.');
    }
    _baseUrl = url;
  }

  static Future<String> probe(String value, {http.Client? client}) async {
    final url = normalize(value);
    final connection = client ?? http.Client();
    try {
      final response = await connection.get(
        Uri.parse('$url/DocumentoEntrada/ObtenerUbicaciones'),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true'
        },
      );
      if (response.statusCode == 401 || response.statusCode == 403) {
        return 'El servidor responde, pero requiere autorización. Verifica el acceso al iniciar sesión.';
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw FormatException(
            'El servidor respondió HTTP ${response.statusCode}. Revisa la dirección y la ruta de la API.');
      }
      final body = jsonDecode(response.body);
      if (body is! List && body is! Map) {
        throw const FormatException(
            'La respuesta no corresponde a una API JSON.');
      }
      return 'Conexión correcta: la API respondió.';
    } finally {
      if (client == null) connection.close();
    }
  }
}
