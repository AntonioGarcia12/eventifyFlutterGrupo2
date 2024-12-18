import 'package:eventify/infraestructuras/models/usuario.dart';
import 'package:eventify/presentacion/services/users_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final userProvider = ChangeNotifierProvider<UserProvider>((ref) {
  return UserProvider();
});

class UserProvider extends ChangeNotifier {
  List<Usuario> _usuarios = [];
  bool _isLoading = false;

  List<Usuario> get usuarios => _usuarios;
  bool get isLoading => _isLoading;

  final UserServices _userServices = UserServices();

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
            responseData['data']
                .where((userData) => userData['email_verified_at'] != null)
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

  Future<void> fetchUsuario() async {
    if (_usuarios.isNotEmpty) {
      // Si ya se cargaron los usuarios, no vuelvas a cargarlos
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _usuarios = await _userServices.fetchUsuarios();
    } catch (e) {
      print("Error al cargar usuarios: $e");
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearUsuarios() {
    _userServices.clearCachedUsuarios();
    _usuarios = [];
    notifyListeners();
  }

  void eliminarUsuario(int userId) {
    _usuarios.removeWhere((usuario) => usuario.id == userId);
    notifyListeners();
  }
}
