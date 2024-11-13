import 'package:eventify/infraestructuras/models/categoria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final categoriaProvider = ChangeNotifierProvider<CategoriasProvider>((ref) {
  return CategoriasProvider();
});

class CategoriasProvider extends ChangeNotifier {
  List<Categoria> _categorias = [];
  bool _isLoading = false;

  List<Categoria> get categorias => _categorias;
  bool get isLoading => _isLoading;

  Future<void> fetchCategorias() async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('No se pudo obtener el token de autenticación');
      }

      final url =
          Uri.parse('https://eventify.allsites.es/public/api/categories');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] is List) {
          _categorias = List<Categoria>.from(
            responseData['data'].map(
              (categoriaData) => Categoria(
                id: categoriaData['id'],
                name: categoriaData['name'] ?? 'Sin nombre',
                description: categoriaData['description'] ?? 'Sin descripción',
              ),
            ),
          );
        } else {
          throw Exception('Error al recuperar las categorías');
        }
      } else {
        throw Exception('Error en la solicitud: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error al obtener las categorías: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
