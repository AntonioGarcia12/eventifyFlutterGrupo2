import 'dart:convert';
import 'package:eventify/infraestructuras/models/eventsByOrganizador.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final eventoByOrganizadorProvider =
    ChangeNotifierProvider<EventoByOrganizadorProvider>(
  (ref) => EventoByOrganizadorProvider(),
);

class EventoByOrganizadorProvider extends ChangeNotifier {
  List<Eventsbyorganizador> _eventos = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Eventsbyorganizador> get eventos =>
      _eventos.where((evento) => evento.deleted == 0).toList();

  Future<void> fetchEventosByOrganizador(
      int organizadorId, String token) async {
    _isLoading = true;
    notifyListeners();

    final url =
        Uri.parse('https://eventify.allsites.es/public/api/eventsByOrganizer');
    final headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({"id": organizadorId}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData["success"] == true) {
          final List<dynamic> data = responseData["data"];
          _eventos = data.map((e) => Eventsbyorganizador.fromJson(e)).toList();
        } else {
          throw Exception(responseData["message"]);
        }
      } else {
        throw Exception("Error en la solicitud: ${response.statusCode}");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Eventsbyorganizador> sortEventsByDateAsc() {
    List<Eventsbyorganizador> sortedEventos = List.from(eventos);
    sortedEventos.sort((a, b) {
      final dateA = DateTime.tryParse(a.start_time) ?? DateTime(9999, 12, 31);
      final dateB = DateTime.tryParse(b.start_time) ?? DateTime(9999, 12, 31);
      return dateA.compareTo(dateB);
    });
    return sortedEventos;
  }

  List<Eventsbyorganizador> filterFutureEvents() {
    return eventos.where((evento) {
      try {
        DateTime eventDate = DateTime.parse(evento.start_time);
        return eventDate.isAfter(DateTime.now());
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Future<void> removeEvent(int eventId) async {
    _eventos.removeWhere((evento) => evento.id == eventId);
    notifyListeners();
  }
}
