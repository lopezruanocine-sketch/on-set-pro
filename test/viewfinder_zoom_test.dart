import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:on_set_pro/data/camera_selection.dart';
import 'package:on_set_pro/domain/optics/units_format.dart';
import 'package:on_set_pro/domain/optics/viewfinder_math.dart';
import 'package:on_set_pro/presentation/viewfinder_screen.dart';
import 'package:on_set_pro/state/shot_state.dart';

void main() {
  group('visor: el cuadro no se achica, la imagen hace zoom', () {
    test('un tele pide zoom digital mayor que 1', () {
      final f = ViewfinderMath.frame(
        phoneHorizontalFovDegrees: 70,
        sensorWidthMm: 24.89,
        sensorHeightMm: 18.66,
        focalMm: 85,
      );
      final zoom = 1 / f.widthFraction;
      expect(zoom, greaterThan(3));
      expect(f.widthFraction, lessThan(0.4));
    });

    test('un gran angular más abierto que el teléfono no puede hacer zoom', () {
      final f = ViewfinderMath.frame(
        phoneHorizontalFovDegrees: 30,
        sensorWidthMm: 36,
        sensorHeightMm: 24,
        focalMm: 14,
      );
      // El cuadro queda a pantalla completa: falta imagen para recortar.
      expect(f.widthFraction, 1.0);
      expect(1 / f.widthFraction, 1.0);
    });

    test('el zoom crece al alargar la focal', () {
      double zoomFor(double focal) => 1 /
          ViewfinderMath.frame(
            phoneHorizontalFovDegrees: 70,
            sensorWidthMm: 27.99,
            sensorHeightMm: 19.22,
            focalMm: focal,
          ).widthFraction;

      expect(zoomFor(25), lessThan(zoomFor(50)));
      expect(zoomFor(50), lessThan(zoomFor(100)));
    });
  });

  group('distancias como se dicen en el set', () {
    test('menos de un metro va en centímetros', () {
      expect(formatDistance(millimetres: 350), '35 cm');
      expect(formatDistance(millimetres: 999), '100 cm');
    });

    test('más de un metro va en metros', () {
      expect(formatDistance(millimetres: 1500), '1.50 m');
      expect(formatDistance(millimetres: 39490), '39.49 m');
    });

    test('infinito se dice infinito', () {
      expect(formatDistance(millimetres: double.infinity), 'INFINITO');
    });

    test('en pies, menos de un pie va en pulgadas', () {
      expect(formatDistance(millimetres: 200, useFeet: true), '8 in');
      expect(formatDistance(millimetres: 1000, useFeet: true), '3.28 ft');
    });
  });

  testWidgets('el visor arranca con el sensor de la cámara elegida', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // ALEXA 35: 27.99 mm de ancho.
    ShotState.instance.setCamera(const CameraSelection(
      kind: 'digital',
      manufacturer: 'ARRI',
      camera: 'ALEXA 35',
      mode: '4.6K 3:2 Open Gate',
    ));

    await tester.pumpWidget(const MaterialApp(home: ViewfinderScreen()));
    await tester.pumpAndSettle();

    // No se pregunta dos veces: el sensor ya viene elegido.
    expect(find.text('ALEXA 35'), findsWidgets);
    expect(find.text('SÚPER 16'), findsNothing);
  });
}
