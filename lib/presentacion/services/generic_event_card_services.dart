import 'package:eventify/infraestructuras/models/evento.dart';
import 'package:eventify/infraestructuras/models/eventsByOrganizador.dart';
import 'package:eventify/presentacion/providers/evento_by_organizador_provider.dart';
import 'package:eventify/presentacion/screens/screens.dart';
import 'package:eventify/presentacion/services/organizador_service.dart';
import 'package:eventify/presentacion/services/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:eventify/presentacion/providers/evento_provider.dart';

class GenericEventCardServices {
  final WidgetRef ref;
  final BuildContext context;

  GenericEventCardServices({required this.ref, required this.context});

  Future<int?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  Future<void> desinscribirseEvento(Evento evento) async {
    try {
      int? userId = await _getUserId();

      if (userId == null) {
        _showSnackBar('Error: No se pudo obtener el ID del usuario');
        return;
      }

      MisEventosServices misEventosServices = MisEventosServices();
      await misEventosServices.unregisterUserFromEvent(
        userId: userId,
        eventId: evento.id,
      );

      ref.read(eventoProvider.notifier).removeEvent(evento.id);
      // ignore: unused_result
      ref.refresh(registeredEventIdsProvider);

      _showSnackBar('Te has desinscrito del evento');
    } catch (e) {
      _showSnackBar('Error al desinscribirse del evento: $e');
    }
  }

  Future<void> inscribirEvento(Evento evento) async {
    try {
      int? userId = await _getUserId();

      if (userId == null) {
        _showSnackBar('Error: No se pudo obtener el ID del usuario');
        return;
      }

      NormalService normalService = ref.read(normalServiceProvider);
      await normalService.registerUserToEvent(
        userId: userId,
        eventId: evento.id,
        registeredAt: DateTime.now(),
      );

      ref.read(eventoProvider.notifier).removeEvent(evento.id);
      // ignore: unused_result
      ref.refresh(registeredEventIdsProvider);

      _showSnackBar('Te has inscrito al evento');
    } catch (e) {
      _showSnackBar('Error al registrar al evento: $e');
    }
  }

  Future<void> mostrarDetalles(Evento evento) async {
    try {
      String formattedStart = _formatDateTime(evento.star_time);
      String formattedEnd = _formatDateTime(evento.end_time);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? description = prefs.getString('event_description_${evento.id}');
      String? location = prefs.getString('event_location_${evento.id}');

      if (description == null || location == null) {
        final eventDetails =
            await MisEventosServices().getEventDetails(evento.id);
        if (eventDetails != null) {
          description = eventDetails.description;
          location = eventDetails.location;
        }
      }

      _showEventDetailsDialog(
          evento, formattedStart, formattedEnd, description, location);
    } catch (e) {
      _showSnackBar('Error al obtener los detalles del evento: $e');
    }
  }

  void confirmarDesinscripcion(Evento evento) {
    _showConfirmationDialog(
      title: 'Confirmar desinscripción',
      content: '¿Estás seguro de que deseas desinscribirse de este evento?',
      onConfirm: () => desinscribirseEvento(evento),
    );
  }

  void confirmarInscripcion(Evento evento) {
    _showConfirmationDialog(
      title: 'Confirmar inscripción',
      content: '¿Estás seguro de que deseas inscribirte a este evento?',
      onConfirm: () => inscribirEvento(evento),
    );
  }

  String _formatDateTime(String dateTimeString, {bool includeTime = true}) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
      if (includeTime) {
        String formattedTime = DateFormat('HH:mm').format(dateTime);
        return '$formattedDate - $formattedTime';
      } else {
        return formattedDate;
      }
    } catch (e) {
      return 'Fecha no disponible';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _showEventDetailsDialog(
    Evento evento,
    String formattedStart,
    String formattedEnd,
    String? description,
    String? location,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          title: Text(
            evento.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  evento.image_url,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailText('Inicio:', formattedStart),
              _buildDetailText('Finalización:', formattedEnd),
              _buildDetailText(
                  'Descripción:', description ?? 'Descripción no disponible'),
              _buildDetailText(
                  'Localización:', location ?? 'Localización no disponible'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  'Cerrar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailText(String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> borrarEvento(Eventsbyorganizador evento) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? id = prefs.getInt('evento_id');
    try {
      final organizadorService = ref.read(organizadorServiceProvider);
      await organizadorService.deleteEvent(evento.id);

      await ref
          .read(eventoByOrganizadorProvider)
          .fetchEventosByOrganizador(id!, token!);

      _showSnackBar('Evento eliminado correctamente.');
    } catch (e) {
      _showSnackBar('Error al eliminar el evento: $e');
    }
  }
}
