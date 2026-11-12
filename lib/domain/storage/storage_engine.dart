import 'dart:math' as math;

import '../core/units.dart';

/// Estimación de grabación para un soporte dado.
class RecordingEstimate {
  /// Datos totales que entran en el soporte.
  final double capacityGb;

  /// Cuánto se puede grabar.
  final Duration duration;

  /// Consumo del códec en GB por hora.
  final double gigabytesPerHour;

  /// Cuántos soportes hacen falta para cubrir [wantedMinutes].
  final int cardsNeeded;

  const RecordingEstimate({
    required this.capacityGb,
    required this.duration,
    required this.gigabytesPerHour,
    required this.cardsNeeded,
  });
}

/// Estimación de copia (DIT).
class CopyEstimate {
  final double gigabytes;

  /// Velocidad efectiva del cuello de botella, en MB/s.
  final double effectiveMegabytesPerSecond;

  final Duration duration;

  const CopyEstimate({
    required this.gigabytes,
    required this.effectiveMegabytesPerSecond,
    required this.duration,
  });
}

/// Motor de almacenamiento: cuánto entra en un soporte y cuánto tarda la copia.
///
/// Los GB son decimales (1000 MB), que es como los publican los fabricantes.
class StorageEngine {
  StorageEngine._();

  /// GB por hora de un códec que consume [mbps] megabits por segundo.
  static double gigabytesPerHour(double mbps) => mbps * 3600 / 8 / 1000;

  /// Datos generados por [minutes] de grabación.
  static double gigabytesForMinutes({required double mbps, required double minutes}) =>
      gigabytesPerHour(mbps) * minutes / 60;

  /// Duración de grabación que entra en un soporte.
  ///
  /// [overhead] descuenta el espacio que el sistema de archivos no entrega
  /// (por ejemplo 0.05 para un 5 %).
  static RecordingEstimate recording({
    required double mbps,
    required double capacityGb,
    double overhead = 0,
    double? wantedMinutes,
  }) {
    final usable = capacityGb * (1 - overhead);
    final perHour = gigabytesPerHour(mbps);
    final hours = usable / DMath.positive(perHour);
    final duration = Duration(microseconds: (hours * 3600 * 1e6).round());

    var cards = 1;
    if (wantedMinutes != null) {
      final needed = gigabytesForMinutes(mbps: mbps, minutes: wantedMinutes);
      cards = math.max(1, (needed / DMath.positive(usable)).ceil());
    }

    return RecordingEstimate(
      capacityGb: capacityGb,
      duration: duration,
      gigabytesPerHour: perHour,
      cardsNeeded: cards,
    );
  }

  /// Tiempo de copia de un soporte a disco.
  ///
  /// El disco nunca entrega su velocidad nominal: se aplica [overhead]
  /// (0.25 = 25 % menos) sobre el menor entre lectura y escritura, que es el
  /// cuello de botella real. [verificationFactor] suma el tiempo de verificación
  /// (1.0 = sin verificación, 2.0 = copiar y verificar).
  static CopyEstimate copyTime({
    required double gigabytes,
    required double readMbps,
    required double writeMbps,
    double overhead = 0.25,
    double verificationFactor = 1.0,
  }) {
    final bottleneck = math.min(readMbps, writeMbps);
    final effective = DMath.positive(bottleneck) * (1 - overhead);
    final megabytes = gigabytes * 1000;
    final seconds = (megabytes / DMath.positive(effective)) * verificationFactor;

    return CopyEstimate(
      gigabytes: gigabytes,
      effectiveMegabytesPerSecond: effective,
      duration: Duration(microseconds: (seconds * 1e6).round()),
    );
  }

  /// Formatea una duración como "1h 05m" o "4m 20s" para la interfaz.
  static String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h}h ${m.toString().padLeft(2, '0')}m';
    }
    if (m > 0) return '${m}m ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }
}
