class OpticalEngine {
  /// Calcula la Distancia Hiperfocal estrictamente en milímetros.
  /// Fórmula física: H = (f^2 / (N * CoC)) + f
  static double calculateHyperfocal({
    required double focalLengthMm,
    required double aperture,
    required double cocMm,
  }) {
    if (aperture <= 0 || cocMm <= 0) return double.infinity;
    
    // Matemática pura del Módulo 1
    double hyperfocal = (focalLengthMm * focalLengthMm) / (aperture * cocMm) + focalLengthMm;
    return hyperfocal;
  }

  /// Calcula el Límite Cercano de foco (Near Limit) en milímetros.
  static double calculateNearLimit({
    required double hyperfocalMm,
    required double subjectDistanceMm,
    required double focalLengthMm,
  }) {
    // Fórmula: (H * s) / (H + (s - f))
    double near = (hyperfocalMm * subjectDistanceMm) / 
                  (hyperfocalMm + (subjectDistanceMm - focalLengthMm));
    return near;
  }

  /// Calcula el Límite Lejano de foco (Far Limit) en milímetros.
  static double calculateFarLimit({
    required double hyperfocalMm,
    required double subjectDistanceMm,
    required double focalLengthMm,
  }) {
    double denominator = hyperfocalMm - (subjectDistanceMm - focalLengthMm);
    
    // FÍSICA PURA: Si el denominador es 0 o negativo, el límite es el Infinito.
    if (denominator <= 0) {
      return double.infinity; 
    }
    
    // Fórmula: (H * s) / (H - (s - f))
    double far = (hyperfocalMm * subjectDistanceMm) / denominator;
    return far;
  }
}