import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/data/camera_selection.dart';
import 'package:on_set_pro/data/shot_export.dart';
import 'package:on_set_pro/data/shots_repository.dart';

void main() {
  const camera = CameraSelection(
    kind: 'digital',
    manufacturer: 'ARRI',
    camera: 'ALEXA 35',
    mode: '4.6K 3:2 Open Gate',
  );

  final plan = ShotPlan(
    id: '1',
    kind: 'digital',
    cameraLabel: 'ALEXA 35 · 4.6K 3:2 Open Gate',
    iso: 800,
    fps: 24,
    shutterAngle: 172.8,
    filterNames: const ['ND 1.2 — 4 stops'],
    gelLabels: const ['Lee 204 Full CTO'],
    meterReading: 4,
    correctionStops: 6.4,
    savedAt: DateTime(2026, 11, 13, 10, 30),
    note: 'Escena 12 · apertura',
  );

  test('el texto incluye cámara, filtros, gelatinas y nota', () {
    final text = ShotExport.toText([plan], cameraLabel: camera.label);
    expect(text, contains('ON SET PRO'));
    expect(text, contains('ALEXA 35'));
    expect(text, contains('ISO 800'));
    expect(text, contains('172.8°'));
    expect(text, contains('ND 1.2'));
    expect(text, contains('Lee 204'));
    expect(text, contains('+6.4 stops'));
    expect(text, contains('Escena 12'));
  });

  test('el texto avisa cuando no hay filtros ni gelatinas', () {
    final plain = ShotPlan(
      id: '2',
      kind: 'digital',
      cameraLabel: 'Sin filtros',
      iso: 400,
      fps: 25,
      shutterAngle: 180,
      filterNames: const [],
      gelLabels: const [],
      meterReading: 2.8,
      correctionStops: 0,
      savedAt: DateTime(2026, 11, 13),
    );
    final text = ShotExport.toText([plain]);
    expect(text, contains('Filtros: ninguno'));
    expect(text, contains('Gelatinas: ninguna'));
  });

  test('el PDF se genera con un tamaño válido', () async {
    final bytes = await ShotExport.toPdf([plan], cameraLabel: camera.label);
    expect(bytes.length, greaterThan(1000));
    // Firma de un archivo PDF.
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('el PDF sale aunque la lista esté vacía', () async {
    final bytes = await ShotExport.toPdf(const []);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
