import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/data/camera_selection.dart';
import 'package:on_set_pro/presentation/storage_screen.dart';
import 'package:on_set_pro/state/shot_state.dart';

void main() {
  setUp(() {
    ShotState.instance.setCamera(const CameraSelection(
      kind: 'digital',
      manufacturer: 'ARRI',
      camera: 'ALEXA 35',
      mode: '4.6K 3:2 Open Gate',
    ));
  });

  testWidgets('abre con ARRIRAW y muestra la tasa real', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StorageScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('ARRIRAW'), findsWidgets);
    expect(find.textContaining('GB/h'), findsOneWidget);
    expect(find.textContaining('4608x3164'), findsWidgets);
  });

  testWidgets('con 512 GB dice cuánto tiempo entra', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StorageScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('TIEMPO QUE ENTRA'), findsOneWidget);
    // 512 GB con 5 % de overhead de ARRIRAW 4.6K a 24 fps: unos 14 minutos.
    expect(find.textContaining('14m'), findsOneWidget);
  });

  testWidgets('cambiar a minutos pide espacio y calcula GB', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StorageScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('NECESITO MINUTOS'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ESPACIO NECESARIO'), findsOneWidget);
    expect(find.textContaining('GB'), findsWidgets);
  });

  testWidgets('el modo fílmico usa el formato del plano', (tester) async {
    ShotState.instance.setCamera(
      const CameraSelection(kind: 'film', filmFormat: '35mm 4-perf full'),
    );
    await tester.pumpWidget(const MaterialApp(home: StorageScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('CHASIS'), findsWidgets);
    expect(find.textContaining('90.0 ft/min'), findsOneWidget);
    expect(find.textContaining('35mm 4-perf full'), findsWidgets);
  });
}
