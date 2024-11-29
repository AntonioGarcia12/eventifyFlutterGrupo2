import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:eventify/utils/resources/pdf_generator.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InformeServices {
  final PdfGenerator _pdfGenerator = PdfGenerator();

  Future<Uint8List> fetchImageBytes(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception(
            'Error al descargar la imagen: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('No se pudo descargar la imagen desde la URL: $imageUrl');
    }
  }

  Future<List<Map<String, dynamic>>> fetchFilteredEvents({
    required DateTime startDate,
    required DateTime endDate,
    required List<String> selectedCategories,
  }) async {
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

      if (responseData['data'] is List) {
        final events = (responseData['data'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        final formattedStartDate =
            DateTime(startDate.year, startDate.month, startDate.day);
        final formattedEndDate =
            DateTime(endDate.year, endDate.month, endDate.day);

        final filteredEvents = events.where((event) {
          final eventDateStr = event['start_time'] ?? '';
          final eventDate = _parseDate(eventDateStr);
          final category = event['category'] ?? '';

          return eventDate != null &&
              eventDate.isAfter(
                  formattedStartDate.subtract(const Duration(days: 1))) &&
              eventDate
                  .isBefore(formattedEndDate.add(const Duration(days: 1))) &&
              selectedCategories.contains(category);
        }).toList();

        for (var event in filteredEvents) {
          if (event['image_url'] != null &&
              event['image_url'].toString().isNotEmpty) {
            try {
              event['imageBytes'] = await fetchImageBytes(event['image_url']);
            } catch (e) {
              event['imageBytes'] = null;
            }
          }
        }

        return filteredEvents;
      } else {
        throw Exception(
            'Formato de datos no esperado: ${responseData['data']}');
      }
    } else {
      throw Exception('Error al obtener eventos: ${response.reasonPhrase}');
    }
  }

  DateTime? _parseDate(String dateStr) {
    try {
      final dateParts = dateStr.split(' ')[0];
      return DateTime.parse(dateParts);
    } catch (e) {
      return null;
    }
  }

  Future<String?> generarPdf({
    required List<Map<String, dynamic>> events,
    required String userName,
  }) async {
    try {
      final pdfFile = await _pdfGenerator.generatePdf(
        events: events,
        userName: userName,
        fileName: "informe_eventos.pdf",
        appLogoPath: "assets/images/logo.png",
      );

      final savedPath = await _pdfGenerator.savePdfToDownloads(
        await pdfFile.readAsBytes(),
        "informe_eventos.pdf",
      );

      return savedPath;
    } catch (e) {
      return null;
    }
  }

  Future<void> enviarPDFEmail({
    required List<Map<String, dynamic>> events,
    required String userName,
    required String userEmail,
  }) async {
    try {
      final pdfFile = await _pdfGenerator.generatePdf(
        events: events,
        userName: userName,
        fileName: "informe_eventos.pdf",
        appLogoPath: "assets/images/logo.png",
      );

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/informe_eventos.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdfFile.readAsBytes());

      final smtpServer = gmail(
        'eventifydam2425@gmail.com',
        'sxta huvx xrxl vkmo',
      );

      final message = Message()
        ..from = const Address('eventifydam2425@gmail.com', 'Eventify App')
        ..recipients.add(userEmail)
        ..subject = 'Informe de Eventos'
        ..text = 'Hola! $userName, Aquí tienes tu informe de eventos.'
        ..attachments.add(FileAttachment(file));

      await send(message, smtpServer);
    } catch (e) {
      throw Exception('Error al enviar el PDF: $e');
    }
  }
}
