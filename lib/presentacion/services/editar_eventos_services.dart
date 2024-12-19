import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditarEventosServices {
  Future<Map<String, dynamic>> updateEvent({
    required int eventId,
    required int organizerId,
    required String title,
    required String description,
    required int categoryId,
    required String startTime,
    required String endTime,
    required String location,
    required String latitude,
    required String longitude,
    required String max_attendees,
    required double price,
    required String imageUrl,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('Token no disponible. Debes iniciar sesión nuevamente.');
    }

    final response = await http.post(
      Uri.parse('https://eventify.allsites.es/public/api/eventUpdate'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': eventId,
        'organizer_id': organizerId,
        'title': title,
        'description': description,
        'category_id': categoryId,
        'start_time': startTime,
        'end_time': endTime,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'max_attendees': max_attendees,
        'price': price,
        'image_url': imageUrl,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'No se pudo editar el evento.');
      }
    } else {
      throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}
