import 'dart:convert';
import 'package:eventify/infraestructuras/models/categoria.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CategoriasServices {
  Future<List<Categoria>> getCategorias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('No se pudo obtener el token de autenticación');
    }

    final url = Uri.parse('https://eventify.allsites.es/public/api/categories');

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
        return List<Categoria>.from(
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
  }
}
