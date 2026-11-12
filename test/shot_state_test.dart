import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/data/camera_selection.dart';
import 'package:on_set_pro/data/catalogs/camera_filters.dart';
import 'package:on_set_pro/data/catalogs/light_gels.dart';
import 'package:on_set_pro/state/shot_state.dart';

void main() {
  setUp(() => ShotState.instance.reset());

  test('al elegir cámara toma su ISO base del catálogo', () {
    const venice = CameraSelection(
      kind: 'digital',
      manufacturer: 'SONY',
      camera: 'VENICE 2 6K',
      mode: '6K 3:2',
    );
    ShotState.instance.setCamera(venice);
    expect(ShotState.instance.iso, 500);

    const arri = CameraSelection(
      kind: 'digital',
      manufacturer: 'ARRI',
      camera: 'ALEXA 35',
      mode: '4.6K 3:2 Open Gate',
    );
    ShotState.instance.setCamera(arri);
    expect(ShotState.instance.iso, 800);
  });

  test('una cámara sin ISO publicado cae en 800', () {
    const a265 = CameraSelection(
      kind: 'digital',
      manufacturer: 'ARRI',
      camera: 'ALEXA 265',
      mode: '6.5K 2.12:1 Open Gate',
    );
    ShotState.instance.setCamera(a265);
    expect(ShotState.instance.iso, 800);
  });

  test('velocidad 1/48 a 24 fps son 180°', () {
    final s = ShotState.instance;
    s.setFps(24);
    s.setShutterDenominator(48);
    expect(s.shutterAngle, closeTo(180, 1e-9));
  });

  test('48 fps a 180° equivalen a 1/96 s', () {
    final s = ShotState.instance;
    s.setFps(48);
    s.setShutterAngle(180);
    expect(s.shutterDenominator, closeTo(96, 1e-6));
  });

  test('el resumen muestra ISO, obturador y ND', () {
    final s = ShotState.instance;
    s.setIso(800);
    s.setFps(24);
    s.setShutterAngle(180);
    s.setFilter(CameraFilters.byName('ND 0.6 — 2 stops'));
    expect(s.summary, contains('ISO 800'));
    expect(s.summary, contains('1/48'));
    expect(s.summary, contains('ND 0.6'));
  });

  test('el filtro y la gelatina aportan sus pasos', () {
    final s = ShotState.instance;
    s.setFilter(CameraFilters.byName('ND 1.2 — 4 stops'));
    s.setGel(LightGels.all.firstWhere((g) => g.code == '204'));
    expect(s.filterStops, 4.0);
    expect(s.gelStops, closeTo(0.67, 0.01));
  });
}
