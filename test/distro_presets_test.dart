import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:on_set_pro/data/distro_presets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DistroPresets.instance.load();
  });

  test('sin memoria previa no hay repartos', () async {
    expect(DistroPresets.instance.presets, isEmpty);
  });

  test('guarda un reparto con nombre y sus cargas', () async {
    await DistroPresets.instance.save(
      name: 'Entrevista 2 puntos',
      loads: const [
        PresetLoad(name: 'M18', watts: 1800),
        PresetLoad(name: 'Skypanel', watts: 900),
      ],
    );

    final preset = DistroPresets.instance.presets.first;
    expect(preset.name, 'Entrevista 2 puntos');
    expect(preset.loads.length, 2);
    expect(preset.totalWatts, 2700);
  });

  test('el reparto sobrevive a cerrar la app', () async {
    await DistroPresets.instance.save(
      name: 'Set de 4',
      loads: const [PresetLoad(name: 'M18', watts: 1800)],
    );
    await DistroPresets.instance.load();
    expect(DistroPresets.instance.presets.first.name, 'Set de 4');
  });

  test('el más nuevo aparece primero y se puede borrar', () async {
    await DistroPresets.instance.save(name: 'Uno', loads: const []);
    await DistroPresets.instance.save(name: 'Dos', loads: const []);
    expect(DistroPresets.instance.presets.first.name, 'Dos');

    await DistroPresets.instance.delete(DistroPresets.instance.presets.first.id);
    expect(DistroPresets.instance.presets.length, 1);
    expect(DistroPresets.instance.presets.first.name, 'Uno');
  });

  test('un reparto sin nombre usa un nombre por defecto', () async {
    await DistroPresets.instance.save(name: '   ', loads: const []);
    expect(DistroPresets.instance.presets.first.name, 'Reparto');
  });

  test('un almacenamiento corrupto no rompe la carga', () async {
    SharedPreferences.setMockInitialValues({'distro.presets': 'no es json'});
    await DistroPresets.instance.load();
    expect(DistroPresets.instance.presets, isEmpty);
  });
}
