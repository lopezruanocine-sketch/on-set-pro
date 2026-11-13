import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/domain/core/units.dart';
import 'package:on_set_pro/domain/exposure/exposure_engine.dart';

void main() {
  group('unidades', () {
    test('180° a 24 fps son 1/48 s', () {
      expect(
        Units.shutterSeconds(angleDegrees: 180, fps: 24),
        closeTo(1 / 48, 1e-9),
      );
    });

    test('1/48 s a 24 fps son 180°', () {
      expect(
        Units.shutterAngle(fps: 24, shutterDenominator: 48),
        closeTo(180, 1e-9),
      );
    });

    test('mireds de ida y vuelta', () {
      expect(Units.kelvinToMired(3200), closeTo(312.5, 1e-9));
      expect(Units.miredToKelvin(312.5), closeTo(3200, 1e-6));
    });
  });

  group('filtros ND', () {
    test('densidad 0.3 equivale a un paso', () {
      expect(NdFilter.stopsFromDensity(0.3), closeTo(1, 0.01));
    });

    test('densidad 0.9 equivale a tres pasos (la densidad comercial está redondeada)', () {
      expect(NdFilter.stopsFromDensity(0.9), closeTo(3, 0.02));
    });

    test('densidad 2.4 equivale a ocho pasos (la densidad comercial está redondeada)', () {
      expect(NdFilter.stopsFromDensity(2.4), closeTo(8, 0.03));
    });

    test('tres pasos son densidad 0.9', () {
      expect(NdFilter.densityFromStops(3), closeTo(0.9, 0.01));
    });
  });

  group('sistema de zonas', () {
    test('f/16 medido con la cámara en f/2.8 cae en zona 10', () {
      final r = ExposureEngine.zoneReading(meterAperture: 16, cameraAperture: 2.8);
      expect(r.rawZone, closeTo(10.03, 0.02));
      expect(r.zone, 10);
    });

    test('llevar la escena de zona 10 a zona 8 son −2 pasos', () {
      final r = ExposureEngine.zoneReading(
        meterAperture: 16,
        cameraAperture: 2.8,
        targetZone: 8,
      );
      expect(r.correctionStops, closeTo(-2.03, 0.02));
    });

    test('si la lectura coincide con el diafragma, cae en zona 5 sin corregir', () {
      final r = ExposureEngine.zoneReading(meterAperture: 5.6, cameraAperture: 5.6);
      expect(r.rawZone, closeTo(5, 1e-9));
      expect(r.isOnTarget, isTrue);
    });

    test('dos diafragmas justos son dos pasos y dos zonas', () {
      final r = ExposureEngine.zoneReading(meterAperture: 4, cameraAperture: 2);
      expect(r.rawZone, closeTo(7, 1e-9));
    });
  });

  group('ley de la inversa del cuadrado', () {
    test('de 2 m a 4 m se pierden 2 pasos y queda un cuarto de luz', () {
      final r = ExposureEngine.fallOff(referenceDistance: 2, newDistance: 4);
      expect(r.stops, closeTo(-2, 1e-9));
      expect(r.intensityRatio, closeTo(0.25, 1e-9));
      expect(r.isLoss, isTrue);
    });

    test('acercar de 4 m a 2 m gana 2 pasos', () {
      final r = ExposureEngine.fallOff(referenceDistance: 4, newDistance: 2);
      expect(r.stops, closeTo(2, 1e-9));
    });
  });

  group('fotometría lux / f', () {
    test('1000 lux con ISO 800 a 1/48 s dan f/8.2', () {
      final n = ExposureEngine.apertureForLux(lux: 1000, iso: 800, shutterTime: 1 / 48);
      expect(n, closeTo(8.165, 0.01));
    });

    test('el cálculo es reversible', () {
      final n = ExposureEngine.apertureForLux(lux: 1000, iso: 800, shutterTime: 1 / 48);
      final lux = ExposureEngine.luxForAperture(aperture: n, iso: 800, shutterTime: 1 / 48);
      expect(lux, closeTo(1000, 1e-6));
    });

    test('el doble de ISO permite cerrar medio diafragma (factor raíz de 2)', () {
      final a = ExposureEngine.apertureForLux(lux: 1000, iso: 800, shutterTime: 1 / 48);
      final b = ExposureEngine.apertureForLux(lux: 1000, iso: 1600, shutterTime: 1 / 48);
      expect(b / a, closeTo(math.sqrt2, 1e-9));
    });
  });

  group('compensación de exposición', () {
    test('misma configuración: no hay nada que corregir', () {
      final r = ExposureEngine.compensate(
        meter: const MeterReading(aperture: 5.6),
        camera: const ExposureSettings(aperture: 5.6),
      );
      expect(r.stops, closeTo(0, 1e-9));
      expect(r.isBalanced, isTrue);
      expect(r.label, 'OK');
    });

    test('cámara un paso más abierta que el fotómetro: sobra luz (−1)', () {
      final r = ExposureEngine.compensate(
        meter: const MeterReading(aperture: 4),
        camera: const ExposureSettings(aperture: 2.8),
      );
      expect(r.stops, closeTo(-1, 0.03));
      expect(r.label, startsWith('CIERRA'));
    });

    test('ISO 1600 pide cerrar un paso respecto de ISO 800', () {
      final r = ExposureEngine.compensate(
        meter: const MeterReading(aperture: 4),
        camera: const ExposureSettings(aperture: 4, iso: 1600),
      );
      expect(r.requiredAperture, closeTo(5.657, 0.01));
      expect(r.stops, closeTo(-1, 1e-6));
      expect(r.isoStops, closeTo(1, 1e-9));
    });

    test('un ND de un paso pide abrir un paso', () {
      final r = ExposureEngine.compensate(
        meter: const MeterReading(aperture: 4),
        camera: const ExposureSettings(aperture: 4, filterStops: 1),
      );
      expect(r.requiredAperture, closeTo(2.828, 0.01));
      expect(r.stops, closeTo(1, 1e-6));
    });

    test('grabar a 48 fps con 180° pide abrir un paso', () {
      final r = ExposureEngine.compensate(
        meter: const MeterReading(aperture: 4),
        camera: const ExposureSettings(aperture: 4, fps: 48),
      );
      expect(r.stops, closeTo(1, 1e-6));
    });

    test('cerrar el obturador a 90° deja la cámara un paso corta', () {
      final r = ExposureEngine.compensate(
        meter: const MeterReading(aperture: 4),
        camera: const ExposureSettings(aperture: 4, shutterAngle: 90),
      );
      expect(r.stops, closeTo(1, 1e-6));
    });

    test('el desglose de variables explica el total', () {
      final r = ExposureEngine.compensate(
        meter: const MeterReading(aperture: 4),
        camera: const ExposureSettings(
          aperture: 4,
          iso: 1600,
          fps: 48,
          filterStops: 1,
          gelStops: 0.5,
        ),
      );
      expect(r.isoStops, closeTo(1, 1e-9));
      expect(r.shutterStops, closeTo(-1, 1e-9));
      expect(r.filterStops, closeTo(-1, 1e-9));
      expect(r.gelStops, closeTo(-0.5, 1e-9));
      expect(r.stops, closeTo(1.5, 1e-6));
    });

    test('medir con el exposímetro a otro ISO no cambia la escena', () {
      final conMedicion800 = ExposureEngine.compensate(
        meter: const MeterReading(aperture: 4, iso: 800),
        camera: const ExposureSettings(aperture: 4, iso: 800),
      );
      final conMedicion1600 = ExposureEngine.compensate(
        meter: const MeterReading(aperture: 5.657, iso: 1600),
        camera: const ExposureSettings(aperture: 4, iso: 800),
      );
      expect(conMedicion800.stops, closeTo(conMedicion1600.stops, 0.01));
    });
  });

  group('delta de luz entre configuraciones', () {
    test('de ISO 800 a 1600 son +1 paso', () {
      final delta = ExposureEngine.lightDelta(
        camera: const ExposureSettings(aperture: 2.8, iso: 1600),
        reference: const ExposureSettings(aperture: 2.8, iso: 800),
      );
      expect(delta, closeTo(1, 1e-9));
    });

    test('de f/2.8 a f/4 son −1 paso', () {
      final delta = ExposureEngine.lightDelta(
        camera: const ExposureSettings(aperture: 4),
        reference: const ExposureSettings(aperture: 2.8),
      );
      expect(delta, closeTo(-1, 0.03));
    });
  });

  group('desglose por variable', () {
    test('ISO 1600 y 48 fps con ND 1 y gel 0.5 sobre la base', () {
      final b = ExposureEngine.breakdown(
        camera: const ExposureSettings(
          aperture: 4,
          iso: 1600,
          fps: 48,
          filterStops: 1,
          gelStops: 0.5,
        ),
      );
      expect(b.isoStops, closeTo(1, 1e-9));
      expect(b.shutterStops, closeTo(-1, 1e-9));
      expect(b.filterStops, closeTo(-1, 1e-9));
      expect(b.gelStops, closeTo(-0.5, 1e-9));
      expect(b.total, closeTo(-1.5, 1e-9));
      expect(b.totalCorrection, closeTo(1.5, 1e-9));
    });

    test('la configuración de referencia no aporta nada', () {
      final b = ExposureEngine.breakdown(camera: ExposureSettings.reference);
      expect(b.total, closeTo(0, 1e-9));
    });
  });

  group('pérdidas de filtros y gelatinas', () {
    test('un ND de 2 pasos baja la escena dos zonas', () {
      final sin = ExposureEngine.zoneReading(meterAperture: 16, cameraAperture: 2.8);
      final con = ExposureEngine.zoneReading(
        meterAperture: 16,
        cameraAperture: 2.8,
        lossStops: 2,
      );
      expect(sin.rawZone, closeTo(10.03, 0.02));
      expect(con.rawZone, closeTo(8.03, 0.02));
      // Con el ND puesto hace falta más luz para llegar a la misma zona.
      expect(con.correctionStops, greaterThan(sin.correctionStops));
    });

    test('la fotometría abre diafragma cuando hay pérdidas', () {
      final sin = ExposureEngine.apertureForLux(
        lux: 1000,
        iso: 800,
        shutterTime: 1 / 48,
      );
      final con = ExposureEngine.apertureForLux(
        lux: 1000,
        iso: 800,
        shutterTime: 1 / 48,
        lossStops: 2,
      );
      expect(con, closeTo(sin / 2, 1e-9));
    });

    test('lux y diafragma siguen siendo reversibles con pérdidas', () {
      final n = ExposureEngine.apertureForLux(
        lux: 1000,
        iso: 800,
        shutterTime: 1 / 48,
        lossStops: 3,
      );
      final lux = ExposureEngine.luxForAperture(
        aperture: n,
        iso: 800,
        shutterTime: 1 / 48,
        lossStops: 3,
      );
      expect(lux, closeTo(1000, 1e-6));
    });
  });
}
