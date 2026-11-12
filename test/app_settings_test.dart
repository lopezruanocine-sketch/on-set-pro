import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:on_set_pro/data/app_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('en un primer arranque no hay cámara guardada', () async {
    SharedPreferences.setMockInitialValues({});
    final boot = await AppSettings.load();
    expect(boot.camera, isNull);
    expect(boot.language, 'es');
  });

  test('guarda la cámara y la recupera con su CoC', () async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.saveCamera(
      const SavedCamera(mode: 'film', format: '35mm 4-Perf'),
    );

    final boot = await AppSettings.load();
    expect(boot.camera, isNotNull);
    expect(boot.camera!.format, '35mm 4-Perf');
    expect(boot.camera!.isFilm, isTrue);
    expect(boot.camera!.coc, 0.025);
  });

  test('ignora una cámara guardada con formato inexistente', () async {
    SharedPreferences.setMockInitialValues({
      'setup.mode': 'digital',
      'setup.format': 'Formato Que No Existe',
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
