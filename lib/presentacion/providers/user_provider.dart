import 'package:eventify/infraestructuras/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Definir el ChangeNotifierProvider
final userProvider = ChangeNotifierProvider<UserProvider>((ref) {
  return UserProvider();
});

// Asegúrate de importar o definir la clase Usuario si está en otro archivo

class UserProvider extends ChangeNotifier {
  List<Usuario> _usuarios = [];
  bool _isLoading = false;

  List<Usuario> get usuarios => _usuarios;
  bool get isLoading => _isLoading;

  Future<void> fetchUsuarios() async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('No se pudo obtener el token de autenticación');
      }

      final url = Uri.parse('https://eventify.allsites.es/public/api/users');
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
          _usuarios = List<Usuario>.from(
            responseData['data'].map((userData) => Usuario(
                  id: userData['id'],
                  name: userData['name'] ?? 'Sin nombre',
                  email: userData['email'] ?? 'Sin correo electrónico',
                  isActive:
                      userData['is_active'] ?? false, // Ajusta según tu API
                )),
          );
        }
      } else {
        throw Exception(
            'Error al obtener los usuarios: ${response.reasonPhrase}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void eliminarUsuario(int userId) {
    _usuarios.removeWhere((usuario) => usuario.id == userId);
    notifyListeners(); // Notificar a los widgets que el estado ha cambiado
  }

  // Método para actualizar el estado de activación de un usuario
  void actualizarEstadoUsuario(int userId, bool isActive) {
    int index = _usuarios.indexWhere((usuario) => usuario.id == userId);
    if (index != -1) {
      _usuarios[index].isActive = isActive;
      notifyListeners();
    }
  }
}
