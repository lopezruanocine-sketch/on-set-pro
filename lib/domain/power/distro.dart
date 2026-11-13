import 'dart:math' as math;

/// Una carga conectada a la distro.
class Load {
  final String name;
  final double watts;

  /// Fase asignada (0, 1 o 2). `null` = todavía sin asignar.
  final int? phase;

  const Load({required this.name, required this.watts, this.phase});
}

/// Resultado de repartir las cargas entre las fases.
class DistroPlan {
  /// Potencia por fase, en watts.
  final List<double> phaseWatts;

  /// Corriente por fase, en amperios.
  final List<double> phaseAmps;

  /// Cargas ya asignadas a una fase.
  final List<Load> assigned;

  /// Cargas que no entran en la fase menos cargada.
  final List<Load> unassigned;

  /// Corriente de la fase más cargada.
  final double maxPhaseAmps;

  /// Hasta qué corriente admite cada fase.
  final double limitAmps;

  const DistroPlan({
    required this.phaseWatts,
    required this.phaseAmps,
    required this.assigned,
    required this.unassigned,
    required this.maxPhaseAmps,
    required this.limitAmps,
  });

  bool get isBalanced {
    final max = phaseWatts.reduce(math.max);
    final min = phaseWatts.reduce(math.min);
    return max < 1 || (max - min) / max < 0.15;
  }

  bool get isOverloaded => maxPhaseAmps > limitAmps;

  /// Fase con más carga (1, 2 o 3).
  int get heaviestPhase => phaseAmps.indexOf(maxPhaseAmps) + 1;
}

/// Reparto de cargas en una acometida trifásica.
///
/// La regla práctica del eléctrico: la carga que menos pesa va a la fase más
/// liviana, así el desbalance final queda lo más parejo posible. Un desbalance
/// grande hace que el neutro trabaje de más y dispara térmicas sin motivo.
class DistroEngine {
  DistroEngine._();

  /// Reparte las cargas en tres fases usando el criterio del más pesado primero.
  static DistroPlan distribute({
    required List<Load> loads,
    required double voltage,
    required double limitAmps,
    double powerFactor = 1,
  }) {
    final phaseWatts = <double>[0, 0, 0];
    final assigned = <Load>[];
    final unassigned = <Load>[];

    // Las que ya vienen asignadas ocupan su lugar.
    for (final load in loads) {
      final phase = load.phase;
      if (phase != null && phase >= 0 && phase < 3) {
        phaseWatts[phase] += load.watts;
        assigned.add(load);
      }
    }

    // Las nuevas van de la más grande a la más chica, a la fase más liviana.
    final pending = loads.where((l) => l.phase == null).toList()
      ..sort((a, b) => b.watts.compareTo(a.watts));

    for (final load in pending) {
      var target = 0;
      for (var i = 1; i < 3; i++) {
        if (phaseWatts[i] < phaseWatts[target]) target = i;
      }
      phaseWatts[target] += load.watts;
      assigned.add(Load(name: load.name, watts: load.watts, phase: target));
    }

    // Corriente: una carga monofásica en una fase de una distro trifásica
    // se calcula con la tensión de fase, no con la de línea.
    final phaseVoltage = voltage / math.sqrt(3);
    final amps = phaseWatts
        .map((w) => w / (phaseVoltage * powerFactor))
        .toList();

    return DistroPlan(
      phaseWatts: phaseWatts,
      phaseAmps: amps,
      assigned: assigned,
      unassigned: unassigned,
      maxPhaseAmps: amps.reduce(math.max),
      limitAmps: limitAmps,
    );
  }

  /// Desbalance: diferencia entre la fase más cargada y la más liviana,
  /// en porcentaje de la más cargada.
  static double imbalancePercent(List<double> phaseWatts) {
    final max = phaseWatts.reduce(math.max);
    if (max <= 0) return 0;
    final min = phaseWatts.reduce(math.min);
    return (max - min) / max * 100;
  }
}
