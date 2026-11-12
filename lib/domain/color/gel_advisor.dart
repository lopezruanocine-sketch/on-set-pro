import '../../data/catalogs/light_gels.dart';
import 'color_engine.dart';

/// Una gelatina candidata para corregir una fuente.
class GelMatch {
  final LightGel gel;

  /// Diferencia entre el corrimiento que hace falta y el que da la gelatina.
  final double errorMired;

  /// Temperatura que queda en cámara si se aplica esta gelatina.
  final double resultingKelvin;

  const GelMatch({
    required this.gel,
    required this.errorMired,
    required this.resultingKelvin,
  });

  bool get isExact => errorMired <= 5;
  bool get isClose => errorMired <= 25;
}

/// Elige la gelatina de corrección de color más adecuada.
class GelAdvisor {
  GelAdvisor._();

  /// Devuelve las mejores opciones ordenadas por error de mired.
  ///
  /// [families] limita la búsqueda (por ejemplo, sólo CTO o sólo CTB).
  static List<GelMatch> recommend({
    required double sourceKelvin,
    required double targetKelvin,
    List<LightGel> catalog = LightGels.all,
    Set<GelFamily>? families,
    int limit = 3,
  }) {
    final shift = ColorEngine.shiftTo(
      sourceKelvin: sourceKelvin,
      targetKelvin: targetKelvin,
    ).shiftMired;

    // Si la fuente ya está en el objetivo, no hace falta gel.
    if (shift.abs() < 3) return const [];

    final candidates = catalog.where((g) {
      if (g.mired == null) return false;
      if (families != null && !families.contains(g.family)) return false;
      // No proponer enfriar cuando hay que calentar, ni al revés.
      if (shift > 0 && g.mired! < 0) return false;
      if (shift < 0 && g.mired! > 0) return false;
      return true;
    }).map((g) {
      return GelMatch(
        gel: g,
        errorMired: (shift - g.mired!).abs(),
        resultingKelvin: ColorEngine.kelvinWithGel(
          sourceKelvin: sourceKelvin,
          gelMired: g.mired!,
        ),
      );
    }).toList();

    candidates.sort((a, b) => a.errorMired.compareTo(b.errorMired));
    return candidates.take(limit).toList();
  }
}
