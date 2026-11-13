import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/data/catalogs/light_gels.dart';
import 'package:on_set_pro/domain/color/color_engine.dart';
import 'package:on_set_pro/domain/core/units.dart';
import 'package:on_set_pro/domain/exposure/exposure_engine.dart';

/// Auditoría del departamento de imagen y exposición.
///
/// El convenio del motor es el del set: **positivo = agregar luz**,
/// **negativo = quitar luz** (cerrar diafragma, poner ND).
void main() {
  group('caída de luz con la distancia', () {
    test('acercar la luz a la mitad de distancia suma 2 pasos', () {
      final r = ExposureEngine.fallOff(referenceDistance: 4, newDistance: 2);
      expect(r.stops, closeTo(2, 0.01));
    });

    test('alejar la luz al doble resta 2 pasos', () {
      final r = ExposureEngine.fallOff(referenceDistance: 2, newDistance: 4);
      expect(r.stops, closeTo(-2, 0.01));
    });

    test('triplicar la distancia resta 3,17 pasos', () {
      final r = ExposureEngine.fallOff(referenceDistance: 1, newDistance: 3);
      expect(r.stops, closeTo(-3.17, 0.01));
    });
  });

  group('compensación: el signo dice si sobra o falta luz', () {
    test('con f/2.8 donde la luz pide f/5.6 sobran 2 pasos', () {
      final r = ExposureEngine.compensate(
        meter: const MeterReading(aperture: 5.6),
        camera: const ExposureSettings(aperture: 2.8),
      );
      expect(r.stops, closeTo(-2, 0.02));
      // El diafragma que expone bien es el que pide la luz: f/5.6.
      expect(r.requiredAperture, closeTo(5.6, 0.02));
    });

    test('duplicar el ISO deja un paso de más', () {
      final r = ExposureEngine.compensate(
        meter: const MeterReading(aperture: 5.6),
        camera: const ExposureSettings(aperture: 5.6, iso: 1600),
      );
      expect(r.stops, closeTo(-1, 0.01));
    });

    test('de 172,8° a 180° a 24 fps gana un dieciseisavo de paso', () {
      final r = ExposureEngine.compensate(
        meter: const MeterReading(aperture: 4, shutterAngle: 180, fps: 24),
        camera: const ExposureSettings(aperture: 4, shutterAngle: 172.8, fps: 24),
      );
      // 180/172.8 = 1.0417 → log2 = 0,059 pasos de más luz
      expect(r.stops, closeTo(0.06, 0.01));
    });
  });

  group('fotometría: abrir o cerrar según el ISO', () {
    test('a ISO 3200 se puede cerrar dos pasos desde ISO 800', () {
      final aperture = ExposureEngine.requiredAperture(
        meter: const MeterReading(aperture: 5.6),
        camera: const ExposureSettings(aperture: 5.6, iso: 3200),
      );
      expect(aperture, closeTo(11.2, 0.1));
    });

    test('a ISO 1600 se puede cerrar un paso', () {
      final aperture = ExposureEngine.requiredAperture(
        meter: const MeterReading(aperture: 5.6),
        camera: const ExposureSettings(aperture: 5.6, iso: 1600),
      );
      expect(aperture, closeTo(7.92, 0.1));
    });

    test('un ND de 2 pasos obliga a abrir dos diafragmas', () {
      final aperture = ExposureEngine.requiredAperture(
        meter: const MeterReading(aperture: 5.6),
        camera: const ExposureSettings(aperture: 5.6, filterStops: 2),
      );
      expect(aperture, closeTo(2.8, 0.02));
    });
  });

  group('zonas: cada zona es un paso', () {
    test('medir en f/5.6 con la cámara en f/5.6 deja la escena en zona V', () {
      final z = ExposureEngine.zoneReading(meterAperture: 5.6, cameraAperture: 5.6);
      expect(z.rawZone, closeTo(5, 0.01));
      expect(z.correctionStops, closeTo(0, 0.01));
    });

    test('abrir dos diafragmas sube dos zonas y pide bajar la luz', () {
      final z = ExposureEngine.zoneReading(meterAperture: 5.6, cameraAperture: 2.8);
      expect(z.rawZone, closeTo(7, 0.02));
      // Para volver a zona V hay que quitar 2 pasos.
      expect(z.correctionStops, closeTo(-2, 0.02));
    });

    test('pedir zona VII desde zona V pide sumar dos pasos', () {
      final z = ExposureEngine.zoneReading(
        meterAperture: 5.6,
        cameraAperture: 5.6,
        targetZone: 7,
      );
      expect(z.correctionStops, closeTo(2, 0.02));
    });
  });

  group('color: mireds contra la tabla de gelatinas', () {
    test('3200 K a 5600 K son −133 mireds', () {
      // Enfriar es corrimiento negativo: destino − origen en mireds.
      final shift = Units.kelvinToMired(5600) - Units.kelvinToMired(3200);
      expect(shift, closeTo(-134, 2));
    });

    test('5600 K a 3200 K son +133 mireds', () {
      final shift = Units.kelvinToMired(3200) - Units.kelvinToMired(5600);
      expect(shift, closeTo(134, 2));
    });

    test('aplicar −133 mireds a 3200 K devuelve 5600 K', () {
      final result = ColorEngine.kelvinAfter(3200, -133);
      expect(result, closeTo(5600, 60));
    });

    test('la Full CTB del catálogo es la que corresponde', () {
      final gel = LightGels.byCode('Rosco', '3202');
      expect(gel, isNotNull);
      expect(gel!.mired, closeTo(-133, 12));
    });

    test('la Full CTO calienta más que la Half CTO', () {
      final half = LightGels.byCode('Lee', '202')!;
      final full = LightGels.byCode('Lee', '201')!;
      expect(full.mired!.abs(), greaterThan(half.mired!.abs()));
    });
  });
}
