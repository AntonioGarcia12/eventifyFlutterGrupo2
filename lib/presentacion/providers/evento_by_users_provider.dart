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
  final List<Eventsbyuser> _eventos = [];
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

      if (userIdsTipoU == null) {
        final userServices = UserServices();
        await userServices.saveUsuarioIdsByRoleUToPrefs();
        userIdsTipoU = prefs.getStringList('userIdsTipoU');
      }

      if (userIdsTipoU != null) {
        final url =
            Uri.parse('https://eventify.allsites.es/public/api/eventsByUser');
        _eventos.clear();

        for (String userId in userIdsTipoU) {
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
              final nuevosEventos =
                  data.map((e) => Eventsbyuser.fromJson(e)).toList();

              _eventos.addAll(nuevosEventos);
            }
          }
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Eventsbyuser> getEventosCoincidentes(
      List<Eventsbyorganizador> organizadorEventos) {
    return _eventos.where((userEvento) {
      return organizadorEventos.any((orgEvento) {
        return orgEvento.organizer_id == userEvento.organizer_id;
      });
    }).toList();
  }

  Future<List<Eventsbyuser>> fetchEventosCoincidentes(
      List<Eventsbyorganizador> organizadorEventos) async {
    await fetchEventosForUsuarios();
    return getEventosCoincidentes(organizadorEventos);
  }
}
