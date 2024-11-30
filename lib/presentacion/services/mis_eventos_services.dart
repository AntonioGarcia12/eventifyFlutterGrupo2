import 'package:eventify/infraestructuras/models/eventsByUser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MisEventosServices {
  Future<void> unregisterUserFromEvent({
    required int userId,
    required int eventId,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('No se pudo obtener el token de autenticación');
    }

    final url =
        Uri.parse('https://eventify.allsites.es/public/api/unregisterEvent');

    try {
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
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          List<String>? registeredEvents =
              prefs.getStringList('registered_events');
          if (registeredEvents != null) {
            registeredEvents.remove(eventId.toString());
            prefs.setStringList('registered_events', registeredEvents);
          }
        } else {
          throw Exception(
              'Error al eliminar el registro: ${responseData['message']}');
        }
      } else {
        throw Exception(
            'Error al eliminar el registro: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
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
          List<int> eventIds = (responseData['data'] as List)
              .map((event) => event['id'] as int)
              .toList();

          List<String> eventIdsString =
              eventIds.map((id) => id.toString()).toList();
          prefs.setStringList('registered_event_ids', eventIdsString);

          return eventIds;
        } else {
          throw Exception(
              'Error en la respuesta de la API: ${responseData['message']}');
        }
      } else {
        throw Exception(
            'Error al obtener eventos registrados: ${response.reasonPhrase}');
      }
    } catch (e) {
      return [];
    }
  }

  Future<Eventsbyuser?> getEventDetails(int eventId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int? userId = prefs.getInt('id');

      if (token == null) {
        throw Exception('No se pudo obtener el token de autenticación');
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
        body: jsonEncode({'id': userId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          List<dynamic> eventsData = responseData['data'];
          var eventJson = eventsData.firstWhere(
            (event) => event['id'] == eventId,
            orElse: () => null,
          );

          if (eventJson != null) {
            Eventsbyuser event = Eventsbyuser.fromJson(eventJson);
            await prefs.setString(
                'event_description_${event.id}', event.description);
            await prefs.setString('event_location_${event.id}', event.location);

            return event;
          } else {
            throw Exception('Evento con id $eventId no encontrado');
          }
        } else {
          throw Exception('Error en la respuesta: ${responseData['message']}');
        }
      } else {
        throw Exception(
            'Error del servidor (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      return null;
    }
  }
}
