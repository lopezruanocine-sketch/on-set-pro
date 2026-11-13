import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:on_set_pro/presentation/viewfinder_screen.dart';

void main() {
  testWidgets('se puede escribir una focal que no está en la lista', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: ViewfinderScreen()));
    await tester.pumpAndSettle();

    // 80 mm existe aunque no esté entre los atajos.
    final field = find.byType(TextField).first;
    await tester.enterText(field, '80');
    await tester.pumpAndSettle();

    expect(find.text('80'), findsWidgets);
  });
}
