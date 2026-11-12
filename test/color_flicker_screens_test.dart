import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/data/camera_selection.dart';
import 'package:on_set_pro/presentation/color_screen.dart';
import 'package:on_set_pro/presentation/flicker_screen.dart';
import 'package:on_set_pro/state/shot_state.dart';

void main() {
  setUp(() {
    ShotState.instance.reset();
    ShotState.instance.setCamera(const CameraSelection(
      kind: 'digital',
      manufacturer: 'ARRI',
      camera: 'ALEXA 35',
      mode: '4.6K 3:2 Open Gate',
    ));
  });

  group('color', () {
    testWidgets('tungsteno contra diurno pide un CTB', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ColorScreen()));
      await tester.pumpAndSettle();

      // 3200 K contra 5600 K: −133 mireds.
      expect(find.textContaining('-133'), findsWidgets);
      expect(find.textContaining('CTB'), findsWidgets);
      expect(find.textContaining('K'), findsWidgets);
    });

    testWidgets('si la fuente ya es la cámara no propone gel', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ColorScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DIURNO 5600'));
      await tester.pumpAndSettle();

      expect(find.textContaining('ya coincide'), findsOneWidget);
    });

    testWidgets('muy verde pide un minus green', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ColorScreen()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('MUY VERDE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('MUY VERDE'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Minus Green'), findsWidgets);
    });
  });

  group('flicker', () {
    testWidgets('50 Hz a 24 fps con 180° avisa que parpadea', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FlickerScreen()));
      await tester.pumpAndSettle();

      expect(find.text('PARPADEA'), findsOneWidget);
      expect(find.textContaining('172.8°'), findsWidgets);
    });

    testWidgets('tocar una ventana cambia el obturador del plano', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FlickerScreen()));
      await tester.pumpAndSettle();

      final tile = find.text('172.8°');
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile.first);
      await tester.pumpAndSettle();

      expect(ShotState.instance.shutterAngle, closeTo(172.8, 0.01));
      expect(find.text('SIN PARPADEO'), findsOneWidget);
    });

    testWidgets('a 25 fps con 50 Hz el 180° ya es seguro', (tester) async {
      ShotState.instance.setFps(25);
      await tester.pumpWidget(const MaterialApp(home: FlickerScreen()));
      await tester.pumpAndSettle();

      expect(find.text('SIN PARPADEO'), findsOneWidget);
    });
  });
}
