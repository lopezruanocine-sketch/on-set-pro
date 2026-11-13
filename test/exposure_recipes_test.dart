import 'package:flutter_test/flutter_test.dart';

import 'package:on_set_pro/core/cine_data.dart';
import 'package:on_set_pro/domain/exposure/exposure_recipes.dart';

List<ExposureRecipe> suggest(
  double stops, {
  List<(String, double)> filters = const [],
  double aperture = 4,
}) =>
    ExposureRecipes.suggest(
      stops: stops,
      aperture: aperture,
      iso: 800,
      shutterAngle: 180,
      apertureScale: CineData.apertures,
      isoScale: CineData.isos,
      filters: filters,
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
    expect(suggest(-2).last.filterName, contains('ND 0.6'));
  });

  test('lo que propone siempre existe en la escala real', () {
    for (final stops in [-3.0, -1.5, -0.5, 0.5, 1.5, 3.0]) {
      final recipes = suggest(stops);
      expect(recipes, isNotEmpty);
      for (final recipe in recipes) {
        switch (recipe.kind) {
          case RecipeKind.aperture:
            expect(CineData.apertures, contains(recipe.value));
          case RecipeKind.iso:
            expect(CineData.isos, contains(recipe.value));
          case RecipeKind.shutter:
            expect(recipe.value, lessThanOrEqualTo(360));
          default:
            break;
        }
      }
    }
  });

  test('con seis pasos de filtros puestos propone quitar el ND 1.2', () {
    final r = suggest(
      6.4,
      filters: [('ND 1.2 — 4 stops', 4.0), ('Polarizador circular', 1.7)],
    );
    expect(r, isNotEmpty);
    expect(r.first.kind, RecipeKind.removeFilter);
    expect(r.first.filterName, contains('ND 1.2'));
    // No propone diafragmas ni ISO fuera de escala.
    expect(r.where((x) => x.kind == RecipeKind.aperture), isEmpty);
    expect(r.where((x) => x.kind == RecipeKind.iso), isEmpty);
  });

  test('con tres pasos y sin filtros propone diafragma e ISO, pero no obturador', () {
    final r = suggest(3);
    expect(r.first.kind, RecipeKind.aperture);
    expect(r.first.value, closeTo(1.4, 0.01));
    expect(r.any((x) => x.kind == RecipeKind.shutter), isFalse);
  });

  test('seis pasos de más proponen el ND de seis pasos primero', () {
    final r = suggest(-6);
    expect(r.first.kind, RecipeKind.nd);
    expect(r.first.filterName, contains('ND 1.8'));
  });
}
