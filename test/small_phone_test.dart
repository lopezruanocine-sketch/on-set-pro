import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/presentation/camera_setup_screen.dart';

void main() {
  // Pantallas chicas reales: iPhone SE y un Android común.
  for (final size in const [Size(375, 667), Size(360, 780), Size(390, 844)]) {
    testWidgets('la pantalla de inicio entra en ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: CameraSetupScreen()));
      await tester.pumpAndSettle();

      // Si algo se desborda, el test falla con "A RenderFlex overflowed".
      expect(tester.takeException(), isNull);
      expect(find.text('INGRESAR'), findsOneWidget);
    });
  }
}
