import 'dart:math' as math;

import '../../data/catalogs/camera_filters.dart';

/// Tipo de solución que propone el recetario.
enum RecipeKind { aperture, iso, shutter, nd, removeFilter }

/// Una alternativa concreta para resolver la corrección de exposición.
class ExposureRecipe {
  final RecipeKind kind;

  /// Valor objetivo: diafragma, ISO, ángulo de obturador o pasos del filtro.
  final double value;

  /// Nombre del filtro, para las recetas de ND o de quitar un filtro.
  final String? filterName;

  const ExposureRecipe({
    required this.kind,
    required this.value,
    this.filterName,
  });
}

/// Recetario: dado un desajuste en pasos, propone cómo resolverlo.
///
/// Positivo = falta luz (abrir, subir ISO, alargar el obturador o quitar un
/// filtro). Negativo = sobra luz (cerrar, bajar ISO, poner ND o acortar).
///
/// Sólo propone cambios que existan de verdad: si el diafragma necesario se va
/// de la escala, no lo propone en lugar de inventar un f/0.4.
class ExposureRecipes {
  ExposureRecipes._();

  static List<ExposureRecipe> suggest({
    required double stops,
    required double aperture,
    required double iso,
    required double shutterAngle,
    required List<double> apertureScale,
    required List<double> isoScale,
    List<(String, double)> filters = const [],
    int limit = 3,
  }) {
    if (stops.abs() < 0.05) return const [];

    final recipes = <ExposureRecipe>[];
    final big = stops.abs() > 2.5;

    // Cuando el desajuste es grande, lo primero es cambiar la estructura
    // (sacar un filtro o poner uno), no forzar ISO o diafragma al extremo.
    if (big && stops > 0 && filters.isNotEmpty) {
      final removable = _bestFilter(filters, stops);
      if (removable != null) {
        recipes.add(ExposureRecipe(
          kind: RecipeKind.removeFilter,
          value: removable.$2,
          filterName: removable.$1,
        ));
      }
    }
    if (big && stops < 0) {
      final nd = CameraFilters.closestNd(stops);
      if (nd != null) {
        recipes.add(ExposureRecipe(
          kind: RecipeKind.nd,
          value: nd.stops,
          filterName: nd.name,
        ));
      }
    }

    // Diafragma: cada paso abre o cierra un factor raíz de 2.
    final targetAperture = aperture / math.pow(2, stops / 2);
    if (_inScale(apertureScale, targetAperture)) {
      recipes.add(ExposureRecipe(
        kind: RecipeKind.aperture,
        value: _nearest(apertureScale, targetAperture)!,
      ));
    }

    // Sensibilidad: cada paso duplica o reduce a la mitad el ISO.
    final targetIso = iso * math.pow(2, stops);
    if (_inScale(isoScale, targetIso)) {
      final value = _nearest(isoScale, targetIso)!;
      if ((value - iso).abs() > 0.5) {
        recipes.add(ExposureRecipe(kind: RecipeKind.iso, value: value));
      }
    }

    // Obturador: sólo si el ángulo resultante existe.
    if (stops > 0) {
      final angle = shutterAngle * math.pow(2, stops);
      if (angle <= 360) {
        recipes.add(ExposureRecipe(kind: RecipeKind.shutter, value: angle));
      }
    } else {
      final nd = CameraFilters.closestNd(stops);
      if (nd != null &&
          !recipes.any((r) => r.kind == RecipeKind.nd)) {
        recipes.add(ExposureRecipe(
          kind: RecipeKind.nd,
          value: nd.stops,
          filterName: nd.name,
        ));
      }
    }

    return recipes.take(limit).toList();
  }

  static (String, double)? _bestFilter(List<(String, double)> filters, double stops) {
    (String, double)? best;
    var diff = double.infinity;
    for (final f in filters) {
      // Sólo sirve si sacarlo no se pasa de largo.
      if (f.$2 > stops + 0.6) continue;
      final d = (f.$2 - stops).abs();
      if (d < diff) {
        diff = d;
        best = f;
      }
    }
    return best;
  }

  static bool _inScale(List<double> scale, double value) {
    if (scale.isEmpty) return false;
    return value >= scale.first - 1e-9 && value <= scale.last + 1e-9;
  }

  static double? _nearest(List<double> scale, double target) {
    if (scale.isEmpty || !target.isFinite || target <= 0) return null;
    var best = scale.first;
    var diff = double.infinity;
    for (final v in scale) {
      final d = (v - target).abs();
      if (d < diff) {
        diff = d;
        best = v;
      }
    }
    return best;
  }
}
