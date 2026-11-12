/// Base de datos de formatos de cámara y su círculo de confusión (CoC, en mm).
/// Vive en la capa de datos: la usan la pantalla de inicio y los ajustes guardados.
class CameraFormats {
  CameraFormats._();

  static const Map<String, double> digital = {
    "Medio Formato (GFX)": 0.050,
    "Full Frame / VV": 0.030,
    "Super 35mm": 0.025,
    "APS-C (Sony/Fuji)": 0.020,
    "APS-C (Canon)": 0.019,
    "MFT (GH6/BMPCC)": 0.015,
    "1-inch Sensor": 0.011,
    "1/1.7-inch": 0.007,
    "1/2.3-inch": 0.006,
    "1/3-inch": 0.005,
  };

  static const Map<String, double> film = {
    "65mm 5-Perf": 0.050,
    "35mm 4-Perf": 0.025,
    "35mm 3-Perf": 0.025,
    "35mm 2-Perf": 0.025,
    "16mm Super": 0.013,
    "16mm Standard": 0.013,
    "9.5mm": 0.010,
    "Super 8mm": 0.006,
    "Standard 8mm": 0.005,
  };

  static bool isFilm(String mode) => mode == 'film';

  static Map<String, double> mapFor(String mode) => isFilm(mode) ? film : digital;

  static List<String> namesFor(String mode) => mapFor(mode).keys.toList();

  static double? cocFor(String mode, String format) => mapFor(mode)[format];

  static bool isValid(String mode, String format) => cocFor(mode, format) != null;
}
