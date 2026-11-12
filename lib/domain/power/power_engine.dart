import 'dart:math' as math;

import '../core/units.dart';

enum Phases { single, three }

/// Resultado de una caída de tensión.
class VoltageDropResult {
  final double volts;
  final double percent;
  final double voltage;

  const VoltageDropResult({
    required this.volts,
    required this.percent,
    required this.voltage,
  });

  bool get isAcceptable => percent <= 5;
}

/// Resultado de un generador corregido por altura y temperatura.
class GeneratorCapacity {
  final double nameplateKva;
  final double usableKva;
  final double usableKw;
  final double deratingFactor;

  const GeneratorCapacity({
    required this.nameplateKva,
    required this.usableKva,
    required this.usableKw,
    required this.deratingFactor,
  });
}

/// Motor eléctrico: ley de Ohm, caída de tensión, ampacidad y generadores.
///
/// Fuentes y fórmulas verificadas en `docs/research/electrico.md`.
class PowerEngine {
  PowerEngine._();

  // ------------------------------------------------------------ Ley de Ohm ---

  /// Corriente (A) para una potencia dada.
  static double amps({
    required double watts,
    required double voltage,
    Phases phases = Phases.single,
    double powerFactor = 1,
  }) {
    final v = DMath.positive(voltage);
    final pf = DMath.positive(powerFactor);
    final phaseFactor = phases == Phases.three ? math.sqrt(3) : 1.0;
    return watts / (v * pf * phaseFactor);
  }

  /// Potencia (W) para una corriente dada.
  static double watts({
    required double amps,
    required double voltage,
    Phases phases = Phases.single,
    double powerFactor = 1,
  }) {
    final phaseFactor = phases == Phases.three ? math.sqrt(3) : 1.0;
    return amps * DMath.positive(voltage) * DMath.positive(powerFactor) * phaseFactor;
  }

  /// Potencia aparente (VA) de una carga.
  static double voltAmps({required double watts, double powerFactor = 1}) =>
      watts / DMath.positive(powerFactor);

  // ------------------------------------------------------ Caída de tensión ---

  /// Caída de tensión en un tramo de cable.
  ///
  /// Monofásico: ΔV = 2·I·L·(R·cosφ + X·senφ)
  /// Trifásico:  ΔV = √3·I·L·(R·cosφ + X·senφ)
  ///
  /// [lengthM] en metros, [resistanceOhmPerKm] a 20 °C y
  /// [conductorTempFactor] corrige la resistencia a la temperatura de servicio
  /// (1.2 a 70 °C, 1.275 a 90 °C).
  static VoltageDropResult voltageDrop({
    required double amps,
    required double lengthM,
    required double resistanceOhmPerKm,
    required double voltage,
    Phases phases = Phases.single,
    double powerFactor = 1,
    double reactanceOhmPerKm = 0,
    double conductorTempFactor = 1.2,
  }) {
    final lengthKm = lengthM / 1000.0;
    final r = resistanceOhmPerKm * conductorTempFactor;
    final x = reactanceOhmPerKm;
    final sinPhi = math.sqrt(math.max(0, 1 - powerFactor * powerFactor));
    final impedanceDrop = r * powerFactor + x * sinPhi;
    final phaseFactor = phases == Phases.three ? math.sqrt(3) : 2.0;

    final drop = phaseFactor * amps * lengthKm * impedanceDrop;
    final v = DMath.positive(voltage);
    return VoltageDropResult(volts: drop, percent: drop / v * 100, voltage: v);
  }

  // ---------------------------------------------------------- Ampacidad -----

  /// Corriente admisible corregida por temperatura y agrupamiento.
  static double deratedAmpacity({
    required double ampacityA,
    double tempFactor = 1,
    double groupingFactor = 1,
    double safetyMargin = 1,
  }) =>
      ampacityA * tempFactor * groupingFactor * safetyMargin;

  /// Factor de corrección de ampacidad por temperatura ambiente.
  ///
  /// Puntos verificados para aislamiento EPR (IEC 60364-5-52, tabla B.52.14).
  /// Entre puntos se interpola linealmente; fuera de rango se usa el extremo.
  static double cableTempFactor(double ambientC) {
    const at30 = 1.0;
    const at40 = 0.91;
    const at50 = 0.82;
    if (ambientC <= 30) return at30;
    if (ambientC >= 50) return at50;
    if (ambientC < 40) {
      final t = (ambientC - 30) / 10;
      return at30 + (at40 - at30) * t;
    }
    final t = (ambientC - 40) / 10;
    return at40 + (at50 - at40) * t;
  }

  // --------------------------------------------------------- Generadores ----

  /// Potencia utilizable de un generador según altura y temperatura.
  ///
  /// Alternador: −3 % por cada 500 m por encima de 1000 m y −3 % por cada 5 °C
  /// por encima de 40 °C. Es la corrección conservadora que usa la industria;
  /// para el motor térmico hay que consultar la curva del fabricante.
  static GeneratorCapacity generator({
    required double nameplateKva,
    double altitudeM = 0,
    double ambientC = 40,
    double powerFactor = 0.8,
  }) {
    var factor = 1.0;
    if (altitudeM > 1000) {
      factor -= ((altitudeM - 1000) / 500) * 0.03;
    }
    if (ambientC > 40) {
      factor -= ((ambientC - 40) / 5) * 0.03;
    }
    factor = factor.clamp(0.5, 1.0);

    final usableKva = nameplateKva * factor;
    return GeneratorCapacity(
      nameplateKva: nameplateKva,
      usableKva: usableKva,
      usableKw: usableKva * powerFactor,
      deratingFactor: factor,
    );
  }

  /// Corriente que demanda un generador a plena carga.
  static double generatorAmps({
    required double kva,
    required double voltage,
    Phases phases = Phases.three,
  }) {
    final phaseFactor = phases == Phases.three ? math.sqrt(3) : 1.0;
    return kva * 1000 / (DMath.positive(voltage) * phaseFactor);
  }
}
