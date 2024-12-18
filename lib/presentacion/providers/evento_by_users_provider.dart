import 'dart:convert';
import 'package:eventify/infraestructuras/models/eventsByOrganizador.dart';
import 'package:eventify/infraestructuras/models/eventsByUser.dart';
import 'package:eventify/presentacion/services/users_services.dart';
import 'package:eventify/presentacion/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final eventoByUserProvider = ChangeNotifierProvider<EventoByUserProvider>(
  (ref) => EventoByUserProvider(),
);

class EventoByUserProvider extends ChangeNotifier {
  List<Eventsbyuser> _eventos = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Eventsbyuser> get eventos => _eventos;

  Future<void> fetchEventosForUsuarios() async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      List<String>? userIdsTipoU = prefs.getStringList('userIdsTipoU');

      if (token == null) {
        throw Exception('No se pudo obtener el token de autenticación.');
      }

      // Asegurarse de que los IDs estén en SharedPreferences
      if (userIdsTipoU == null) {
        print("Cargando IDs de usuarios con rol 'u'...");
        final userServices = UserServices();
        await userServices.saveUsuarioIdsByRoleUToPrefs();
        userIdsTipoU = prefs.getStringList('userIdsTipoU');
      }

      if (userIdsTipoU != null) {
        final url =
            Uri.parse('https://eventify.allsites.es/public/api/eventsByUser');

        // Limpiar la lista de eventos antes de fetch para evitar duplicados
        _eventos.clear();

        for (String userId in userIdsTipoU) {
          int retryCount = 0;
          const maxRetries = 5;
          int delaySeconds = 1;

          while (retryCount < maxRetries) {
            try {
              final response = await http.post(
                url,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $token',
                },
                body: jsonEncode({'id': int.parse(userId)}),
              );

              if (response.statusCode == 200) {
                final responseData = json.decode(response.body);

                if (responseData["success"] == true) {
                  final List<dynamic> data = responseData["data"];

                  // Asegurarse de no agregar eventos duplicados
                  final nuevosEventos =
                      data.map((e) => Eventsbyuser.fromJson(e)).toList();
                  for (var evento in nuevosEventos) {
                    if (!_eventos.any((e) => e.id == evento.id)) {
                      _eventos.add(evento);
                    }
                  }

                  // Imprimir detalles de los eventos
                  for (var evento in nuevosEventos) {
                    print(
                        "Evento: ID=${evento.id}, Categoría=${evento.category_name}, Fecha=${evento.start_time}, OrganizerID=${evento.organizer_id}");
                  }

                  // Salir del loop de reintentos si la solicitud fue exitosa
                  break;
                } else {
                  print("Error en la respuesta: ${responseData["message"]}");
                  break; // No reintentar si la respuesta no es exitosa
                }
              } else if (response.statusCode == 429) {
                // Manejo de rate limiting
                print(
                    "Rate limit alcanzado. Intentando de nuevo en $delaySeconds segundos...");
                await Future.delayed(Duration(seconds: delaySeconds));
                retryCount++;
                delaySeconds *= 2; // Exponencial backoff
              } else {
                print(
                    "Error HTTP ${response.statusCode}: ${response.reasonPhrase}");
                break; // No reintentar otros errores
              }
            } catch (e) {
              print(
                  "Error al cargar eventos para el usuario con ID $userId: $e");
              break; // No reintentar errores de conexión u otros
            }
          }

          if (retryCount == maxRetries) {
            print(
                "Máximo número de reintentos alcanzado para el usuario $userId");
          }

          // Introducir un pequeño retraso entre solicitudes para evitar sobrecarga
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para obtener eventos coincidentes basados en organizer_id
  List<Eventsbyuser> getEventosCoincidentes(
      List<Eventsbyorganizador> organizadorEventos) {
    return _eventos.where((userEvento) {
      return organizadorEventos.any((orgEvento) {
        return orgEvento.organizer_id == userEvento.organizer_id;
      });
    }).toList();
  }

  // Método asíncrono que primero obtiene los eventos y luego los filtra
  Future<List<Eventsbyuser>> fetchEventosCoincidentes(
      List<Eventsbyorganizador> organizadorEventos) async {
    await fetchEventosForUsuarios();
    return getEventosCoincidentes(organizadorEventos);
  }
}
