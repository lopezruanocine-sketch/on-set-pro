/// Una gelatina de iluminación con sus datos publicados.
class LightGel {
  final String brand;
  final String code;
  final String name;

  /// Corrimiento de color en mireds. `null` cuando la gelatina no corrige
  /// temperatura (difusión, verde/magenta).
  final double? mired;

  /// Pérdida de luz en pasos (positivo = quita luz).
  final double stops;

  /// Familia para agrupar en la interfaz.
  final GelFamily family;

  const LightGel({
    required this.brand,
    required this.code,
    required this.name,
    required this.mired,
    required this.stops,
    required this.family,
  });

  String get label => '$brand $code $name';
}

enum GelFamily { cto, ctb, green, magenta, diffusion, color }

/// Catálogo de gelatinas. Fuente: catálogos técnicos de Lee Filters y Rosco
/// (ver `docs/research/filtros-geles.md`). Los valores son de fábrica; donde el
/// mired es calculado, la ficha lo aclara.
class LightGels {
  LightGels._();

  static const List<LightGel> all = [
    // --- Lee: CTO ---
    LightGel(brand: 'Lee', code: '204', name: 'Full CTO', mired: 159, stops: 0.67, family: GelFamily.cto),
    LightGel(brand: 'Lee', code: '205', name: 'Half CTO', mired: 109, stops: 0.42, family: GelFamily.cto),
    LightGel(brand: 'Lee', code: '206', name: 'Quarter CTO', mired: 64, stops: 0.28, family: GelFamily.cto),
    LightGel(brand: 'Lee', code: '223', name: 'Eighth CTO', mired: 26, stops: 0.23, family: GelFamily.cto),
    // --- Lee: CTB ---
    LightGel(brand: 'Lee', code: '201', name: 'Full CTB', mired: -137, stops: 1.51, family: GelFamily.ctb),
    LightGel(brand: 'Lee', code: '202', name: 'Half CTB', mired: -78, stops: 0.91, family: GelFamily.ctb),
    LightGel(brand: 'Lee', code: '203', name: 'Quarter CTB', mired: -35, stops: 0.50, family: GelFamily.ctb),
    LightGel(brand: 'Lee', code: '218', name: 'Eighth CTB', mired: -18, stops: 0.32, family: GelFamily.ctb),
    // --- Lee: verde / magenta ---
    LightGel(brand: 'Lee', code: '244', name: 'Plus Green', mired: null, stops: 0.43, family: GelFamily.green),
    LightGel(brand: 'Lee', code: '245', name: 'Half Plus Green', mired: null, stops: 0.29, family: GelFamily.green),
    LightGel(brand: 'Lee', code: '246', name: 'Quarter Plus Green', mired: null, stops: 0.23, family: GelFamily.green),
    LightGel(brand: 'Lee', code: '247', name: 'Minus Green', mired: null, stops: 0.74, family: GelFamily.magenta),
    LightGel(brand: 'Lee', code: '248', name: 'Half Minus Green', mired: null, stops: 0.49, family: GelFamily.magenta),
    LightGel(brand: 'Lee', code: '249', name: 'Quarter Minus Green', mired: null, stops: 0.31, family: GelFamily.magenta),
    // --- Lee: difusión ---
    LightGel(brand: 'Lee', code: '216', name: 'White Diffusion', mired: null, stops: 1.50, family: GelFamily.diffusion),
    LightGel(brand: 'Lee', code: '250', name: 'Half White Diffusion', mired: null, stops: 0.75, family: GelFamily.diffusion),
    LightGel(brand: 'Lee', code: '251', name: 'Quarter White Diffusion', mired: null, stops: 0.33, family: GelFamily.diffusion),
    LightGel(brand: 'Lee', code: '252', name: 'Eighth White Diffusion', mired: null, stops: 0.23, family: GelFamily.diffusion),
    // --- Rosco ---
    LightGel(brand: 'Rosco', code: '3401', name: 'Sun 85', mired: 131, stops: 0.79, family: GelFamily.cto),
    LightGel(brand: 'Rosco', code: '3407', name: 'Full CTO', mired: 167, stops: 1.09, family: GelFamily.cto),
    LightGel(brand: 'Rosco', code: '3408', name: 'Half CTO', mired: 81, stops: 0.45, family: GelFamily.cto),
    LightGel(brand: 'Rosco', code: '3409', name: 'Quarter CTO', mired: 40, stops: 0.30, family: GelFamily.cto),
    LightGel(brand: 'Rosco', code: '3410', name: 'Eighth CTO', mired: 22, stops: 0.12, family: GelFamily.cto),
    LightGel(brand: 'Rosco', code: '3411', name: '3/4 CTO', mired: 131, stops: 0.79, family: GelFamily.cto),
    LightGel(brand: 'Rosco', code: '3202', name: 'Full CTB', mired: -131, stops: 1.47, family: GelFamily.ctb),
    LightGel(brand: 'Rosco', code: '3204', name: 'Half CTB', mired: -68, stops: 0.94, family: GelFamily.ctb),
    LightGel(brand: 'Rosco', code: '3208', name: 'Quarter CTB', mired: -27, stops: 0.43, family: GelFamily.ctb),
    LightGel(brand: 'Rosco', code: '3216', name: 'Eighth CTB', mired: -9, stops: 0.30, family: GelFamily.ctb),
    LightGel(brand: 'Rosco', code: '3304', name: 'Tough Plusgreen', mired: null, stops: 0.40, family: GelFamily.green),
    LightGel(brand: 'Rosco', code: '3315', name: 'Half Plusgreen', mired: null, stops: 0.15, family: GelFamily.green),
  ];

  /// Todas las gelatinas que corrigen temperatura (tienen mired).
  static List<LightGel> get withMired => all.where((g) => g.mired != null).toList();

  /// Busca una gelatina por marca y código (ej. `Lee 204`).
  static LightGel? byCode(String brand, String code) {
    for (final g in all) {
      if (g.brand == brand && g.code == code) return g;
    }
    return null;
  }

  /// Gelatinas de una familia (verde, magenta, difusión…).
  static List<LightGel> ofFamily(GelFamily family) =>
      all.where((g) => g.family == family).toList();
}
