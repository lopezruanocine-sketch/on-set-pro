import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/data/camera_selection.dart';
import 'package:on_set_pro/presentation/electricity_screen.dart';
import 'package:on_set_pro/presentation/panels/distro_panel.dart';
import 'package:on_set_pro/domain/power/power_engine.dart';
import 'package:on_set_pro/state/shot_state.dart';

void main() {
  Future<void> pumpDistro(WidgetTester tester, {double? limit = 32}) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DistroPanel(
          voltage: 380,
          phases: Phases.three,
          limitAmps: limit,
          sourceLabel: 'Generador 20 kVA',
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('una carga nueva entra en AUTO y se puede mover a mano', (tester) async {
    await pumpDistro(tester);

    await tester.enterText(find.byType(TextField).first, 'M18');
    await tester.enterText(find.byType(TextField).at(1), '1800');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('M18'), findsOneWidget);
    expect(find.text('AUTO'), findsWidgets);

    // Tocar AUTO la fija en F1, después F2, F3 y vuelve a AUTO.
    final auto = find.text('AUTO').first;
    await tester.tap(auto);
    await tester.pumpAndSettle();
    expect(find.text('F1'), findsWidgets);

    await tester.tap(find.text('F1').first);
    await tester.pumpAndSettle();
    expect(find.text('F2'), findsWidgets);
  });

  testWidgets('editar una carga cambia nombre y watts sin borrarla', (tester) async {
    await pumpDistro(tester);

    await tester.enterText(find.byType(TextField).first, 'M18');
    await tester.enterText(find.byType(TextField).at(1), '1800');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('M18'));
    await tester.pumpAndSettle();

    // Los campos del diálogo, no los de la carga nueva.
    final dialogFields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(dialogFields.first, 'M18 con difusor');
    await tester.enterText(dialogFields.at(1), '2400');
    // El diálogo tiene su propio GUARDAR; el de la barra de repartos queda detrás.
    await tester.tap(find.text('GUARDAR').last);
    await tester.pumpAndSettle();

    expect(find.text('M18 con difusor'), findsOneWidget);
    expect(find.text('2400 W'), findsOneWidget);
  });

  testWidgets('sin soporte elegido avisa que falta el límite', (tester) async {
    await pumpDistro(tester, limit: null);
    expect(find.textContaining('Elegí el soporte en CIRCUITO'), findsOneWidget);
  });

  testWidgets('el panel de fases toma el límite del soporte', (tester) async {
    tester.view.physicalSize = const Size(430, 1500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    ShotState.instance.setCamera(const CameraSelection(
      kind: 'digital',
      manufacturer: 'ARRI',
      camera: 'ALEXA 35',
      mode: '4.6K 3:2 Open Gate',
    ));
    await tester.pumpWidget(const MaterialApp(home: ElectricityScreen(initialTab: 1)));
    await tester.pumpAndSettle();

    expect(find.textContaining('Red (tie-in)'), findsOneWidget);
    expect(find.textContaining('límite 32.0 A'), findsOneWidget);
  });
}
