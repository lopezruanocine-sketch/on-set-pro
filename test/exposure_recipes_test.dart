import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/core/cine_data.dart';
import 'package:on_set_pro/domain/exposure/exposure_recipes.dart';

List<ExposureRecipe> suggest(double stops) => ExposureRecipes.suggest(
      stops: stops,
      aperture: 4,
      iso: 800,
      shutterAngle: 180,
      apertureScale: CineData.apertures,
      isoScale: CineData.isos,
    );

void main() {
  test('sin desajuste no propone nada', () {
    expect(suggest(0), isEmpty);
  });

  test('sobra un paso: cerrar a f/5.6, bajar a ISO 400 y ND 0.3', () {
    final r = suggest(-1);
    expect(r.length, 3);
    expect(r[0].kind, RecipeKind.aperture);
    expect(r[0].value, closeTo(5.6, 0.01));
    expect(r[1].kind, RecipeKind.iso);
    expect(r[1].value, 400);
    expect(r[2].kind, RecipeKind.nd);
    expect(r[2].filterName, contains('ND 0.3'));
  });

  test('falta un paso: abrir a f/2.8, subir a ISO 1600 y alargar el obturador', () {
    final r = suggest(1);
    expect(r[0].kind, RecipeKind.aperture);
    expect(r[0].value, closeTo(2.8, 0.01));
    expect(r[1].kind, RecipeKind.iso);
    expect(r[1].value, 1600);
    expect(r[2].kind, RecipeKind.shutter);
    expect(r[2].value, closeTo(360, 0.01));
  });

  test('dos pasos de más piden ND 0.6', () {
    final r = suggest(-2);
    expect(r.last.filterName, contains('ND 0.6'));
  });

  test('el diafragma propuesto siempre está en la escala real', () {
    for (final stops in [-3.0, -1.5, -0.5, 0.5, 1.5, 3.0]) {
      final r = suggest(stops);
      expect(CineData.apertures, contains(r.first.value));
      expect(CineData.isos, contains(r[1].value));
    }
  });
}
