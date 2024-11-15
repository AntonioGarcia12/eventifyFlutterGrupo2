import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventify/infraestructuras/models/evento.dart';

class GenericEventCard extends StatelessWidget {
  final Evento evento;
  final Color borderColor;

  const GenericEventCard({
    required this.evento,
    required this.borderColor,
    super.key,
  });

  void _inscribirEvento(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inscrito al evento: ${evento.title}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: borderColor.withOpacity(0.9),
      ),
    );
  }

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
        side: BorderSide(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black.withOpacity(0.5),
      child: SizedBox(
        height: 160,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(10),
              ),
              child: Image.network(
                evento.image_url,
                width: 130,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evento.title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fecha: $formattedDate',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Hora: $formattedTime',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () => _inscribirEvento(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: borderColor.withOpacity(0.85),
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Inscribirse',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
