import 'dart:math' as math;

/// Cómo se muestra el encuadre de la cámara de cine sobre la imagen de la
/// cámara del teléfono.
///
/// El problema: el teléfono ve un ángulo (FOV) que depende de su propia lente;
/// la cámara de cine ve otro según su sensor y la focal elegida. Para mostrar
/// el encuadre de cine usamos una ventana sobre la vista del teléfono.
class ViewfinderFrame {
  /// Fracción del ancho del teléfono que ocupa el encuadre de cine (0–1).
  final double widthFraction;

  /// Relación de aspecto del encuadre, ancho / alto.
  final double aspectRatio;

  /// Radio del círculo de imagen de la óptica, en milímetros.
  final double imageCircleMm;

  /// Si el círculo de imagen cubre el sensor (la óptica cubre el formato).
  final bool coversSensor;

  /// Aviso de recorte: cuántos pasos de crop respecto de una óptica que cubre.
  final double cropFactor;

  const ViewfinderFrame({
    required this.widthFraction,
    required this.aspectRatio,
    required this.imageCircleMm,
    required this.coversSensor,
    required this.cropFactor,
  });
}

/// Motor del visor: convierte focales y sensores en una ventana sobre la vista.
class ViewfinderMath {
  ViewfinderMath._();

  /// Súper 16: 12.52 × 7.41 mm. Se usa como referencia de "lente de cine".
  static const double s16WidthMm = 12.52;
  static const double s16HeightMm = 7.41;

  /// Diámetro del círculo de imagen de una óptica con la cobertura de S16.
  static const double referenceImageCircleMm = 14.55;

  /// Encuadre de cine sobre la vista del teléfono.
  ///
  /// [phoneHorizontalFovDegrees] es el campo de visión horizontal de la cámara
  /// del teléfono (depende del modelo y de si es frontal o trasera).
  /// [sensorWidthMm]/[sensorHeightMm] son del sensor de cine elegido y
  /// [focalMm] la focal de la óptica.
  ///
  /// [squeeze] es el factor anamórfico (1 = esférico, 2 = anamórfico 2×).
  static ViewfinderFrame frame({
    required double phoneHorizontalFovDegrees,
    required double sensorWidthMm,
    required double sensorHeightMm,
    required double focalMm,
    double squeeze = 1,
    double imageCircleMm = referenceImageCircleMm,
  }) {
    final phoneHalf = _rad(phoneHorizontalFovDegrees.clamp(5, 170)) / 2;
    final cineHalf = math.atan(sensorWidthMm / (2 * focalMm));

    // El encuadre de cine es más angosto que el del teléfono: ocupa una
    // fracción del ancho proporcional a la tangente de los semiángulos.
    final fraction = (math.tan(cineHalf) / math.tan(phoneHalf)).clamp(0.02, 1.0);

    // El anamórfico desplega el cuadro: el alto aparente se divide por squeeze.
    final aspect = (sensorWidthMm / sensorHeightMm) / (squeeze == 0 ? 1 : squeeze);

    final sensorDiagonal = math.sqrt(
      sensorWidthMm * sensorWidthMm + sensorHeightMm * sensorHeightMm,
    );

    return ViewfinderFrame(
      widthFraction: fraction,
      aspectRatio: aspect,
      imageCircleMm: imageCircleMm,
      coversSensor: imageCircleMm >= sensorDiagonal,
      cropFactor: imageCircleMm / sensorDiagonal,
    );
  }

  /// Campo de visión horizontal que necesita una lente de referencia para
  /// cubrir un sensor: sirve para marcar el aviso de viñeteo.
  static double requiredFovDegrees(double sensorWidthMm, double focalMm) =>
      _deg(2 * math.atan(sensorWidthMm / (2 * focalMm)));

  static double _rad(double deg) => deg * math.pi / 180;
  static double _deg(double rad) => rad * 180 / math.pi;
}
