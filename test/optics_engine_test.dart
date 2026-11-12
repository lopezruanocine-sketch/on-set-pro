import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/domain/optics/optics_engine.dart';

void main() {
  group('hiperfocal', () {
    test('50 mm a f/2.8 con CoC 0.03 son 29.81 m', () {
      final h = OpticsEngine.hyperfocalMm(focalMm: 50, aperture: 2.8, cocMm: 0.03);
      expect(h, closeTo(29811.9, 0.5));
    });

    test('24 mm a f/8 con CoC 0.03 son 2.42 m', () {
      final h = OpticsEngine.hyperfocalMm(focalMm: 24, aperture: 8, cocMm: 0.03);
      expect(h, closeTo(2424.0, 0.1));
    });

    test('cerrar el diafragma acerca la hiperfocal', () {
      final abierto = OpticsEngine.hyperfocalMm(focalMm: 50, aperture: 2.8, cocMm: 0.03);
      final cerrado = OpticsEngine.hyperfocalMm(focalMm: 50, aperture: 5.6, cocMm: 0.03);
      expect(cerrado, closeTo(abierto / 2, 50));
    });
  });

  group('profundidad de campo', () {
    test('50 mm f/2.8 a 2 m: límites 1.877 m y 2.140 m', () {
      final dof = OpticsEngine.depthOfField(
        focalMm: 50,
        aperture: 2.8,
        subjectDistanceMm: 2000,
        cocMm: 0.03,
      );
      expect(dof.nearLimitMm, closeTo(1877.0, 1.0));
      expect(dof.farLimitMm, closeTo(2140.2, 1.0));
      expect(dof.totalDepthMm, closeTo(263.2, 2.0));
      expect(dof.isFarInfinite, isFalse);
    });

    test('enfocar a la hiperfocal deja el fondo en infinito y el frente a H/2', () {
      final h = OpticsEngine.hyperfocalMm(focalMm: 24, aperture: 8, cocMm: 0.03);
      final dof = OpticsEngine.depthOfField(
        focalMm: 24,
        aperture: 8,
        subjectDistanceMm: h,
        cocMm: 0.03,
      );
      expect(dof.isFarInfinite, isTrue);
      expect(dof.nearLimitMm, closeTo(h / 2, 1.0));
    });

    test('enfocar más allá de la hiperfocal también da infinito', () {
      final dof = OpticsEngine.depthOfField(
        focalMm: 24,
        aperture: 8,
        subjectDistanceMm: 5000,
        cocMm: 0.03,
      );
      expect(dof.isFarInfinite, isTrue);
    });

    test('cerrar dos pasos casi duplica la profundidad (no es exactamente 2× por el término +f)', () {
      final abierto = OpticsEngine.depthOfField(
        focalMm: 50,
        aperture: 2.8,
        subjectDistanceMm: 2000,
        cocMm: 0.03,
      );
      final cerrado = OpticsEngine.depthOfField(
        focalMm: 50,
        aperture: 5.6,
        subjectDistanceMm: 2000,
        cocMm: 0.03,
      );
      expect(cerrado.totalDepthMm, closeTo(abierto.totalDepthMm * 2, 10.0));
    });
  });

  group('campo de visión y encuadre', () {
    test('50 mm en full frame da 39.6° horizontales', () {
      final fov = OpticsEngine.fieldOfView(
        sensorWidthMm: 36,
        sensorHeightMm: 24,
        focalMm: 50,
      );
      expect(fov.horizontalDegrees, closeTo(39.598, 0.01));
      expect(fov.verticalDegrees, closeTo(26.99, 0.02));
    });

    test('a 10 m con 50 mm el encuadre mide 7.2 m de ancho', () {
      final width = OpticsEngine.frameWidthAt(
        sensorWidthMm: 36,
        focalMm: 50,
        distanceMm: 10000,
      );
      expect(width, closeTo(7200, 0.01));
    });

    test('la diagonal de full frame es 43.27 mm', () {
      expect(OpticsEngine.diagonalMm(36, 24), closeTo(43.267, 0.001));
    });
  });

  group('equivalencia de lentes', () {
    test('crop de full frame a super 16 y focal equivalente', () {
      final focal = OpticsEngine.equivalentFocal(
        focalMm: 50,
        sourceWidthMm: 36,
        sourceHeightMm: 24,
        targetWidthMm: 12.52,
        targetHeightMm: 7.41,
      );
      expect(focal, closeTo(16.8, 0.2));
    });

    test('mismo sensor da la misma focal', () {
      final focal = OpticsEngine.equivalentFocal(
        focalMm: 32,
        sourceWidthMm: 36,
        sourceHeightMm: 24,
        targetWidthMm: 36,
        targetHeightMm: 24,
      );
      expect(focal, closeTo(32, 1e-9));
    });
  });
}
