import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/data/catalogs/film_formats.dart';
import 'package:on_set_pro/data/catalogs/sensors.dart';

void main() {
  group('catálogo de cámaras', () {
    test('tiene las 25 cámaras y 82 modos', () {
      expect(SensorCatalog.cameras.length, 25);
      expect(SensorCatalog.all.length, 82);
    });

    test('ARRI ALEXA 35 4.6K 3:2 con su área real', () {
      final m = SensorCatalog.byId('ARRI', 'ALEXA 35', '4.6K 3:2 Open Gate')!;
      expect(m.widthMm, 27.99);
      expect(m.heightMm, 19.22);
      expect(m.widthPx, 4608);
      expect(m.baseIso, 800);
      expect(m.diagonalMm, closeTo(34.0, 0.1));
      expect(m.coc1500Mm, closeTo(0.0226, 0.0005));
    });

    test('VENICE 2 6K tiene ISO base 500, no 800', () {
      final m = SensorCatalog.byId('SONY', 'VENICE 2 6K', '6K 3:2')!;
      expect(m.baseIso, 500);
    });

    test('la Canon C400 no es 36x24 y tiene triple ISO', () {
      final m = SensorCatalog.modesOfCamera('EOS C400').first;
      expect(m.widthMm, closeTo(36.0, 0.01));
      expect(m.heightMm, closeTo(19.0, 0.01));
      expect(m.baseIso, 800);
    });

    test('ALEXA 265 queda sin ISO verificado en vez de inventado', () {
      final modes = SensorCatalog.modesOfCamera('ALEXA 265');
      expect(modes, isNotEmpty);
      expect(modes.every((m) => m.baseIso == null), isTrue);
    });

    test('cada cámara tiene al menos un modo', () {
      for (final c in SensorCatalog.cameras) {
        expect(SensorCatalog.modesOf(c), isNotEmpty, reason: c);
      }
    });

    test('el CoC por diagonal/1500 queda en rango razonable para todos los modos', () {
      for (final m in SensorCatalog.all) {
        expect(m.coc1500Mm, greaterThan(0.003), reason: m.label);
        expect(m.coc1500Mm, lessThan(0.06), reason: m.label);
      }
    });
  });

  group('catálogo fílmico', () {
    test('tiene los doce formatos', () {
      expect(FilmFormats.all.length, 12);
    });

    test('35 mm 4-perf gasta 90 pies por minuto', () {
      final f = FilmFormats.byName('35mm 4-perf full')!;
      expect(f.feetPerMinute, 90);
      expect(f.metresPerMinute, closeTo(27.43, 0.01));
      expect(f.perfsPerFrame, 4);
    });

    test('400 pies de 35 mm 4-perf son 4m 27s', () {
      final f = FilmFormats.byName('35mm 4-perf full')!;
      expect(f.minutesForFeet(400), closeTo(4.444, 0.01));
    });

    test('400 pies de 35 mm 3-perf duran más que en 4-perf', () {
      final cuatro = FilmFormats.byName('35mm 4-perf full')!;
      final tres = FilmFormats.byName('35mm 3-perf')!;
      expect(tres.minutesForFeet(400), greaterThan(cuatro.minutesForFeet(400)));
      expect(tres.feetPerMinute, 67.5);
    });

    test('2-perf consume la mitad de metraje que 4-perf', () {
      final dos = FilmFormats.byName('35mm 2-perf Techniscope')!;
      expect(dos.feetPerMinute, 45);
    });

    test('1000 pies de 65 mm 5-perf son casi 9 minutos', () {
      final f = FilmFormats.byName('65mm 5-perf (5/70)')!;
      expect(f.minutesForFeet(1000), closeTo(8.889, 0.01));
    });

    test('un cartucho de Super 8 de 50 pies dura 2.5 minutos', () {
      final f = FilmFormats.byName('Super 8')!;
      expect(f.minutesForFeet(50), closeTo(2.5, 0.01));
    });

    test('los metros por minuto son los pies convertidos', () {
      for (final f in FilmFormats.all) {
        expect(f.metresPerMinute, closeTo(f.feetPerMinute * 0.3048, 0.05), reason: f.name);
      }
    });

    test('el 65 mm 5-perf tiene más superficie que el 35 mm 4-perf', () {
      final grande = FilmFormats.byName('65mm 5-perf (5/70)')!;
      final chico = FilmFormats.byName('35mm 4-perf full')!;
      expect(grande.diagonalMm, greaterThan(chico.diagonalMm));
      expect(grande.cocMm, greaterThan(chico.cocMm));
    });
  });
}
