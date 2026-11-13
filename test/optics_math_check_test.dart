import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/domain/optics/optics_engine.dart';

void main() {
  group('óptica: las cuentas contra valores de catálogo', () {
    test('full frame a 50 mm abre 39,6° horizontal', () {
      final fov = OpticsEngine.fieldOfView(
        sensorWidthMm: 36,
        sensorHeightMm: 24,
        focalMm: 50,
      );
      expect(fov.horizontalDegrees, closeTo(39.6, 0.1));
      expect(fov.verticalDegrees, closeTo(27.0, 0.1));
      // Diagonal: 2·atan(43.27/100) = 46.8°
      expect(fov.diagonalDegrees, closeTo(46.8, 0.1));
    });

    test('Súper 16 a 25 mm abre 28° (equivalente a 74 mm en full frame)', () {
      final fov = OpticsEngine.fieldOfView(
        sensorWidthMm: 12.52,
        sensorHeightMm: 7.41,
        focalMm: 25,
      );
      expect(fov.horizontalDegrees, closeTo(28.1, 0.2));

      final eq = OpticsEngine.equivalentFocal(
        focalMm: 25,
        sourceWidthMm: 12.52,
        sourceHeightMm: 7.41,
        targetWidthMm: 36,
        targetHeightMm: 24,
      );
      expect(eq, closeTo(74.3, 0.5));
    });

    test('el factor de recorte va por diagonal, no por ancho', () {
      final crop = OpticsEngine.cropFactor(
        sourceWidthMm: 12.52,
        sourceHeightMm: 7.41,
        targetWidthMm: 36,
        targetHeightMm: 24,
      );
      // 43.27 / 14.55
      expect(crop, closeTo(2.97, 0.02));
    });

    test('ALEXA 35 contra full frame da 1,27×', () {
      final crop = OpticsEngine.cropFactor(
        sourceWidthMm: 27.99,
        sourceHeightMm: 19.22,
        targetWidthMm: 36,
        targetHeightMm: 24,
      );
      expect(crop, closeTo(1.27, 0.02));
    });

    test('el ancho del cuadro a 10 m con 50 mm en full frame', () {
      // 36 · 10000 / 50 = 7200 mm
      final width = OpticsEngine.frameWidthAt(
        sensorWidthMm: 36,
        focalMm: 50,
        distanceMm: 10000,
      );
      expect(width, closeTo(7200, 1));
    });

    test('duplicar la distancia duplica el cuadro', () {
      final a = OpticsEngine.frameWidthAt(
        sensorWidthMm: 24.89,
        focalMm: 32,
        distanceMm: 5000,
      );
      final b = OpticsEngine.frameWidthAt(
        sensorWidthMm: 24.89,
        focalMm: 32,
        distanceMm: 10000,
      );
      expect(b, closeTo(a * 2, 0.01));
    });
  });
}
