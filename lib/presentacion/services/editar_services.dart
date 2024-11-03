import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eventify/presentacion/providers/user_provider.dart';

class EditarServices {
  final WidgetRef ref;

  EditarServices(this.ref);

  Map<String, String> cargarUsuario(int userId) {
    final usuario =
        ref.read(userProvider).usuarios.firstWhere((u) => u.id == userId);

    return {
      'nombre': usuario.name,
      'correo': usuario.email,
      'rol': 'normal',
    };
  }

  Future<bool> guardarCambios({
    required int userId,
    required String nombre,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('No se pudo obtener el token de autenticación');
      }

      final url =
          Uri.parse('https://eventify.allsites.es/public/api/updateUser');

      Map<String, String> body = {
        'id': userId.toString(),
        'name': nombre,
      };

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
