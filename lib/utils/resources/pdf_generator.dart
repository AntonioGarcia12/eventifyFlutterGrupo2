import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PdfGenerator {
  Future<File> generatePdf({
    required List<Map<String, dynamic>> events,
    required String userName,
    required String appLogoPath,
  }) async {
    final pdf = pw.Document();

    final logoBytes = await rootBundle.load(appLogoPath);
    final logo = logoBytes.buffer.asUint8List();
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(pw.MemoryImage(logo), height: 50),
                pw.Text(
                  'Nombre: $userName',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold, font: ttf),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Informe de Eventos',
              style: pw.TextStyle(
                  fontSize: 24, fontWeight: pw.FontWeight.bold, font: ttf),
            ),
            pw.SizedBox(height: 20),
            ...events.map((event) {
              final imageBytes = event['imageBytes'] as Uint8List?;
              String? formattedStartTime;
              String? formattedEndTime;

              if (event['start_time'] != null) {
                final DateTime startTime = DateTime.parse(event['start_time']);
                formattedStartTime = dateFormat.format(startTime);
              }
              if (event['end_time'] != null) {
                final DateTime endTime = DateTime.parse(event['end_time']);
                formattedEndTime = dateFormat.format(endTime);
              }

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (imageBytes != null)
                      pw.Image(
                        pw.MemoryImage(imageBytes),
                        height: 100,
                        width: 100,
                        fit: pw.BoxFit.cover,
                      ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            event['title'] ?? 'Evento sin nombre',
                            style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                font: ttf),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'Inicio: ${formattedStartTime ?? 'No disponible'}',
                            style: pw.TextStyle(fontSize: 12, font: ttf),
                          ),
                          pw.Text(
                            'Fin: ${formattedEndTime ?? 'No disponible'}',
                            style: pw.TextStyle(fontSize: 12, font: ttf),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Eventos.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  Future<String?> savePdfToDownloads(List<int> bytes) async {
    try {
      final directory = Directory('/storage/emulated/0/Download');

      if (!await directory.exists()) {
        throw Exception("No se pudo acceder a la carpeta Descargas.");
      }

      String baseFileName = 'Eventos';
      String extension = '.pdf';
      String fileName = '$baseFileName$extension';

      int cont = 1;

      while (await File('${directory.path}/$fileName').exists()) {
        fileName = '$baseFileName($cont)$extension';
        cont++;
      }

      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      return null;
    }
  }
}

Future<Uint8List> fetchImageBytes(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Error al descargar la imagen: ${response.reasonPhrase}');
    }
  } catch (e) {
    return Uint8List(0);
  }
}
