import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/presentation/electricity_screen.dart';

Future<void> pumpScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: ElectricityScreen()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tie-in de 1000 W a 220 V monofásico consume 4.5 A', (tester) async {
    await pumpScreen(tester);
    expect(find.text('4.5'), findsOneWidget);
    expect(find.textContaining('monofásico'), findsOneWidget);
  });

  testWidgets('el cable H07RN-F de 2.5 mm² declara 25 A de ampacidad', (tester) async {
    await pumpScreen(tester);
    expect(find.textContaining('H07RN-F'), findsWidgets);
    expect(find.text('25 A'), findsOneWidget);
  });

  testWidgets('al elegir SOOW la tabla cambia a AWG y baja la ampacidad', (tester) async {
    await pumpScreen(tester);
    await tester.ensureVisible(find.text('SOOW (AWG)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SOOW (AWG)'));
    await tester.pumpAndSettle();

    expect(find.textContaining('SOOW 14 AWG'), findsWidgets);
    // 14 AWG aguanta 15 A, no 25.
    expect(find.text('15 A'), findsOneWidget);
  });

  testWidgets('con 6000 W en un cable de 2.5 mm² avisa peligro térmico', (tester) async {
    await pumpScreen(tester);

    // 6000 W a 220 V son 27.3 A: más de los 25 A que aguanta el cable.
    final watts = find.byType(TextField).at(2);
    await tester.ensureVisible(watts);
    await tester.enterText(watts, '6000');
    await tester.pumpAndSettle();

    expect(find.textContaining('PELIGRO TÉRMICO'), findsOneWidget);
  });

  testWidgets('el generador pierde capacidad con la altura', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('GENERADOR'));
    await tester.pumpAndSettle();

    expect(find.textContaining('kVA'), findsWidgets);
  });
}
