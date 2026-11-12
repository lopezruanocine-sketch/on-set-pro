import 'dart:math' as math;

import '../core/units.dart';

/// Resultado del cálculo de profundidad de campo. Todas las distancias en mm.
class DepthOfField {
  final double hyperfocalMm;
  final double nearLimitMm;
  final double farLimitMm;
  final double totalDepthMm;
  final double subjectDistanceMm;

  const DepthOfField({
    required this.hyperfocalMm,
    required this.nearLimitMm,
    required this.farLimitMm,
    required this.totalDepthMm,
    required this.subjectDistanceMm,
  });

  bool get isFarInfinite => farLimitMm.isInfinite;

  double get depthInFrontMm => subjectDistanceMm - nearLimitMm;

  double get depthBehindMm =>
      isFarInfinite ? double.infinity : farLimitMm - subjectDistanceMm;
}

/// Resultado del campo de visión.
class FieldOfView {
  final double horizontalDegrees;
  final double verticalDegrees;
  final double diagonalDegrees;

  const FieldOfView({
    required this.horizontalDegrees,
    required this.verticalDegrees,
    required this.diagonalDegrees,
  });
}

/// Motor óptico: profundidad de campo, hiperfocal, campo de visión y
/// equivalencia de lentes entre sensores.
///
/// Todo se calcula en milímetros para no mezclar unidades.
/// Referencias: H = f²/(N·c) + f, Dn = s(H−f)/(H+s−2f), Df = s(H−f)/(H−s).
class OpticsEngine {
  OpticsEngine._();

  static double hyperfocalMm({
    required double focalMm,
    required double aperture,
    required double cocMm,
  }) {
    final f = DMath.positive(focalMm);
    final n = DMath.positive(aperture);
    final c = DMath.positive(cocMm);
    return (f * f) / (n * c) + f;
  }

  static DepthOfField depthOfField({
    required double focalMm,
    required double aperture,
    required double subjectDistanceMm,
    required double cocMm,
  }) {
    final f = DMath.positive(focalMm);
    final s = DMath.positive(subjectDistanceMm);
    final h = hyperfocalMm(focalMm: f, aperture: aperture, cocMm: cocMm);

    // Fórmulas exactas: Dn = s(H−f)/(H+s−2f) y Df = s(H−f)/(H−s).
    // Con la forma aproximada, enfocar a la hiperfocal no daba infinito.
    final nearDenominator = h + s - 2 * f;
    final farDenominator = h - s;

    final near = (s * (h - f)) / DMath.positive(nearDenominator);
    final far = farDenominator <= 0 ? double.infinity : (s * (h - f)) / farDenominator;

    return DepthOfField(
      hyperfocalMm: h,
      nearLimitMm: near,
      farLimitMm: far,
      totalDepthMm: far.isInfinite ? double.infinity : far - near,
      subjectDistanceMm: s,
    );
  }

  static FieldOfView fieldOfView({
    required double sensorWidthMm,
    required double sensorHeightMm,
    required double focalMm,
  }) {
    final f = DMath.positive(focalMm);
    final diagonal =
        math.sqrt(sensorWidthMm * sensorWidthMm + sensorHeightMm * sensorHeightMm);
    double angle(double dimension) =>
        (2 * math.atan(dimension / (2 * f))) * 180 / math.pi;

    return FieldOfView(
      horizontalDegrees: angle(sensorWidthMm),
      verticalDegrees: angle(sensorHeightMm),
      diagonalDegrees: angle(diagonal),
    );
  }

  static double frameWidthAt({
    required double sensorWidthMm,
    required double focalMm,
    required double distanceMm,
  }) =>
      sensorWidthMm * distanceMm / DMath.positive(focalMm);

  static double frameHeightAt({
    required double sensorHeightMm,
    required double focalMm,
    required double distanceMm,
  }) =>
      sensorHeightMm * distanceMm / DMath.positive(focalMm);

  static double diagonalMm(double widthMm, double heightMm) =>
      math.sqrt(widthMm * widthMm + heightMm * heightMm);

  static double cropFactor({
    required double sourceWidthMm,
    required double sourceHeightMm,
    required double targetWidthMm,
    required double targetHeightMm,
  }) {
    final source = diagonalMm(sourceWidthMm, sourceHeightMm);
    final target = diagonalMm(targetWidthMm, targetHeightMm);
    return DMath.positive(target) / DMath.positive(source);
  }

  /// Focal equivalente: qué lente hace falta en el sensor B para igualar el
  /// encuadre que da [focalMm] en el sensor A.
  static double equivalentFocal({
    required double focalMm,
    required double sourceWidthMm,
    required double sourceHeightMm,
    required double targetWidthMm,
    required double targetHeightMm,
  }) =>
      focalMm *
      cropFactor(
        sourceWidthMm: sourceWidthMm,
        sourceHeightMm: sourceHeightMm,
        targetWidthMm: targetWidthMm,
        targetHeightMm: targetHeightMm,
      );
}
