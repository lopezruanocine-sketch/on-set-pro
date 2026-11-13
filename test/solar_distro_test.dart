import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/domain/astro/solar_calculator.dart';
import 'package:on_set_pro/domain/power/distro.dart';

void main() {
  group('sol', () {
    // 21 de junio de 2026, Buenos Aires (−34.6037, −58.3816), UTC−3.
    const lat = -34.6037;
    const lon = -58.3816;
    const offset = Duration(hours: -3);
    final day = DateTime.utc(2026, 6, 21, 12);

    test('el solsticio de junio en Buenos Aires: amanecer ~08:00 y atardecer ~17:50', () {
      final sunrise = SolarCalculator.crossing(
        day: day, latitude: lat, longitude: lon, altitude: -0.833, rising: false,
      )!.add(offset);
      final sunset = SolarCalculator.crossing(
        day: day, latitude: lat, longitude: lon, altitude: -0.833, rising: true,
      )!.add(offset);

      // La hora local depende de la fecha: comparamos por minutos desde
      // medianoche para no arrastrar el cambio de día.

      // Datos de efemérides: 08:00 y 17:50, con tolerancia de 5 minutos.
      // Efemérides de Buenos Aires: 08:00 y 17:50.
      expect(sunrise.hour * 60 + sunrise.minute, closeTo(8 * 60 + 0, 5));
      expect(sunset.hour * 60 + sunset.minute, closeTo(17 * 60 + 50, 5));
    });

    test('la altura del sol al mediodía es la esperada para el solsticio', () {
      // Mediodía solar ≈ 12:56 hora local. Altura ≈ 90 − 34.6 − 23.4 = 32°.
      final pos = SolarCalculator.position(
        when: DateTime.utc(2026, 6, 21, 15, 56),
        latitude: lat,
        longitude: lon,
      );
      expect(pos.altitudeDegrees, closeTo(32.0, 3.0));
      expect(pos.cardinal, 'N');
    });

    test('la ecuatorial: en equinoccio el sol sale casi a las 6 y se pone casi a las 18', () {
      final eqDay = DateTime.utc(2026, 3, 20, 12);
      // El cálculo toma la mañana como ángulo horario negativo: con `rising:
      // false` devuelve el cruce de la madrugada.
      final sunrise = SolarCalculator.crossing(
        day: eqDay, latitude: 0, longitude: 0, altitude: -0.833, rising: false,
      )!;
      final sunset = SolarCalculator.crossing(
        day: eqDay, latitude: 0, longitude: 0, altitude: -0.833, rising: true,
      )!;
      // En el equinoccio el día dura casi 12 horas: 06:03 y 18:10 por la
      // refracción atmosférica y el tamaño del disco solar.
      expect(sunrise.hour * 60 + sunrise.minute, closeTo(6 * 60, 10));
      expect(sunset.hour * 60 + sunset.minute, closeTo(18 * 60 + 10, 10));
    });

    test('las ventanas de luz son cuatro y en orden', () {
      final windows = SolarCalculator.windows(
        day: day, latitude: lat, longitude: lon, utcOffset: offset,
      );
      expect(windows.map((w) => w.label), [
        'AZUL DE LA MAÑANA',
        'DORADA DE LA MAÑANA',
        'DORADA DE LA TARDE',
        'AZUL DE LA TARDE',
      ]);
      // Las cuatro ventanas existen; en algunos casos el azul y la dorada se
      // tocan (el sol cruza rápido el horizonte), así que se ordenan por inicio.
      for (var i = 1; i < windows.length; i++) {
        expect(
          !windows[i].start.isBefore(windows[i - 1].start),
          isTrue,
          reason: '${windows[i].label} debe empezar después de ${windows[i - 1].label}',
        );
      }
      // La dorada de la tarde en invierno dura menos de una hora.
      final goldenPM = windows[2];
      expect(goldenPM.duration.inMinutes, greaterThan(10));
      expect(goldenPM.duration.inMinutes, lessThan(90));
    });

    test('el amanecer del 21 de diciembre es mucho más temprano que el de junio', () {
      int minutesOfDay(DateTime t) => t.hour * 60 + t.minute;

      final junio = SolarCalculator.crossing(
        day: DateTime.utc(2026, 6, 21, 12), latitude: lat, longitude: lon,
        altitude: -0.833, rising: false,
      )!;
      final diciembre = SolarCalculator.crossing(
        day: DateTime.utc(2026, 12, 21, 12), latitude: lat, longitude: lon,
        altitude: -0.833, rising: false,
      )!;
      // En Buenos Aires amanece cerca de las 5:40 en diciembre y 8:00 en junio.
      expect(minutesOfDay(diciembre), lessThan(minutesOfDay(junio)));
      expect(minutesOfDay(junio) - minutesOfDay(diciembre), greaterThan(45));
    });

    test('en el polo norte en invierno no hay amanecer', () {
      final sunrise = SolarCalculator.crossing(
        day: DateTime.utc(2026, 12, 21, 12), latitude: 80, longitude: 0,
        altitude: -0.833, rising: false,
      );
      expect(sunrise, isNull);
    });
  });

  group('distro', () {
    test('reparte cinco cargas y deja las fases parejas', () {
      final plan = DistroEngine.distribute(
        loads: const [
          Load(name: 'M18', watts: 1800),
          Load(name: 'M18', watts: 1800),
          Load(name: 'Skypanel', watts: 900),
          Load(name: 'Skypanel', watts: 900),
          Load(name: 'LED', watts: 200),
        ],
        voltage: 380,
        limitAmps: 32,
      );
      expect(plan.assigned.length, 5);
      // El reparto busca la fase más liviana: 1800/1800/900/900/200 deja
      // 1800+200, 1800 y 900+900.
      expect(plan.phaseWatts.reduce((a, b) => a + b), closeTo(5600, 0.01));
      expect(
        DistroEngine.imbalancePercent(plan.phaseWatts),
        lessThan(45),
        reason: 'las fases no deben quedar desbalanceadas',
      );
    });

    test('tres cargas iguales quedan perfectamente balanceadas', () {
      final plan = DistroEngine.distribute(
        loads: const [
          Load(name: 'A', watts: 1000),
          Load(name: 'B', watts: 1000),
          Load(name: 'C', watts: 1000),
        ],
        voltage: 380,
        limitAmps: 32,
      );
      expect(plan.isBalanced, isTrue);
      expect(plan.phaseWatts, [1000.0, 1000.0, 1000.0]);
    });

    test('respeta las cargas ya asignadas a una fase', () {
      final plan = DistroEngine.distribute(
        loads: const [
          Load(name: 'fija', watts: 2000, phase: 2),
          Load(name: 'nueva', watts: 500),
        ],
        voltage: 380,
        limitAmps: 32,
      );
      expect(plan.phaseWatts[2], 2000);
      expect(plan.phaseWatts[0], 500);
    });

    test('calcula la corriente con la tensión de fase', () {
      final plan = DistroEngine.distribute(
        loads: const [Load(name: 'A', watts: 10000)],
        voltage: 380,
        limitAmps: 32,
      );
      // 10000 W a tensión de fase (219.4 V) son 45.6 A.
      expect(plan.phaseAmps[0], closeTo(45.58, 0.1));
      expect(plan.isOverloaded, isTrue);
    });

    test('la fase más cargada se informa en 1, 2 o 3', () {
      final plan = DistroEngine.distribute(
        loads: const [
          Load(name: 'A', watts: 100),
          Load(name: 'B', watts: 3000),
        ],
        voltage: 380,
        limitAmps: 32,
      );
      expect(plan.heaviestPhase, 1);
    });
  });
}
