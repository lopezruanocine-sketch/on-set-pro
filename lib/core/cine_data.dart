// lib/core/cine_data.dart

/// Escalas de valores reales de cámara (tercios de paso).
/// Los catálogos de filtros y gelatinas viven en `lib/data/catalogs/`.
class CineData {
  // Escalas exactas en tercios de paso (1/3 stops)
  static const List<double> apertures = [1.0, 1.1, 1.2, 1.4, 1.6, 1.8, 2.0, 2.2, 2.5, 2.8, 3.2, 3.5, 4.0, 4.5, 5.0, 5.6, 6.3, 7.1, 8.0, 9.0, 10.0, 11.0, 13.0, 14.0, 16.0, 18.0, 20.0, 22.0, 32.0];
  static const List<double> isos = [50, 64, 80, 100, 125, 160, 200, 250, 320, 400, 500, 640, 800, 1000, 1250, 1600, 2000, 2500, 3200, 4000, 5000, 6400, 8000, 10000, 12800, 25600];
  static const List<double> fps = [12, 18, 23.976, 24, 25, 29.97, 30, 48, 50, 59.94, 60, 75, 90, 120, 240];
  static const List<double> shutterAngles = [11.25, 22.5, 45, 90, 144, 172.8, 180, 270, 360];
}
