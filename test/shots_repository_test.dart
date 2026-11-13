import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:on_set_pro/data/camera_selection.dart';
import 'package:on_set_pro/data/catalogs/camera_filters.dart';
import 'package:on_set_pro/data/catalogs/light_gels.dart';
import 'package:on_set_pro/data/shots_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const camera = CameraSelection(
    kind: 'digital',
    manufacturer: 'ARRI',
    camera: 'ALEXA 35',
    mode: '4.6K 3:2 Open Gate',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ShotsRepository.instance.load();
  });

  test('guarda un plano con filtros y gelatinas y lo recupera', () async {
    await ShotsRepository.instance.savePlan(
      camera: camera,
      iso: 800,
      fps: 24,
      shutterAngle: 180,
      filters: [CameraFilters.byName('ND 0.6 — 2 stops')],
      gels: [LightGels.byCode('Lee', '204')!],
      meterReading: 4,
      correctionStops: 2.67,
      note: 'Escena 12',
    );

    final repo = ShotsRepository.instance;
    expect(repo.plans.length, 1);
    final plan = repo.plans.first;
    expect(plan.cameraLabel, contains('ALEXA 35'));
    expect(plan.shutterLabel, '1/48 s');
    expect(plan.lossLabel, contains('ND 0.6'));
    expect(plan.lossLabel, contains('Lee 204'));
    expect(plan.note, 'Escena 12');

    // Se persiste: otra lectura desde cero lo encuentra.
    await repo.load();
    expect(ShotsRepository.instance.plans.length, 1);
  });

  test('el plano más nuevo aparece primero', () async {
    for (var i = 1; i <= 3; i++) {
      await ShotsRepository.instance.savePlan(
        camera: camera,
        iso: 400.0 * i,
        fps: 24,
        shutterAngle: 180,
        filters: const [],
        gels: const [],
        meterReading: 4,
        correctionStops: 0,
        note: 'plano $i',
      );
    }
    expect(ShotsRepository.instance.plans.first.note, 'plano 3');
  });

  test('borra un plano', () async {
    final plan = await ShotsRepository.instance.savePlan(
      camera: camera,
      iso: 800,
      fps: 24,
      shutterAngle: 180,
      filters: const [],
      gels: const [],
      meterReading: 4,
      correctionStops: 0,
    );
    await ShotsRepository.instance.deletePlan(plan.id);
    expect(ShotsRepository.instance.plans, isEmpty);
  });

  test('guarda y borra notas por departamento', () async {
    await ShotsRepository.instance.addNote(department: 'CÁMARA', text: 'falta el 85');
    await ShotsRepository.instance.addNote(department: 'ILUMINACIÓN', text: 'subir la fuente');
    expect(ShotsRepository.instance.notes.length, 2);
    expect(ShotsRepository.instance.notes.first.department, 'ILUMINACIÓN');

    await ShotsRepository.instance.deleteNote(ShotsRepository.instance.notes.first.id);
    expect(ShotsRepository.instance.notes.length, 1);
    expect(ShotsRepository.instance.notes.first.department, 'CÁMARA');
  });

  test('un almacenamiento corrupto no rompe la carga', () async {
    SharedPreferences.setMockInitialValues({'shots.plans': 'esto no es json'});
    await ShotsRepository.instance.load();
    expect(ShotsRepository.instance.plans, isEmpty);
  });
}
