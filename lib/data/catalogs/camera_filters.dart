enum FilterKind { nd, irnd, polarizer, color, combo }

/// Un filtro de cámara con su pérdida de luz y, si corrige color, su mired.
class CameraFilter {
  final String name;
  final FilterKind kind;

  /// Pérdida de luz en pasos (positivo = quita luz).
  final double stops;

  /// Densidad óptica, para los ND.
  final double? density;

  /// Corrimiento de color en mireds, para los correctores.
  final double? mired;

  const CameraFilter({
    required this.name,
    required this.kind,
    required this.stops,
    this.density,
    this.mired,
  });

  bool get isNd => kind == FilterKind.nd || kind == FilterKind.irnd;
  bool get correctsColor => mired != null;
}

/// Catálogo de filtros de cámara.
///
/// Fuente: `docs/research/filtros-geles.md` (Tiffen, Schneider, Lee, B+W).
/// La pérdida de los ND se deriva de la densidad; los correctores llevan su
/// mired publicado.
class CameraFilters {
  CameraFilters._();

  static const CameraFilter none = CameraFilter(
    name: 'Ninguno',
    kind: FilterKind.nd,
    stops: 0,
  );

  static const List<CameraFilter> all = [
    none,
    // --- ND ---
    CameraFilter(name: 'ND 0.3 — 1 stop', kind: FilterKind.nd, stops: 1.0, density: 0.3),
    CameraFilter(name: 'ND 0.45 — 1 1/2', kind: FilterKind.nd, stops: 1.5, density: 0.45),
    CameraFilter(name: 'ND 0.6 — 2 stops', kind: FilterKind.nd, stops: 2.0, density: 0.6),
    CameraFilter(name: 'ND 0.75 — 2 1/2', kind: FilterKind.nd, stops: 2.5, density: 0.75),
    CameraFilter(name: 'ND 0.9 — 3 stops', kind: FilterKind.nd, stops: 3.0, density: 0.9),
    CameraFilter(name: 'ND 1.2 — 4 stops', kind: FilterKind.nd, stops: 4.0, density: 1.2),
    CameraFilter(name: 'ND 1.5 — 5 stops', kind: FilterKind.nd, stops: 5.0, density: 1.5),
    CameraFilter(name: 'ND 1.8 — 6 stops', kind: FilterKind.nd, stops: 6.0, density: 1.8),
    CameraFilter(name: 'ND 2.1 — 7 stops', kind: FilterKind.nd, stops: 7.0, density: 2.1),
    CameraFilter(name: 'ND 2.4 — 8 stops', kind: FilterKind.nd, stops: 8.0, density: 2.4),
    CameraFilter(name: 'ND 2.7 — 9 stops', kind: FilterKind.nd, stops: 9.0, density: 2.7),
    CameraFilter(name: 'ND 3.0 — 10 stops', kind: FilterKind.nd, stops: 10.0, density: 3.0),
    // --- IRND ---
    CameraFilter(name: 'IRND 0.9 — 3 stops', kind: FilterKind.irnd, stops: 3.0, density: 0.9),
    CameraFilter(name: 'IRND 1.2 — 4 stops', kind: FilterKind.irnd, stops: 4.0, density: 1.2),
    // --- polarizadores ---
    CameraFilter(name: 'Polarizador lineal', kind: FilterKind.polarizer, stops: 2.0),
    CameraFilter(name: 'Polarizador circular', kind: FilterKind.polarizer, stops: 1.7),
    // --- correctores de color ---
    CameraFilter(name: '85 — diurno a tungsteno', kind: FilterKind.color, stops: 0.67, mired: 112),
    CameraFilter(name: '85B — diurno a 3200K', kind: FilterKind.color, stops: 0.67, mired: 131),
    CameraFilter(name: '85C — diurno a 3800K', kind: FilterKind.color, stops: 0.30, mired: 81),
    CameraFilter(name: '80A — tungsteno a diurno', kind: FilterKind.color, stops: 2.0, mired: -131),
    CameraFilter(name: '80B — 3400K a diurno', kind: FilterKind.color, stops: 1.67, mired: -112),
    CameraFilter(name: '80C — 3800K a diurno', kind: FilterKind.color, stops: 1.0, mired: -81),
    CameraFilter(name: '81A — calentamiento suave', kind: FilterKind.color, stops: 0.33, mired: 18),
    CameraFilter(name: '81B — calentamiento suave', kind: FilterKind.color, stops: 0.33, mired: 27),
    CameraFilter(name: '81EF — calentamiento suave', kind: FilterKind.color, stops: 0.67, mired: 52),
    CameraFilter(name: 'FLD — fluorescente', kind: FilterKind.color, stops: 1.0),
    // --- combinados ---
    CameraFilter(name: '85 + ND 1.2', kind: FilterKind.combo, stops: 4.67, mired: 112),
  ];

  static CameraFilter byName(String name) =>
      all.firstWhere((f) => f.name == name, orElse: () => none);

  /// El ND más cercano a una cantidad de pasos (para "poné ND 0.6").
  static CameraFilter? closestNd(double stops) {
    final n = stops.abs();
    CameraFilter? best;
    var bestDiff = double.infinity;
    for (final f in all) {
      if (!f.isNd || f.stops == 0) continue;
      final diff = (f.stops - n).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        best = f;
      }
    }
    return best;
  }
}
