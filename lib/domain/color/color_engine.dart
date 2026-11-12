import '../core/units.dart';

/// Corrimiento de color entre dos fuentes, expresado en mireds.
///
/// Los Kelvin no se suman: los mireds sí. Por eso todo el cálculo de color de
/// la app pasa por mireds.
class ColorShift {
  final double sourceKelvin;
  final double targetKelvin;
  final double sourceMired;
  final double targetMired;

  const ColorShift({
    required this.sourceKelvin,
    required this.targetKelvin,
    required this.sourceMired,
    required this.targetMired,
  });

  /// Positivo = hay que calentar la imagen (CTO). Negativo = enfriar (CTB).
  double get shiftMired => targetMired - sourceMired;
}

/// Motor de color y gelatinas.
class ColorEngine {
  ColorEngine._();

  static ColorShift shiftTo({
    required double sourceKelvin,
    required double targetKelvin,
  }) {
    return ColorShift(
      sourceKelvin: sourceKelvin,
      targetKelvin: targetKelvin,
      sourceMired: Units.kelvinToMired(sourceKelvin),
      targetMired: Units.kelvinToMired(targetKelvin),
    );
  }

  /// Kelvin que resultan de aplicar un corrimiento en mireds a una fuente.
  static double kelvinAfter(double sourceKelvin, double miredDelta) {
    final mired = Units.kelvinToMired(sourceKelvin) + miredDelta;
    return mired <= 0 ? sourceKelvin : Units.miredToKelvin(mired);
  }

  /// Kelvin que produce una gelatina (su mired publicado) sobre una fuente.
  static double kelvinWithGel({
    required double sourceKelvin,
    required double gelMired,
  }) =>
      kelvinAfter(sourceKelvin, gelMired);

  /// Distancia de una gelatina al corrimiento que necesitamos.
  static double errorFor(double neededMired, double gelMired) =>
      (neededMired - gelMired).abs();
}
