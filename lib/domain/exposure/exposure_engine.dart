import 'dart:math' as math;

import '../core/units.dart';

/// Constantes de calibración fotométrica.
///
/// La relación entre iluminancia (lux), diafragma, ISO y tiempo de exposición es:
///
///     E = C · N² / (ISO · t)
///
/// con `E` en lux, `N` el diafragma, `t` en segundos y `C` la constante del
/// exposímetro. C = 250 es el valor clásico para luz incidente plana.
class Photometry {
  Photometry._();

  /// Luz incidente con difusor plano.
  static const double incidentFlat = 250.0;

  /// Luz incidente con domo esférico. Se usa cuando se quiere medir la luz
  /// que realmente llega al sujeto desde un hemisferio.
  static const double incidentDome = 340.0;
}

/// Configuración de captura: lo que define cuánta luz recibe el sensor.
class ExposureSettings {
  /// Diafragma (N). Ej. 2.8.
  final double aperture;

  /// Sensibilidad. Ej. 800.
  final double iso;

  /// Cuadros por segundo. Ej. 24.
  final double fps;

  /// Ángulo de obturación en grados. 180 equivale a 1/48 s a 24 fps.
  final double shutterAngle;

  /// Pérdida de luz de los filtros de la lente (ND, polarizador, correctores).
  final double filterStops;

  /// Pérdida de luz de las gelatinas de la luz.
  final double gelStops;

  const ExposureSettings({
    this.aperture = 2.8,
    this.iso = 800,
    this.fps = 24,
    this.shutterAngle = 180,
    this.filterStops = 0,
    this.gelStops = 0,
  });

  /// Configuración de referencia de la app: 24 fps, 180°, ISO 800, sin filtros.
  static const ExposureSettings reference = ExposureSettings();

  /// Tiempo de exposición de un cuadro, en segundos.
  double get shutterTime => Units.shutterSeconds(angleDegrees: shutterAngle, fps: fps);

  /// Velocidad de obturación expresada como denominador de 1/x.
  double get shutterDenominator => 1.0 / DMath.positive(shutterTime);

  /// Pérdida total de luz de filtros y gelatinas, en pasos.
  double get totalLossStops => filterStops + gelStops;

  ExposureSettings copyWith({
    double? aperture,
    double? iso,
    double? fps,
    double? shutterAngle,
    double? filterStops,
    double? gelStops,
  }) {
    return ExposureSettings(
      aperture: aperture ?? this.aperture,
      iso: iso ?? this.iso,
      fps: fps ?? this.fps,
      shutterAngle: shutterAngle ?? this.shutterAngle,
      filterStops: filterStops ?? this.filterStops,
      gelStops: gelStops ?? this.gelStops,
    );
  }
}

/// Lectura del exposímetro: el diafragma que da exposición correcta.
class MeterReading {
  final double aperture;
  final double iso;
  final double fps;
  final double shutterAngle;
  final double calibration;

  const MeterReading({
    required this.aperture,
    this.iso = 800,
    this.fps = 24,
    this.shutterAngle = 180,
    this.calibration = Photometry.incidentFlat,
  });

  double get shutterTime => Units.shutterSeconds(angleDegrees: shutterAngle, fps: fps);
}

/// Resultado del cálculo de compensación, con el desglose de cada variable.
class CompensationResult {
  /// Pasos totales a corregir. Positivo = cerrar diafragma o quitar luz;
  /// negativo = abrir diafragma o añadir luz.
  final double stops;

  /// Diafragma que expondría correctamente con la configuración de cámara.
  final double requiredAperture;

  /// Aportes individuales (en pasos de luz que suma cada variable).
  final double isoStops;
  final double shutterStops;
  final double filterStops;
  final double gelStops;

  const CompensationResult({
    required this.stops,
    required this.requiredAperture,
    required this.isoStops,
    required this.shutterStops,
    required this.filterStops,
    required this.gelStops,
  });

  bool get isBalanced => stops.abs() < 0.05;

  /// Etiqueta corta para la UI: "CIERRA 2.0", "ABRE 1.5" o "OK".
  String get label {
    if (isBalanced) return 'OK';
    final action = stops > 0 ? 'CIERRA' : 'ABRE';
    return '$action ${stops.abs().toStringAsFixed(1)}';
  }
}

/// Resultado del sistema de zonas.
class ZoneReading {
  /// Zona real (no redondeada) en la que cae la escena.
  final double rawZone;

  /// Zona entera más cercana, limitada a 0–10.
  final int zone;

  /// Pasos que hay que corregir para llevar la escena a la zona elegida.
  /// Positivo = cerrar / quitar luz; negativo = abrir / añadir luz.
  final double correctionStops;

  const ZoneReading({
    required this.rawZone,
    required this.zone,
    required this.correctionStops,
  });

  bool get isOnTarget => correctionStops.abs() < 0.05;
}

/// Resultado de la ley de la inversa del cuadrado.
class FallOffResult {
  /// Pasos que cambia la luz: negativo = pérdida, positivo = ganancia.
  final double stops;

  /// Relación de intensidad (1.0 = igual; 0.25 = un cuarto).
  final double intensityRatio;

  const FallOffResult({required this.stops, required this.intensityRatio});

  bool get isLoss => stops < 0;
}

/// Motor de exposición. Todas las fórmulas viven acá, fuera de la interfaz.
class ExposureEngine {
  ExposureEngine._();

  // ---------------------------------------------------------------- Zonas ---

  /// Zona de la escena según la lectura del exposímetro.
  ///
  /// Si el fotómetro pide f/16 y la cámara está en f/2.8, la escena está 5 pasos
  /// por encima del gris medio y cae en la zona 10.
  static ZoneReading zoneReading({
    required double meterAperture,
    required double cameraAperture,
    double targetZone = 5,
  }) {
    final stops = 2 * DMath.log2(
      DMath.positive(meterAperture) / DMath.positive(cameraAperture),
    );
    final rawZone = 5 + stops;
    final correction = targetZone - rawZone;
    return ZoneReading(
      rawZone: rawZone,
      zone: rawZone.round().clamp(0, 10),
      correctionStops: correction,
    );
  }

  // ------------------------------------------------------------- Fall-off ---

  /// Ley de la inversa del cuadrado: cuánto cambia la luz al mover la fuente.
  ///
  /// `stops = 2 · log2(d1 / d2)`: mover de 2 m a 4 m son −2 pasos.
  static FallOffResult fallOff({
    required double referenceDistance,
    required double newDistance,
  }) {
    final ratio = DMath.positive(referenceDistance) / DMath.positive(newDistance);
    return FallOffResult(stops: 2 * DMath.log2(ratio), intensityRatio: ratio * ratio);
  }

  // ----------------------------------------------------------- Fotometría ---

  /// Lux que iluminan al sujeto para un diafragma dado.
  static double luxForAperture({
    required double aperture,
    required double iso,
    required double shutterTime,
    double calibration = Photometry.incidentFlat,
  }) {
    final n2 = DMath.positive(aperture) * DMath.positive(aperture);
    return calibration * n2 / (DMath.positive(iso) * DMath.positive(shutterTime));
  }

  /// Diafragma que corresponde a una iluminancia (lux).
  static double apertureForLux({
    required double lux,
    required double iso,
    required double shutterTime,
    double calibration = Photometry.incidentFlat,
  }) {
    final value = DMath.positive(lux) *
        DMath.positive(iso) *
        DMath.positive(shutterTime) /
        DMath.positive(calibration);
    return math.sqrt(value);
  }

  // --------------------------------------------------------- Compensación ---

  /// Diafragma que expondría correctamente, considerando que el exposímetro
  /// pudo haberse usado con otros ajustes de ISO u obturador.
  static double requiredAperture({
    required MeterReading meter,
    required ExposureSettings camera,
  }) {
    // Partimos de la lectura del fotómetro y corregimos por las diferencias
    // de ISO, tiempo de exposición, pérdida de filtros/geles y calibración.
    final sensitivity = DMath.positive(camera.iso) / DMath.positive(meter.iso);
    final time = DMath.positive(camera.shutterTime) / DMath.positive(meter.shutterTime);
    final loss = DMath.pow2(-camera.totalLossStops);
    final calibration = DMath.positive(meter.calibration) / Photometry.incidentFlat;

    return meter.aperture * math.sqrt(sensitivity * time * loss * calibration);
  }

  /// Compensación completa: cuántos pasos hay que corregir y por qué.
  static CompensationResult compensate({
    required MeterReading meter,
    required ExposureSettings camera,
  }) {
    final required = requiredAperture(meter: meter, camera: camera);
    final stops = 2 * DMath.log2(required / DMath.positive(camera.aperture));

    final isoStops = DMath.log2(DMath.positive(camera.iso) / meter.iso);
    final shutterStops =
        DMath.log2(DMath.positive(camera.shutterTime) / DMath.positive(meter.shutterTime));

    return CompensationResult(
      stops: stops,
      requiredAperture: required,
      isoStops: isoStops,
      shutterStops: shutterStops,
      filterStops: -camera.filterStops,
      gelStops: -camera.gelStops,
    );
  }

  /// Pasos que aporta una combinación de ISO, obturador y filtros respecto de
  /// otra. Positivo = más luz. Útil para explicar de dónde sale una corrección.
  static double lightDelta({
    required ExposureSettings camera,
    ExposureSettings reference = ExposureSettings.reference,
  }) {
    final iso = DMath.log2(DMath.positive(camera.iso) / reference.iso);
    final time = DMath.log2(
      DMath.positive(camera.shutterTime) / DMath.positive(reference.shutterTime),
    );
    final aperture = 2 * DMath.log2(DMath.positive(reference.aperture) / camera.aperture);
    return iso + time + aperture - camera.totalLossStops + reference.totalLossStops;
  }
}

/// Relación entre densidad óptica de un filtro y pasos de exposición.
class NdFilter {
  NdFilter._();

  /// 1 paso equivale a densidad 0.30103 (log10 2).
  static const double _stopsPerDensity = 3.321928094887362;

  /// Pasos de un filtro ND a partir de su densidad (0.3 = 1 paso).
  static double stopsFromDensity(double density) => density * _stopsPerDensity;

  /// Densidad equivalente a una cantidad de pasos.
  static double densityFromStops(double stops) => stops / _stopsPerDensity;

  /// Factor de exposición (2 pasos = 4× más tiempo).
  static double factor(double stops) => DMath.pow2(stops);
}
