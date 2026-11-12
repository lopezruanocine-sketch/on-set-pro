import '../core/units.dart';

/// Una ventana de obturación que no capta el parpadeo de una fuente.
class FlickerWindow {
  final int multiple;
  final double shutterTime;
  final double angle;
  final double shutterDenominator;
  final double distanceTo180;

  const FlickerWindow({
    required this.multiple,
    required this.shutterTime,
    required this.angle,
    required this.shutterDenominator,
    required this.distanceTo180,
  });
}

/// Motor antivibración (flicker free).
///
/// Una fuente alimentada por corriente alterna pulsa al doble de la frecuencia
/// de red (50 Hz → 100 pulsos por segundo). Para que un cuadro no capture una
/// variación de intensidad, la exposición tiene que ser un múltiplo exacto del
/// semiciclo: t = n / (2·Hz).
class FlickerEngine {
  FlickerEngine._();

  static List<FlickerWindow> safeWindows({
    required double gridHz,
    required double fps,
    double maxAngle = 360,
    int maxMultiple = 12,
  }) {
    final pulses = DMath.positive(gridHz) * 2;
    final windows = <FlickerWindow>[];

    for (var n = 1; n <= maxMultiple; n++) {
      final t = n / pulses;
      final angle = t * DMath.positive(fps) * 360;
      if (angle > maxAngle) continue;
      windows.add(
        FlickerWindow(
          multiple: n,
          shutterTime: t,
          angle: angle,
          shutterDenominator: 1 / t,
          distanceTo180: (angle - 180).abs(),
        ),
      );
    }

    windows.sort((a, b) => a.angle.compareTo(b.angle));
    return windows;
  }

  static FlickerWindow? recommended({
    required double gridHz,
    required double fps,
    double maxAngle = 360,
  }) {
    final windows = safeWindows(gridHz: gridHz, fps: fps, maxAngle: maxAngle);
    if (windows.isEmpty) return null;
    windows.sort((a, b) => a.distanceTo180.compareTo(b.distanceTo180));
    return windows.first;
  }

  static bool isSafe({
    required double gridHz,
    required double fps,
    required double angle,
    double toleranceDegrees = 0.5,
  }) {
    for (final w in safeWindows(gridHz: gridHz, fps: fps)) {
      if ((w.angle - angle).abs() <= toleranceDegrees) return true;
    }
    return false;
  }
}
