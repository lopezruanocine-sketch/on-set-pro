import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:on_set_pro/presentation/camera_setup_screen.dart';
import 'package:on_set_pro/presentation/dashboard_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('elegir cámara y modo habilita el ingreso y guarda la selección',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: CameraSetupScreen()));
    await tester.pumpAndSettle();

    // Sin elegir nada, el botón está deshabilitado.
    var button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'INGRESAR'),
    );
    expect(button.onPressed, isNull);

    // Elegir DIGITAL.
    await tester.tap(find.text('DIGITAL'));
    await tester.pumpAndSettle();

    // Abrir el desplegable de cámara y elegir ARRI ALEXA 35.
    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ARRI ALEXA 35').last);
    await tester.pumpAndSettle();

    // Se autoselecciona el primer modo y aparecen los datos del sensor.
    expect(find.textContaining('0.0226'), findsOneWidget);
    expect(find.textContaining('ISO base 800'), findsOneWidget);

    button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'INGRESAR'),
    );
    expect(button.onPressed, isNotNull);

    // Entrar: guarda y navega al menú.
    await tester.ensureVisible(find.text('INGRESAR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('INGRESAR'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.textContaining('ALEXA 35'), findsWidgets);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('camera.kind'), 'digital');
    expect(prefs.getString('camera.camera'), 'ALEXA 35');
    expect(prefs.getString('camera.mode'), '4.6K 3:2 Open Gate');
  });

  testWidgets('el modo fílmico pide formato y muestra su consumo',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: CameraSetupScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('FÍLMICO'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('35mm 4-perf full').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('90 ft/min'), findsOneWidget);
    expect(find.textContaining('0.0254'), findsOneWidget);
  });
}
