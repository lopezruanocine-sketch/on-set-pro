import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/domain/optics/viewfinder_math.dart';

void main() {
  group('visor', () {
    test('una focal más larga achica la ventana sobre la vista', () {
      final wide = ViewfinderMath.frame(
        phoneHorizontalFovDegrees: 70,
        sensorWidthMm: ViewfinderMath.s16WidthMm,
        sensorHeightMm: ViewfinderMath.s16HeightMm,
        focalMm: 18,
      );
      final long = ViewfinderMath.frame(
        phoneHorizontalFovDegrees: 70,
        sensorWidthMm: ViewfinderMath.s16WidthMm,
        sensorHeightMm: ViewfinderMath.s16HeightMm,
        focalMm: 50,
      );
      expect(long.widthFraction, lessThan(wide.widthFraction));
      expect(long.widthFraction, lessThan(1));
    });

    test('el anamórfico desplega el cuadro', () {
      final esferico = ViewfinderMath.frame(
        phoneHorizontalFovDegrees: 70,
        sensorWidthMm: 21.6,
        sensorHeightMm: 18.0,
        focalMm: 32,
        squeeze: 1,
      );
      final ana = ViewfinderMath.frame(
        phoneHorizontalFovDegrees: 70,
        sensorWidthMm: 21.6,
        sensorHeightMm: 18.0,
        focalMm: 32,
        squeeze: 2,
      );
      // El cuadro de sensor se comprime /2 en horizontal (squeeze): el alto
      // aparente relativamente es mayor, la relación se divide por 2.
      expect(ana.aspectRatio, closeTo(esferico.aspectRatio / 2, 1e-9));
    });

    test('detecta si la circular de imagen cubre el sensor', () {
      final cubre = ViewfinderMath.frame(
        phoneHorizontalFovDegrees: 70,
        sensorWidthMm: 12.52,
        sensorHeightMm: 7.41,
        focalMm: 25,
      );
      expect(cubre.coversSensor, isTrue);

      final noCubre = ViewfinderMath.frame(
        phoneHorizontalFovDegrees: 70,
        sensorWidthMm: 36,
        sensorHeightMm: 24,
        focalMm: 25,
        imageCircleMm: 30,
      );
      expect(noCubre.coversSensor, isFalse);
      expect(noCubre.cropFactor, lessThan(1));
    });

    test('el campo de visión de referencia de un sensor full frame a 50 mm', () {
      expect(ViewfinderMath.requiredFovDegrees(36, 50), closeTo(39.6, 0.1));
    });

    test('fov del teléfono extremo no rompe el cálculo', () {
      final r = ViewfinderMath.frame(
        phoneHorizontalFovDegrees: 5,
        sensorWidthMm: 36,
        sensorHeightMm: 24,
        focalMm: 24,
      );
      expect(r.widthFraction, 1.0);
    });
  });
}
