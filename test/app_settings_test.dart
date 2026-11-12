import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:on_set_pro/data/app_settings.dart';
import 'package:on_set_pro/data/camera_selection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('en un primer arranque no hay cámara guardada', () async {
    SharedPreferences.setMockInitialValues({});
    final boot = await AppSettings.load();
    expect(boot.camera, isNull);
    expect(boot.language, 'es');
  });

  test('guarda una cámara digital con su modo y recupera el CoC del catálogo', () async {
    SharedPreferences.setMockInitialValues({});
    const selection = CameraSelection(
      kind: 'digital',
      manufacturer: 'ARRI',
      camera: 'ALEXA 35',
      mode: '4.6K 3:2 Open Gate',
    );
    await AppSettings.saveCamera(selection);

    final boot = await AppSettings.load();
    expect(boot.camera, isNotNull);
    expect(boot.camera!.label, 'ALEXA 35 · 4.6K 3:2 Open Gate');
    expect(boot.camera!.isFilm, isFalse);
    expect(boot.camera!.cocMm, closeTo(0.0226, 0.0005));
    expect(boot.camera!.baseIso, 800);
  });

  test('guarda un formato fílmico y recupera su CoC', () async {
    SharedPreferences.setMockInitialValues({});
    const selection = CameraSelection(kind: 'film', filmFormat: '35mm 4-perf full');
    await AppSettings.saveCamera(selection);

    final boot = await AppSettings.load();
    expect(boot.camera!.isFilm, isTrue);
    expect(boot.camera!.cocMm, closeTo(0.0254, 0.0001));
    expect(boot.camera!.widthMm, closeTo(24.92, 0.01));
  });

  test('ignora un modo que no existe en el catálogo', () async {
    SharedPreferences.setMockInitialValues({
      'camera.kind': 'digital',
      'camera.manufacturer': 'ARRI',
      'camera.camera': 'ALEXA 35',
      'camera.mode': 'Modo Inventado',
    });
    final boot = await AppSettings.load();
    expect(boot.camera, isNull);
  });

  test('guarda el idioma elegido', () async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.saveLanguage('pt');
    final boot = await AppSettings.load();
    expect(boot.language, 'pt');
  });
}
