import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/data/camera_selection.dart';
import 'package:on_set_pro/presentation/dashboard_screen.dart';
import 'package:on_set_pro/presentation/exposure_screen.dart';
import 'package:on_set_pro/state/shot_state.dart';

void main() {
  const camera = CameraSelection(
    kind: 'digital',
    manufacturer: 'ARRI',
    camera: 'ALEXA 35',
    mode: '4.6K 3:2 Open Gate',
  );

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    ShotState.instance.setCamera(camera);
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen(selection: camera)));
    await tester.pumpAndSettle();
  }

  testWidgets('el menú está agrupado en cinco departamentos', (tester) async {
    await pump(tester);
    for (final name in [
      'CIRCUITO',
      'FASES',
      'CÁMARA Y ÓPTICA',
      'IMAGEN Y EXPOSICIÓN',
      'PRODUCCIÓN',
      'UTILIDADES',
    ]) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
  });

  testWidgets('cada herramienta aparece una sola vez', (tester) async {
    await pump(tester);
    const tools = [
      'VISOR DE CÁMARA',
      'ÓPTICA / FOV',
      'PROFUNDIDAD DE CAMPO',
      'SISTEMA DE ZONAS / EXPO',
      'FLICKER Y PARPADEO',
      'CIRCUITO',
      'FASES',
      'COLOR Y GELES',
      'LUZ SOLAR',
      'DATA Y ALMACENAMIENTO',
      'PLANOS Y NOTAS',
      'CALCULADORA DE CINE',
      'LINTERNA',
    ];
    for (final tool in tools) {
      expect(find.text(tool), findsOneWidget, reason: tool);
    }
  });

  testWidgets('la cámara activa muestra sensor y CoC', (tester) async {
    await pump(tester);
    expect(find.textContaining('ALEXA 35'), findsWidgets);
    expect(find.textContaining('0.0226'), findsOneWidget);
  });

  testWidgets('tocar una herramienta la abre', (tester) async {
    await pump(tester);
    await tester.scrollUntilVisible(find.text('SISTEMA DE ZONAS / EXPO'), 200);
    await tester.tap(find.text('SISTEMA DE ZONAS / EXPO'));
    await tester.pumpAndSettle();
    expect(find.byType(ExpoFotoTabs), findsOneWidget);
  });

  testWidgets('en modo fílmico la tarjeta de data cambia de nombre', (tester) async {
    const film = CameraSelection(kind: 'film', filmFormat: '35mm 4-perf full');
    tester.view.physicalSize = const Size(420, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    ShotState.instance.setCamera(film);
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen(selection: film)));
    await tester.pumpAndSettle();

    expect(find.text('CHASIS Y METRAJE'), findsOneWidget);
    expect(find.text('DATA Y ALMACENAMIENTO'), findsNothing);
  });
}
