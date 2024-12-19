import 'package:eventify/infraestructuras/models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserServices {
  List<Usuario>? _cachedUsuarios;

  Future<List<Usuario>> fetchUsuarios() async {
    if (_cachedUsuarios != null) {
      return _cachedUsuarios!;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('No se pudo obtener el token de autenticación');
    }

    final url = Uri.parse('https://eventify.allsites.es/public/api/users');

    int retryCount = 0;
    const maxRetries = 5;
    int delaySeconds = 1;

    while (retryCount < maxRetries) {
      try {
        final response = await http.get(
          url,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          if (responseData['data'] is List) {
            _cachedUsuarios = List<Usuario>.from(
              responseData['data']
                  .where((userData) =>
                      userData['email_verified_at'] != null &&
                      userData['actived'] == 1 &&
                      userData['deleted'] == 0)
                  .map(
                    (userData) => Usuario(
                      id: userData['id'],
                      name: userData['name'] ?? 'Sin nombre',
                      email: userData['email'] ?? 'Sin correo electrónico',
                      role: userData['role'] ?? 'Sin rol',
                      actived: userData['actived'] ?? false,
                      deleted: userData['deleted'] ?? false,
                    ),
                  ),
            );
            return _cachedUsuarios!;
          } else {
            return [];
          }
        } else if (response.statusCode == 429) {
          await Future.delayed(Duration(seconds: delaySeconds));
          retryCount++;
          delaySeconds *= 2;
        } else {
          throw Exception(
              'Error al obtener los usuarios: ${response.reasonPhrase}');
        }
      } catch (e) {
        throw Exception('Error al obtener usuarios: $e');
      }
    }

    throw Exception('Máximo número de reintentos alcanzado');
  }

  void clearCachedUsuarios() {
    _cachedUsuarios = null;
  }

  Future<void> saveUsuarioIdsByRoleUToPrefs() async {
    final usuarios = await fetchUsuarios();
    final ids = usuarios
        .where((usuario) => usuario.role == 'u')
        .map((usuario) => usuario.id.toString())
        .toList();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('userIdsTipoU', ids);
  }
}
