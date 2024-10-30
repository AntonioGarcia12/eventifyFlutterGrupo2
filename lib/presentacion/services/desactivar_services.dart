import 'package:eventify/presentacion/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DesactivarServices {
  static Future<void> desactivarUsuario(
      int userId, BuildContext context, WidgetRef ref) async {
    final bool? confirmDeactivate = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Desactivación'),
        content:
            const Text('¿Estás seguro de que deseas desactivar este usuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );

    if (confirmDeactivate != true) {
      return; // El usuario canceló la desactivación
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('No se pudo obtener el token de autenticación'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
        return;
      }

      final url =
          Uri.parse('https://eventify.allsites.es/public/api/deactivate');
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type':
              'application/json', // Asegurarse de que el tipo de contenido sea JSON
        },
        body: jsonEncode({
          'id': userId,
        }),
      );

      if (response.statusCode == 200) {
        // Actualizar el estado del usuario en el proveedor
        ref.read(userProvider).actualizarEstadoUsuario(userId, false);

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exito'),
            content: const Text('Usuario desactivado correctamente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      } else {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(
                'Error al desactivar el usuario: ${response.reasonPhrase}, ${response.body}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Hubo un error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }
}
