import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/domain/calculator/cine_math.dart';
import 'package:on_set_pro/presentation/cine_calculator_screen.dart';

/// Simula un teléfono y toca una tecla desplazándose hasta ella.
Future<void> tapKey(WidgetTester tester, String key) async {
  final finder = find.text(key).first;
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
}

void main() {
  // Pantalla de teléfono: el teclado se desplaza si la altura no alcanza.
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  void phoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('calcula 1/48 y muestra la fracción', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(const MaterialApp(home: CineCalculatorScreen()));
    await tester.pumpAndSettle();

    for (final key in ['1', '÷', '4', '8']) {
      await tapKey(tester, key);
    }

    expect(find.text(CineMath.formatNumber(1 / 48)), findsWidgets);
    expect(find.textContaining('1/48'), findsWidgets);
  });

  testWidgets('la tecla 1/x invierte el valor', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(const MaterialApp(home: CineCalculatorScreen()));
    await tester.pumpAndSettle();

    for (final key in ['4', '8']) {
      await tapKey(tester, key);
    }
    await tapKey(tester, '1/x');

    expect(find.text(CineMath.formatNumber(1 / 48)), findsWidgets);
  });

  testWidgets('USAR devuelve el número elegido', (tester) async {
    phoneSize(tester);
    double? returned;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            returned = await showCineCalculator(context, initial: 48);
          },
          child: const Text('abrir'),
        ),
      ),
    ));

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USAR'));
    await tester.pumpAndSettle();

    expect(returned, 48);
  });

  testWidgets('arranca con el valor que le pasan', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(const MaterialApp(
      home: CineCalculatorScreen(initial: 2.8),
    ));
    await tester.pumpAndSettle();
    expect(find.text('2.8'), findsWidgets);
  });
}
