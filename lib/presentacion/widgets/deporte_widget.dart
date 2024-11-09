import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventify/infraestructuras/models/evento.dart';

class DeporteEventCard extends StatelessWidget {
  final Evento evento;

  const DeporteEventCard({required this.evento, super.key});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime;
    String formattedDate = '';
    String formattedTime = '';

    try {
      dateTime = DateTime.parse(evento.star_time);
      formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
      formattedTime = DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      formattedDate = 'Fecha no disponible';
      formattedTime = '';
    }

    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFFF4500), width: 2), // Naranja
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image.network(
            evento.image_url,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Text(
              '${evento.title}\nFecha: $formattedDate\nHora: $formattedTime',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
