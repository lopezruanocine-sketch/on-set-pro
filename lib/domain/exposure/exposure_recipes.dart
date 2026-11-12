import 'dart:math' as math;

import '../../data/catalogs/camera_filters.dart';

/// Tipo de solución que propone el recetario.
enum RecipeKind { aperture, iso, shutter, nd }

/// Una alternativa concreta para resolver la corrección de exposición.
class ExposureRecipe {
  final RecipeKind kind;

  /// Valor objetivo: diafragma, ISO, ángulo de obturador o pasos del ND.
  final double value;

  /// Nombre del filtro, sólo para las recetas de ND.
  final String? filterName;

  const ExposureRecipe({
    required this.kind,
    required this.value,
    this.filterName,
  });
}

/// Recetario: dado un desajuste en pasos, propone tres formas de resolverlo.
///
/// Positivo = falta luz (hay que abrir, subir ISO o alargar el obturador).
/// Negativo = sobra luz (cerrar, bajar ISO, poner ND o acortar el obturador).
class ExposureRecipes {
  ExposureRecipes._();

  static List<ExposureRecipe> suggest({
    required double stops,
    required double aperture,
    required double iso,
    required double shutterAngle,
    required List<double> apertureScale,
    required List<double> isoScale,
    int limit = 3,
  }) {
    if (stops.abs() < 0.05) return const [];

    final recipes = <ExposureRecipe>[];

    // 1. Diafragma: cada paso abre o cierra un factor raíz de 2.
    final targetAperture = aperture / math.pow(2, stops / 2);
    final f = _nearest(apertureScale, targetAperture);
    if (f != null) {
      recipes.add(ExposureRecipe(kind: RecipeKind.aperture, value: f));
    }

    // 2. Sensibilidad: cada paso duplica o reduce a la mitad el ISO.
    final targetIso = iso * math.pow(2, stops);
    final i = _nearest(isoScale, targetIso);
    if (i != null && (i - iso).abs() > 0.5) {
      recipes.add(ExposureRecipe(kind: RecipeKind.iso, value: i));
    }

    // 3. ND si sobra luz; obturador si falta.
    if (stops < 0) {
      final nd = CameraFilters.closestNd(stops);
      if (nd != null) {
        recipes.add(ExposureRecipe(
          kind: RecipeKind.nd,
          value: nd.stops,
          filterName: nd.name,
        ));
      }
    } else {
      final angle = (shutterAngle * math.pow(2, stops)).clamp(11.25, 360.0);
      recipes.add(ExposureRecipe(kind: RecipeKind.shutter, value: angle));
    }

    return recipes.take(limit).toList();
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
