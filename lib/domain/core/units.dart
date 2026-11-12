import 'dart:math' as math;

/// Conversiones y utilidades numéricas compartidas por todos los motores.
///
/// Esta capa es Dart puro: no importa Flutter y se puede probar sin abrir la app.
class DMath {
  DMath._();

  /// Logaritmo en base 2. Es la unidad natural de la fotografía.
  static double log2(double x) => math.log(x) / math.ln2;

  static double pow2(double x) => math.pow(2, x).toDouble();

  /// Evita dividir por cero o tomar logaritmos de cero.
  static double positive(double value, {double fallback = 1e-6}) =>
      value.isFinite && value > 0 ? value : fallback;

  /// Redondeo a una cantidad de decimales (para mostrar, no para calcular).
  static double roundTo(double value, int decimals) {
    final factor = math.pow(10, decimals).toDouble();
    return (value * factor).roundToDouble() / factor;
  }
}

/// Conversión de unidades de uso diario en set.
class Units {
  Units._();

  static const double millimetresPerInch = 25.4;
  static const double feetPerMetre = 3.280839895013123;
  static const double metresPerFoot = 0.3048;

  static double metresToFeet(double m) => m * feetPerMetre;
  static double feetToMetres(double ft) => ft * metresPerFoot;
  static double mmToMetres(double mm) => mm / 1000.0;
  static double metresToMm(double m) => m * 1000.0;

  /// Mireds: la unidad en la que se suman los colores (1.000.000 / Kelvin).
  static double kelvinToMired(double kelvin) => 1000000.0 / DMath.positive(kelvin);
  static double miredToKelvin(double mired) => 1000000.0 / DMath.positive(mired);

  /// Segundos a partir de un ángulo de obturación.
  static double shutterSeconds({required double angleDegrees, required double fps}) =>
      angleDegrees / (360.0 * DMath.positive(fps));

  /// Ángulo a partir de una velocidad de obturación (1/x).
  static double shutterAngle({required double fps, required double shutterDenominator}) =>
      360.0 * DMath.positive(fps) / DMath.positive(shutterDenominator);
}
