import 'dart:convert';
import 'package:eventify/infraestructuras/models/evento.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:eventify/presentacion/providers/evento_provider.dart';

final normalServiceProvider = Provider((ref) => NormalService(ref));

class NormalService {
  // ignore: deprecated_member_use
  final ProviderRef ref;
  String username = 'Usuario';
  NormalService(this.ref);

  Future<void> loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? 'Usuario';
  }

  Future<List<Evento>> fetchEventosNoRegistrados() async {
    final allEventos = await ref.read(eventoProvider).fetchEventos();

    final registeredEventIds = await fetchRegisteredEventIds();

    if (allEventos.isEmpty || registeredEventIds.isEmpty) {
      return allEventos;
    }

    final eventosNoRegistrados = allEventos
        .where((evento) => !registeredEventIds.contains(evento.id))
        .toList();

    return eventosNoRegistrados;
  }

  List<Evento> filterEventosByCategory(List<Evento> eventos, String category) {
    if (category.isEmpty) {
      return eventos;
    }
    return eventos
        .where(
            (evento) => evento.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  Future<void> registerUserToEvent({
    required int userId,
    required int eventId,
    required DateTime registeredAt,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('No se pudo obtener el token de autenticación');
    }

    final url =
        Uri.parse('https://eventify.allsites.es/public/api/registerEvent');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'user_id': userId,
        'event_id': eventId,
        'registered_at': registeredAt.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        ref.read(eventoProvider).removeEvent(eventId);
      } else {
        throw Exception(
            'Error al registrar al evento: ${responseData['message']}');
      }
    } else {
      throw Exception('Error al registrar al evento: ${response.reasonPhrase}');
    }
  }

  Future<List<int>> fetchRegisteredEventIds() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int? userId = prefs.getInt('id');

      if (token == null || userId == null) {
        throw Exception('Token o ID de usuario no encontrados');
      }

      final url =
          Uri.parse('https://eventify.allsites.es/public/api/eventsByUser');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] is List) {
          return (responseData['data'] as List)
              .map((event) => event['id'] as int)
              .toList();
        } else {
          throw Exception('Error en la respuesta de la API');
        }
      } else {
        throw Exception(
            'Error al obtener eventos registrados: ${response.reasonPhrase}');
      }
    } catch (e) {
      return [];
    }
  }
}
