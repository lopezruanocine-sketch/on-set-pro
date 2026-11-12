import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/data/catalogs/codecs.dart';
import 'package:on_set_pro/domain/storage/storage_engine.dart';

void main() {
  group('catálogo de códecs', () {
    test('tiene cargadas las familias principales', () {
      final names = Codecs.codecNames;
      expect(names, contains('ARRIRAW'));
      expect(names, contains('ProRes 422 HQ'));
      expect(names, contains('BRAW 5:1'));
      expect(names, contains('X-OCN LT'));
      expect(names.length, greaterThan(20));
    });

    test('ARRIRAW 4.6K a 24 fps consume 2047 GB por hora', () {
      final r = Codecs.find('ARRIRAW', '4608x3164', 24)!;
      expect(r.gigabytesPerHour, closeTo(2047, 1));
      expect(r.megabytesPerSecond, closeTo(568.6, 0.1));
    });

    test('ProRes 422 HQ en UHD a 30 fps consume 398 GB por hora', () {
      final r = Codecs.find('ProRes 422 HQ', '3840x2160', 30)!;
      expect(r.gigabytesPerHour, closeTo(397.8, 0.5));
    });

    test('buscar un códec inexistente devuelve null', () {
      expect(Codecs.find('NoExiste', '4096x2160', 24), isNull);
    });
  });

  group('grabación', () {
    test('ARRIRAW 4.6K en un disco de 1000 GB entra media hora', () {
      final e = StorageEngine.recording(mbps: 4549, capacityGb: 1000);
      expect(e.duration.inSeconds, closeTo(1758, 2));
      expect(StorageEngine.formatDuration(e.duration), '29m 18s');
    });

    test('ProRes 422 HQ en 512 GB entra poco más de una hora', () {
      final e = StorageEngine.recording(mbps: 884, capacityGb: 512);
      expect(e.duration.inMinutes, 77);
    });

    test('descontar 5 % de overhead reduce el tiempo', () {
      final sin = StorageEngine.recording(mbps: 884, capacityGb: 512);
      final con = StorageEngine.recording(mbps: 884, capacityGb: 512, overhead: 0.05);
      expect(con.duration.inSeconds, lessThan(sin.duration.inSeconds));
      expect(con.duration.inSeconds, closeTo(sin.duration.inSeconds * 0.95, 2));
    });

    test('cuántas tarjetas hacen falta para un plan de 90 minutos', () {
      final e = StorageEngine.recording(
        mbps: 4549,
        capacityGb: 640,
        wantedMinutes: 90,
      );
      expect(e.cardsNeeded, greaterThan(1));
    });

    test('GB por 10 minutos de ProRes 422 HQ UHD', () {
      expect(
        StorageEngine.gigabytesForMinutes(mbps: 884, minutes: 10),
        closeTo(66.3, 0.2),
      );
    });
  });

  group('copia DIT', () {
    test('100 GB con disco de 500 MB/s y 25 % de pérdida tardan 4m 27s', () {
      final c = StorageEngine.copyTime(
        gigabytes: 100,
        readMbps: 1000,
        writeMbps: 500,
      );
      expect(c.effectiveMegabytesPerSecond, closeTo(375, 0.01));
      expect(c.duration.inSeconds, closeTo(267, 1));
      expect(StorageEngine.formatDuration(c.duration), '4m 26s');
    });

    test('si la lectura es el cuello de botella, manda la lectura', () {
      final c = StorageEngine.copyTime(
        gigabytes: 100,
        readMbps: 200,
        writeMbps: 1000,
      );
      expect(c.effectiveMegabytesPerSecond, closeTo(150, 0.01));
    });

    test('copiar y verificar duplica el tiempo', () {
      final simple = StorageEngine.copyTime(
        gigabytes: 100,
        readMbps: 1000,
        writeMbps: 500,
      );
      final verificado = StorageEngine.copyTime(
        gigabytes: 100,
        readMbps: 1000,
        writeMbps: 500,
        verificationFactor: 2,
      );
      expect(verificado.duration.inSeconds, closeTo(simple.duration.inSeconds * 2, 1));
    });
  });
}
