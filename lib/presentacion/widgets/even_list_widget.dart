import 'package:eventify/presentacion/widgets/generic_event_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:eventify/infraestructuras/models/evento.dart';
import 'package:eventify/presentacion/widgets/widgets.dart';

class EventList extends StatelessWidget {
  final bool isLoading;
  final List<Evento> eventos;
  final bool isMyEvent;

  const EventList({
    required this.isLoading,
    required this.eventos,
    this.isMyEvent = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (eventos.isEmpty) {
      return const Center(
        child: Text(
          'No hay eventos disponibles.',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: eventos.length,
        itemBuilder: (context, index) {
          final evento = eventos[index];
          return _getEventCard(evento);
        },
      );
    }
  }

  Widget _getEventCard(Evento evento) {
    Color borderColor;
    switch (evento.category.toLowerCase()) {
      case 'music':
        borderColor = const Color(0xFFFFD700);
        break;
      case 'sport':
        borderColor = const Color(0xFFFF4500);
        break;
      case 'technology':
        borderColor = const Color(0xFF4CAF50);
        break;
      default:
        borderColor = Colors.grey;
    }

    return GenericEventCard(
      evento: evento,
      borderColor: borderColor,
      isMyEvent: isMyEvent,
    );
  }
}
