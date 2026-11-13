import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/presentation/distro_screen.dart';
import 'package:on_set_pro/presentation/nd_quick_screen.dart';
import 'package:on_set_pro/presentation/solar_screen.dart';

void main() {
  /// Pantalla alta: los controles de estas herramientas quedan abajo.
  void tall(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('ND rápido: f/5.6 de luz contra f/2.8 pide ND 0.6', (tester) async {
    tall(tester);
    await tester.pumpWidget(const MaterialApp(home: NdQuickScreen()));
    await tester.pumpAndSettle();

    // Dos pasos de diferencia: el filtro que los quita es el 0.6.
    expect(find.text('ND 0.6'), findsOneWidget);
    expect(find.textContaining('2.0 pasos'), findsWidgets);
  });

  testWidgets('ND rápido: si el diafragma elegido es el de la luz, no pide filtro', (tester) async {
    tall(tester);
    await tester.pumpWidget(const MaterialApp(home: NdQuickScreen()));
    await tester.pumpAndSettle();

    // Cambiamos el diafragma de luz a f/2.8 en el primer desplegable.
    await tester.tap(find.byType(DropdownButton<double>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('f/2.8').last);
    await tester.pumpAndSettle();

    expect(find.text('NINGUNO'), findsOneWidget);
  });

  testWidgets('luz solar muestra las cuatro ventanas y el sol de ahora', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SolarScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('AZUL DE LA MAÑANA'), findsOneWidget);
    expect(find.textContaining('DORADA DE LA MAÑANA'), findsOneWidget);
    expect(find.textContaining('DORADA DE LA TARDE'), findsOneWidget);
    expect(find.textContaining('AZUL DE LA TARDE'), findsOneWidget);
    expect(find.textContaining('BUENOS AIRES'), findsWidgets);
  });

  testWidgets('distro reparte las cargas y muestra las fases', (tester) async {
    tall(tester);
    await tester.pumpWidget(const MaterialApp(home: DistroScreen()));
    await tester.pumpAndSettle();

    expect(find.text('FASE 1'), findsOneWidget);
    expect(find.text('FASE 2'), findsOneWidget);
    expect(find.text('FASE 3'), findsOneWidget);
    expect(find.textContaining('5 cargas'), findsOneWidget);
    expect(find.textContaining('Desbalance'), findsOneWidget);
  });

  testWidgets('agregar una carga a la distro actualiza el total', (tester) async {
    tall(tester);
    await tester.pumpWidget(const MaterialApp(home: DistroScreen()));
    await tester.pumpAndSettle();

    // Las dos primeras cajas son nombre y potencia de la carga nueva.
    final fields = find.byType(TextField);
    await tester.enterText(fields.first, 'C12');
    await tester.enterText(fields.at(1), '4000');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.textContaining('6 cargas'), findsOneWidget);
    expect(find.text('C12'), findsOneWidget);
  });
}
