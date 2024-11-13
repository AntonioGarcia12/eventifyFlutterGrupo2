import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eventify/infraestructuras/models/evento.dart';

final eventoProvider = ChangeNotifierProvider<EventoProvider>((ref) {
  return EventoProvider();
});

class EventoProvider extends ChangeNotifier {
  List<Evento> _eventos = [];
  bool _isLoading = false;

  List<Evento> get eventos => _eventos;
  bool get isLoading => _isLoading;

  Future<void> fetchEventos() async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('No se pudo obtener el token de autenticación');
      }

      final url = Uri.parse('https://eventify.allsites.es/public/api/events');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('$response.body');
        if (responseData['data'] is List) {
          _eventos = List<Evento>.from(
            responseData['data'].map((eventData) => Evento(
                  title: eventData['title'] ?? 'Sin título',
                  star_time: eventData['start_time'] ?? 'Sin hora de inicio',
                  image_url: eventData['image_url'] ?? '',
                  category: eventData['category'] ?? 'Sin categoría',
                )),
          );
        }

        print('$responseData');
      } else {
        throw Exception(
            'Error al obtener los eventos: ${response.reasonPhrase} (${response.statusCode})');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
