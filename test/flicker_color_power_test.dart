import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/data/catalogs/cables.dart';
import 'package:on_set_pro/data/catalogs/light_gels.dart';
import 'package:on_set_pro/domain/color/color_engine.dart';
import 'package:on_set_pro/domain/color/gel_advisor.dart';
import 'package:on_set_pro/domain/flicker/flicker_engine.dart';
import 'package:on_set_pro/domain/power/power_engine.dart';

void main() {
  group('flicker free', () {
    test('50 Hz a 24 fps: la ventana recomendada es 172.8°', () {
      final w = FlickerEngine.recommended(gridHz: 50, fps: 24);
      expect(w, isNotNull);
      expect(w!.angle, closeTo(172.8, 0.01));
      // 172.8° equivale a dos semiciclos de 50 Hz: 1/50 s.
      expect(w.shutterDenominator, closeTo(50, 1e-9));
    });

    test('50 Hz a 24 fps genera cuatro ventanas hasta 360°', () {
      final windows = FlickerEngine.safeWindows(gridHz: 50, fps: 24);
      expect(windows.length, 4);
      expect(windows.map((w) => w.angle.round()).toList(), [86, 173, 259, 346]);
    });

    test('50 Hz a 25 fps cae exactamente en 180°', () {
      final w = FlickerEngine.recommended(gridHz: 50, fps: 25);
      expect(w!.angle, closeTo(180, 1e-9));
      expect(w.distanceTo180, closeTo(0, 1e-9));
    });

    test('60 Hz a 24 fps: la mejor ventana queda a 36° de 180', () {
      final w = FlickerEngine.recommended(gridHz: 60, fps: 24);
      expect(w!.distanceTo180, closeTo(36, 1e-9));
    });

    test('180° a 50 Hz y 24 fps no está a salvo', () {
      expect(FlickerEngine.isSafe(gridHz: 50, fps: 24, angle: 180), isFalse);
    });

    test('172.8° a 50 Hz y 24 fps sí está a salvo', () {
      expect(FlickerEngine.isSafe(gridHz: 50, fps: 24, angle: 172.8), isTrue);
    });
  });

  group('color y mireds', () {
    test('3200 K a 5500 K pide −130.7 mireds', () {
      final shift = ColorEngine.shiftTo(sourceKelvin: 3200, targetKelvin: 5500);
      expect(shift.sourceMired, closeTo(312.5, 1e-9));
      expect(shift.targetMired, closeTo(181.82, 0.01));
      expect(shift.shiftMired, closeTo(-130.68, 0.01));
    });

    test('un CTB completo sobre 3200 K deja la fuente en ~5700 K', () {
      final k = ColorEngine.kelvinWithGel(sourceKelvin: 3200, gelMired: -137);
      expect(k, closeTo(5698, 3));
    });

    test('aplicar el corrimiento exacto llega al objetivo', () {
      final shift = ColorEngine.shiftTo(sourceKelvin: 3200, targetKelvin: 5500);
      final k = ColorEngine.kelvinAfter(3200, shift.shiftMired);
      expect(k, closeTo(5500, 1));
    });
  });

  group('asesor de gelatinas', () {
    test('de tungsteno a diurno propone un CTB', () {
      final options = GelAdvisor.recommend(sourceKelvin: 3200, targetKelvin: 5500);
      expect(options, isNotEmpty);
      expect(options.first.gel.family, GelFamily.ctb);
      expect(options.first.errorMired, lessThan(10));
    });

    test('de diurno a tungsteno propone un CTO', () {
      final options = GelAdvisor.recommend(sourceKelvin: 5600, targetKelvin: 3200);
      expect(options.first.gel.family, GelFamily.cto);
    });

    test('si la fuente ya está en el objetivo no propone nada', () {
      final options = GelAdvisor.recommend(sourceKelvin: 3200, targetKelvin: 3200);
      expect(options, isEmpty);
    });

    test('el catálogo tiene gelatinas con mired y difusiones sin mired', () {
      expect(LightGels.withMired.length, greaterThan(15));
      expect(LightGels.all.any((g) => g.family == GelFamily.diffusion), isTrue);
    });
  });

  group('eléctrico: ley de Ohm', () {
    test('1000 W a 220 V son 4.55 A', () {
      expect(PowerEngine.amps(watts: 1000, voltage: 220), closeTo(4.545, 0.001));
    });

    test('1000 W a 380 V trifásico son 1.52 A', () {
      expect(
        PowerEngine.amps(watts: 1000, voltage: 380, phases: Phases.three),
        closeTo(1.519, 0.001),
      );
    });

    test('un HMI de 1000 W con factor 0.98 consume algo más de corriente', () {
      final pf1 = PowerEngine.amps(watts: 1000, voltage: 220);
      final pf098 = PowerEngine.amps(watts: 1000, voltage: 220, powerFactor: 0.98);
      expect(pf098, greaterThan(pf1));
    });
  });

  group('eléctrico: caída de tensión', () {
    test('16 A a 50 m con 2.5 mm² y 220 V: 15.3 V a 70 °C', () {
      final r = PowerEngine.voltageDrop(
        amps: 16,
        lengthM: 50,
        resistanceOhmPerKm: 7.98,
        voltage: 220,
      );
      expect(r.volts, closeTo(15.32, 0.01));
      expect(r.percent, closeTo(6.96, 0.01));
      expect(r.isAcceptable, isFalse);
    });

    test('a 90 °C la caída sube a 16.3 V (coincide con la tabla de Prysmian)', () {
      final r = PowerEngine.voltageDrop(
        amps: 16,
        lengthM: 50,
        resistanceOhmPerKm: 7.98,
        voltage: 220,
        conductorTempFactor: 1.275,
      );
      expect(r.volts, closeTo(16.28, 0.01));
    });

    test('trifásico: la caída es menor que monofásico para la misma corriente', () {
      final mono = PowerEngine.voltageDrop(
        amps: 16,
        lengthM: 50,
        resistanceOhmPerKm: 7.98,
        voltage: 220,
      );
      final tri = PowerEngine.voltageDrop(
        amps: 16,
        lengthM: 50,
        resistanceOhmPerKm: 7.98,
        voltage: 380,
        phases: Phases.three,
      );
      expect(tri.volts, closeTo(mono.volts * 0.866, 0.01));
    });
  });

  group('eléctrico: ampacidad y derating', () {
    test('el factor por temperatura interpola entre 0.91 y 0.82', () {
      expect(PowerEngine.cableTempFactor(30), closeTo(1.0, 1e-9));
      expect(PowerEngine.cableTempFactor(40), closeTo(0.91, 1e-9));
      expect(PowerEngine.cableTempFactor(50), closeTo(0.82, 1e-9));
      expect(PowerEngine.cableTempFactor(35), closeTo(0.955, 1e-9));
    });

    test('un cable de 36 A a 50 °C admite 29.5 A', () {
      expect(PowerEngine.deratedAmpacity(ampacityA: 36, tempFactor: 0.82),
          closeTo(29.52, 0.01));
    });

    test('2.5 mm² móvil admite 25 A y el SOOW 14 AWG sólo 15 A', () {
      final h07 = CableCatalog.bySection(CableKind.h07rnf, 2.5)!;
      final soow = CableCatalog.bySection(CableKind.soow, 2.08)!;
      expect(h07.ampacityA, 25);
      expect(soow.ampacityA, 15);
    });

    test('para 20 A encuentra primero el cable de 2.5 mm²', () {
      final cable = CableCatalog.forCurrent(CableKind.h07rnf, 20);
      expect(cable!.sectionMm2, 2.5);
    });
  });

  group('eléctrico: generadores', () {
    test('100 kVA a 3000 m entregan 88 kVA (70.4 kW)', () {
      final g = PowerEngine.generator(nameplateKva: 100, altitudeM: 3000);
      expect(g.usableKva, closeTo(88, 0.01));
      expect(g.usableKw, closeTo(70.4, 0.01));
      expect(g.deratingFactor, closeTo(0.88, 1e-9));
    });

    test('a nivel del mar y 40 °C no hay pérdida', () {
      final g = PowerEngine.generator(nameplateKva: 100);
      expect(g.usableKva, closeTo(100, 1e-9));
    });

    test('corriente de un generador de 100 kVA a 380 V trifásico', () {
      expect(
        PowerEngine.generatorAmps(kva: 100, voltage: 380),
        closeTo(151.93, 0.01),
      );
    });
  });
}
