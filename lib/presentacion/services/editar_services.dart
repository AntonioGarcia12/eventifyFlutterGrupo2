import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eventify/presentacion/providers/user_provider.dart';

class EditarServices {
  final WidgetRef ref;

  EditarServices(this.ref);

  // Método para cargar el usuario
  Map<String, String> cargarUsuario(int userId) {
    final usuario =
        ref.read(userProvider).usuarios.firstWhere((u) => u.id == userId);

    return {
      'nombre': usuario.name,
      'correo': usuario.email,
      'rol': usuario.isActive ? 'organizador' : 'normal',
    };
  }

  // Método para guardar los cambios
  Future<bool> guardarCambios({
    required int userId,
    required String nombre,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print('Error: Token de autenticación no disponible');
        throw Exception('No se pudo obtener el token de autenticación');
      }

      final url =
          Uri.parse('https://eventify.allsites.es/public/api/updateUser');

      // Solo enviar el nombre en el body
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
        print('Usuario actualizado exitosamente: ${jsonDecode(response.body)}');
        return true;
      } else {
        print('Error al actualizar el usuario: ${response.reasonPhrase}');
        print('Detalles del error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Hubo un error: $e');
      return false;
    }
  }
}
