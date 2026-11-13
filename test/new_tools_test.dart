import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/presentation/electricity_screen.dart';
import 'package:on_set_pro/presentation/solar_screen.dart';

void main() {
  /// Pantalla alta: los controles de estas herramientas quedan abajo.
  void tall(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('luz solar muestra las cuatro ventanas y el sol de ahora', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SolarScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('AZUL DE LA MAÑANA'), findsOneWidget);
    expect(find.textContaining('DORADA DE LA MAÑANA'), findsOneWidget);
    expect(find.textContaining('DORADA DE LA TARDE'), findsOneWidget);
    expect(find.textContaining('AZUL DE LA TARDE'), findsOneWidget);
    expect(find.textContaining('BUENOS AIRES'), findsWidgets);
  });

  testWidgets('el eléctrico tiene la pestaña de fases y reparte cargas', (tester) async {
    tall(tester);
    await tester.pumpWidget(const MaterialApp(home: ElectricityScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(Tab, 'FASES'));
    await tester.pumpAndSettle();

    expect(find.text('FASE 1'), findsOneWidget);
    expect(find.text('FASE 2'), findsOneWidget);
    expect(find.text('FASE 3'), findsOneWidget);
    // La distro arranca vacía: se carga con lo que hay en el camión.
    expect(find.textContaining('Cargá las luminarias'), findsOneWidget);
    expect(find.text('CARGAR UN EJEMPLO'), findsOneWidget);
  });

  testWidgets('agregar una carga a la distro actualiza el total', (tester) async {
    tall(tester);
    await tester.pumpWidget(const MaterialApp(home: ElectricityScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Tab, 'FASES'));
    await tester.pumpAndSettle();

    // Las dos primeras cajas son nombre y potencia de la carga nueva.
    final fields = find.byType(TextField);
    await tester.enterText(fields.first, 'C12');
    await tester.enterText(fields.at(1), '4000');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 cargas'), findsOneWidget);
    expect(find.text('C12'), findsOneWidget);
  });
}
