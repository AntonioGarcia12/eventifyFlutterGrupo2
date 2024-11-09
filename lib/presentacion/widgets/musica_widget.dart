import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventify/infraestructuras/models/evento.dart';

class MusicaEventCard extends StatelessWidget {
  final Evento evento;

  const MusicaEventCard({required this.evento, super.key});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime;
    String formattedDate = '';
    String formattedTime = '';

    try {
      // Parsear la fecha y hora desde la cadena
      dateTime = DateTime.parse(evento.star_time);
      // Formatear la fecha a "dd/MM/yyyy"
      formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
      // Formatear la hora a "HH:mm" (24 horas sin segundos)
      formattedTime = DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      // Manejar errores de parsing
      formattedDate = 'Fecha no disponible';
      formattedTime = '';
    }

    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFFFD700), width: 2), // Amarillo
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Imagen de fondo
          Image.network(
            evento.image_url,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          // Degradado para mejorar la legibilidad del texto
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
          // Texto superpuesto con la información del evento
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
