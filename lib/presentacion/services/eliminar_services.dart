import 'dart:convert';

import 'package:eventify/presentacion/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EliminarServices {
  static Future<void> eliminarUsuario(
      int userId, BuildContext context, WidgetRef ref) async {
    final bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text(
            '¿Estás seguro de que deseas eliminar este usuario? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmDelete != true) {
      return; // El usuario canceló la eliminación
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('No se pudo obtener el token de autenticación')),
        );
        return;
      }

      final url =
          Uri.parse('https://eventify.allsites.es/public/api/deleteUser');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'id': userId}),
      );

      if (response.statusCode == 200) {
        // Actualizar el estado del usuario en el proveedor
        ref.read(userProvider).eliminarUsuario(userId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario eliminado correctamente.')),
        );
      } else {
        print('Error: ${response.statusCode}, Cuerpo: ${response.body}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error al eliminar el usuario: ${response.reasonPhrase}, ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hubo un error: $e')),
      );
    }
  }
}
