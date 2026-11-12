/// Tipo de cable de set. La ampacidad depende del tipo, no sólo de la sección.
enum CableKind { h07rnf, soow }

/// Un cable de alimentación con sus datos eléctricos verificados.
///
/// `ampacityA` es la corriente admisible en servicio móvil (instalación
/// temporal) a 30 °C de ambiente. `resistanceOhmPerKm` es la resistencia del
/// conductor a 20 °C: para caída de tensión se corrige por temperatura.
class CableSpec {
  final CableKind kind;
  final double sectionMm2;
  final String awg;
  final double ampacityA;
  final double resistanceOhmPerKm;
  final double? fixedInAirA;
  final double? inConduitA;

  const CableSpec({
    required this.kind,
    required this.sectionMm2,
    required this.awg,
    required this.ampacityA,
    required this.resistanceOhmPerKm,
    this.fixedInAirA,
    this.inConduitA,
  });

  String get label => switch (kind) {
        CableKind.h07rnf => 'H07RN-F ${_mm(sectionMm2)} mm²',
        CableKind.soow => 'SOOW $awg AWG',
      };

  static String _mm(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}

/// Catálogo de cables de alimentación de set.
///
/// Fuentes: EN 50565-1 / IEC 60228 clase 5 (H07RN-F) y NEC 400.5(A)(1) (SOOW).
/// Ver `docs/research/electrico.md` para las tablas completas y las fuentes.
class CableCatalog {
  CableCatalog._();

  static const List<CableSpec> h07rnf = [
    CableSpec(kind: CableKind.h07rnf, sectionMm2: 1.0, awg: '17', ampacityA: 10, resistanceOhmPerKm: 19.5, fixedInAirA: 20, inConduitA: 20),
    CableSpec(kind: CableKind.h07rnf, sectionMm2: 1.5, awg: '16', ampacityA: 16, resistanceOhmPerKm: 13.3, fixedInAirA: 26, inConduitA: 25),
    CableSpec(kind: CableKind.h07rnf, sectionMm2: 2.5, awg: '14', ampacityA: 25, resistanceOhmPerKm: 7.98, fixedInAirA: 36, inConduitA: 33),
    CableSpec(kind: CableKind.h07rnf, sectionMm2: 4.0, awg: '12', ampacityA: 35, resistanceOhmPerKm: 4.95, fixedInAirA: 49, inConduitA: 43),
    CableSpec(kind: CableKind.h07rnf, sectionMm2: 6.0, awg: '10', ampacityA: 44, resistanceOhmPerKm: 3.30, fixedInAirA: 63, inConduitA: 53),
    CableSpec(kind: CableKind.h07rnf, sectionMm2: 10.0, awg: '8', ampacityA: 62, resistanceOhmPerKm: 1.91, fixedInAirA: 86, inConduitA: 71),
    CableSpec(kind: CableKind.h07rnf, sectionMm2: 16.0, awg: '6', ampacityA: 82, resistanceOhmPerKm: 1.21, fixedInAirA: 115, inConduitA: 91),
    CableSpec(kind: CableKind.h07rnf, sectionMm2: 25.0, awg: '4', ampacityA: 109, resistanceOhmPerKm: 0.780, fixedInAirA: 149, inConduitA: 116),
    CableSpec(kind: CableKind.h07rnf, sectionMm2: 35.0, awg: '2', ampacityA: 135, resistanceOhmPerKm: 0.554, fixedInAirA: 185, inConduitA: 139),
    CableSpec(kind: CableKind.h07rnf, sectionMm2: 50.0, awg: '1/0', ampacityA: 169, resistanceOhmPerKm: 0.386, fixedInAirA: 225, inConduitA: 164),
  ];

  static const List<CableSpec> soow = [
    CableSpec(kind: CableKind.soow, sectionMm2: 0.823, awg: '18', ampacityA: 7, resistanceOhmPerKm: 20.95),
    CableSpec(kind: CableKind.soow, sectionMm2: 1.31, awg: '16', ampacityA: 10, resistanceOhmPerKm: 13.16),
    CableSpec(kind: CableKind.soow, sectionMm2: 2.08, awg: '14', ampacityA: 15, resistanceOhmPerKm: 8.29),
    CableSpec(kind: CableKind.soow, sectionMm2: 3.31, awg: '12', ampacityA: 20, resistanceOhmPerKm: 5.21),
    CableSpec(kind: CableKind.soow, sectionMm2: 5.26, awg: '10', ampacityA: 25, resistanceOhmPerKm: 3.28),
    CableSpec(kind: CableKind.soow, sectionMm2: 8.37, awg: '8', ampacityA: 35, resistanceOhmPerKm: 2.06),
    CableSpec(kind: CableKind.soow, sectionMm2: 13.3, awg: '6', ampacityA: 45, resistanceOhmPerKm: 1.30),
    CableSpec(kind: CableKind.soow, sectionMm2: 21.2, awg: '4', ampacityA: 60, resistanceOhmPerKm: 0.813),
    CableSpec(kind: CableKind.soow, sectionMm2: 33.6, awg: '2', ampacityA: 80, resistanceOhmPerKm: 0.513),
  ];

  static List<CableSpec> of(CableKind kind) =>
      kind == CableKind.h07rnf ? h07rnf : soow;

  /// Busca el cable por sección exacta. Devuelve el más chico que alcance la
  /// sección pedida cuando no hay coincidencia exacta.
  static CableSpec? bySection(CableKind kind, double sectionMm2) {
    for (final c in of(kind)) {
      if ((c.sectionMm2 - sectionMm2).abs() < 0.01) return c;
    }
    for (final c in of(kind)) {
      if (c.sectionMm2 >= sectionMm2) return c;
    }
    return null;
  }

  /// Primer cable del tipo indicado cuya ampacidad corregida alcanza [amps].
  static CableSpec? forCurrent(
    CableKind kind,
    double amps, {
    double tempFactor = 1,
    double groupingFactor = 1,
  }) {
    for (final c in of(kind)) {
      if (c.ampacityA * tempFactor * groupingFactor >= amps) return c;
    }
    return null;
  }
}
