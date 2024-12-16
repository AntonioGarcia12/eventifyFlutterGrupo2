import 'dart:convert';

import 'package:eventify/infraestructuras/models/eventsByOrganizador.dart';
import 'package:eventify/presentacion/providers/evento_by_organizador_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final organizadorServiceProvider = Provider((ref) => OrganizadorService(ref));

class OrganizadorService {
  // ignore: deprecated_member_use
  final ProviderRef ref;
  String username = 'Organizador';

  OrganizadorService(this.ref);

  Future<void> loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? 'Usuario';
  }

  Future<void> fetchEventos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? organizadorId = prefs.getInt('id');
    await ref
        .read(eventoByOrganizadorProvider)
        .fetchEventosByOrganizador(organizadorId!, token!);
  }

  Future<List<Eventsbyorganizador>> fetchEventosByOrganizer(
      int organizerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('Token no disponible. Debes iniciar sesión nuevamente.');
    }

    final url =
        Uri.parse('https://eventify.allsites.es/public/api/eventsByOrganizer');
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': organizerId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        List<dynamic> eventsData = data['data'] ?? [];
        List<Eventsbyorganizador> events = eventsData.map((eventJson) {
          return Eventsbyorganizador(
            id: eventJson['id'],
            title: eventJson['title'],
            description: eventJson['description'],
            organizer_id: eventJson['organizer_id'],
            category_name: eventJson['category_name'],
            start_time: eventJson['start_time'],
            end_time: eventJson['end_time'],
            location: eventJson['location'],
            price: eventJson['price'],
            image_url: eventJson['image_url'],
            deleted: eventJson['deleted'],
          );
        }).toList();

        events = events.where((event) => event.deleted == 0).toList();

        if (events.isNotEmpty) {
          await prefs.setInt('evento_id', events.first.id);
        }

        return events;
      } else {
        final message =
            data['message'] ?? 'Error desconocido al obtener eventos';
        throw Exception(message);
      }
    } else {
      throw Exception(
          'Error ${response.statusCode}: No se pudo obtener eventos del organizador.');
    }
  }

  Future<void> deleteEvent(int eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('Token no disponible. Debes iniciar sesión nuevamente.');
    }

    final url =
        Uri.parse('https://eventify.allsites.es/public/api/eventDelete');
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': eventId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return;
      } else {
        final message = data['message'] ?? 'Error desconocido al borrar evento';
        throw Exception(message);
      }
    } else {
      throw Exception(
          'Error ${response.statusCode}: No se pudo eliminar el evento.');
    }
  }
}
