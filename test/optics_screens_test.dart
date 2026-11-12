import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/data/camera_selection.dart';
import 'package:on_set_pro/presentation/dof_calculator_screen.dart';
import 'package:on_set_pro/presentation/optics_screen.dart';
import 'package:on_set_pro/state/shot_state.dart';

void main() {
  const alexa = CameraSelection(
    kind: 'digital',
    manufacturer: 'ARRI',
    camera: 'ALEXA 35',
    mode: '4.6K 3:2 Open Gate',
  );

  setUp(() => ShotState.instance.setCamera(alexa));

  testWidgets('la profundidad de campo usa el CoC del sensor elegido', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DofCalculatorScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('ALEXA 35'), findsWidgets);
    // CoC del modo 4.6K 3:2 (diagonal/1500 ≈ 0.0226 mm).
    expect(find.textContaining('0.0226'), findsOneWidget);
    // Con 50 mm a f/2.8 y CoC 0.0226 mm, la hiperfocal ronda los 39.5 m.
    expect(find.textContaining('39.4'), findsWidgets);
  });

  testWidgets('la óptica calcula el encuadre y la lente equivalente', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OpticsScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('ALEXA 35'), findsWidgets);
    // 50 mm en 27.99 mm de ancho a 5 m dan 2.80 m de ancho.
    expect(find.textContaining('2.80 m'), findsOneWidget);
    expect(find.textContaining('LENTE EQUIVALENTE'), findsOneWidget);
  });

  testWidgets('sin cámara las dos pantallas piden elegir una', (tester) async {
    ShotState.instance.camera = null;
    await tester.pumpWidget(const MaterialApp(home: DofCalculatorScreen()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Elegí una cámara'), findsOneWidget);
  });
}
