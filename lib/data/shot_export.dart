import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'shots_repository.dart';

/// Exporta los planos guardados a texto o PDF para mandarlos al DIT, al
/// director o imprimirlos.
class ShotExport {
  ShotExport._();

  static String _two(int v) => v.toString().padLeft(2, '0');

  /// Las fuentes del PDF son Latin-1: cambiamos los signos tipográficos que
  /// no existen ahí (guion largo, comillas curvas) por sus equivalentes.
  static String _pdfSafe(String text) => text
      .replaceAll('—', '-')
      .replaceAll('–', '-')
      .replaceAll('“', '"')
      .replaceAll('”', '"')
      .replaceAll('’', "'");

  static String _date(DateTime d) =>
      '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';

  /// Texto plano, listo para pegar en un mail o en una planilla.
  static String toText(List<ShotPlan> plans, {String? cameraLabel}) {
    final buffer = StringBuffer()
      ..writeln('ON SET PRO — PLANOS')
      ..writeln('Generado: ${_date(DateTime.now())}');
    if (cameraLabel != null) buffer.writeln('Cámara activa: $cameraLabel');
    buffer
      ..writeln('')
      ..writeln('${plans.length} planos')
      ..writeln('');

    for (var i = 0; i < plans.length; i++) {
      final p = plans[i];
      buffer
        ..writeln('${i + 1}. ${p.cameraLabel}')
        ..writeln('   Fecha: ${_date(p.savedAt)}')
        ..writeln('   ISO ${p.iso.toStringAsFixed(0)} · '
            '${p.fps.toStringAsFixed(p.fps % 1 == 0 ? 0 : 2)} fps · '
            '${p.shutterAngle.toStringAsFixed(1)}° (${p.shutterLabel})')
        ..writeln('   Filtros: ${p.filterNames.isEmpty ? "ninguno" : p.filterNames.map((f) => f.split(" — ").first).join(", ")}')
        ..writeln('   Gelatinas: ${p.gelLabels.isEmpty ? "ninguna" : p.gelLabels.join(", ")}')
        ..writeln('   Lectura: f/${p.meterReading.toStringAsFixed(1)} · '
            'corrección ${p.correctionStops > 0 ? "+" : ""}${p.correctionStops.toStringAsFixed(1)} stops');
      if (p.note != null && p.note!.isNotEmpty) {
        buffer.writeln('   Nota: ${p.note}');
      }
      buffer.writeln('');
    }
    return buffer.toString();
  }

  /// PDF una hoja por tanda de planos, con la misma información que el texto.
  static Future<Uint8List> toPdf(
    List<ShotPlan> plans, {
    String? cameraLabel,
  }) async {
    final doc = pw.Document();
    final grey = PdfColor.fromInt(0xFF555555);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              _pdfSafe('ON SET PRO — PLANOS'),
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Generado ${_date(DateTime.now())}'
              '${cameraLabel == null ? '' : ' · ${_pdfSafe(cameraLabel)}'}',
              style: pw.TextStyle(fontSize: 9, color: grey),
            ),
            pw.Divider(),
          ],
        ),
        footer: (context) => pw.Text(
          'Página ${context.pageNumber} de ${context.pagesCount}',
          style: pw.TextStyle(fontSize: 8, color: grey),
        ),
        build: (context) => [
          for (var i = 0; i < plans.length; i++) ...[
            pw.Container(
              width: double.infinity,
              margin: const pw.EdgeInsets.only(bottom: 14),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${i + 1}. ${_pdfSafe(plans[i].cameraLabel)}',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'ISO ${plans[i].iso.toStringAsFixed(0)} · '
                    '${plans[i].fps.toStringAsFixed(plans[i].fps % 1 == 0 ? 0 : 2)} fps · '
                    '${plans[i].shutterAngle.toStringAsFixed(1)}° (${plans[i].shutterLabel})',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Filtros: ${plans[i].filterNames.isEmpty ? "ninguno" : _pdfSafe(plans[i].filterNames.map((f) => f.split(" — ").first).join(", "))}',
                    style: pw.TextStyle(fontSize: 10, color: grey),
                  ),
                  pw.Text(
                    'Gelatinas: ${plans[i].gelLabels.isEmpty ? "ninguna" : _pdfSafe(plans[i].gelLabels.join(", "))}',
                    style: pw.TextStyle(fontSize: 10, color: grey),
                  ),
                  pw.Text(
                    'Lectura f/${plans[i].meterReading.toStringAsFixed(1)} · '
                    'corrección ${plans[i].correctionStops > 0 ? "+" : ""}${plans[i].correctionStops.toStringAsFixed(1)} stops',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  if (plans[i].note != null && plans[i].note!.isNotEmpty)
                    pw.Text(
                      'Nota: ${_pdfSafe(plans[i].note!)}',
                      style: pw.TextStyle(fontSize: 10, color: grey),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
    return doc.save();
  }
}
