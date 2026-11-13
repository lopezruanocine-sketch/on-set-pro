import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:on_set_pro/data/viewfinder_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sin memoria previa no hay sensor y usa el de la cámara activa', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await ViewfinderSettings.load();
    expect(s.cameraId, isNull);
    // Sin sensor guardado, el visor toma el de la cámara elegida al entrar.
    expect(s.sensorWidthMm, isNull);
    expect(s.sensorHeightMm, isNull);
    expect(s.focalMm, 25);
    expect(s.phoneFov, 70);
    expect(s.squeeze, isFalse);
  });

  test('guarda la cámara y el encuadre, y los recupera', () async {
    SharedPreferences.setMockInitialValues({});
    const saved = ViewfinderSettings(
      cameraId: 'webcam-1',
      sensorWidthMm: 36,
      sensorHeightMm: 24,
      focalMm: 50,
      phoneFov: 65,
      squeeze: true,
    );
    await saved.save();

    final loaded = await ViewfinderSettings.load();
    expect(loaded.cameraId, 'webcam-1');
    expect(loaded.sensorWidthMm, 36);
    expect(loaded.sensorHeightMm, 24);
    expect(loaded.focalMm, 50);
    expect(loaded.phoneFov, 65);
    expect(loaded.squeeze, isTrue);
  });

  test('copyWith conserva lo que no cambia', () async {
    const base = ViewfinderSettings(cameraId: 'a', focalMm: 32, squeeze: true);
    final next = base.copyWith(cameraId: 'b');
    expect(next.cameraId, 'b');
    expect(next.focalMm, 32);
    expect(next.squeeze, isTrue);
  });
}
