/// Un modo de grabación de una cámara: el área de imagen que realmente se usa.
///
/// Ancho y alto están en milímetros, verificados contra fichas oficiales
/// (ver `docs/research/camaras-sensores.md`). `baseIso` es `null` cuando el
/// fabricante no publica un valor nativo.
class SensorMode {
  final String manufacturer;
  final String camera;
  final String mode;
  final int widthPx;
  final int heightPx;
  final double widthMm;
  final double heightMm;
  final double? baseIso;
  final String notes;

  const SensorMode({
    required this.manufacturer,
    required this.camera,
    required this.mode,
    required this.widthPx,
    required this.heightPx,
    required this.widthMm,
    required this.heightMm,
    this.baseIso,
    this.notes = '',
  });

  String get cameraLabel => '$manufacturer $camera';
  String get label => '$cameraLabel · $mode';

  double get diagonalMm {
    final d = (widthMm * widthMm + heightMm * heightMm);
    return d <= 0 ? 0 : _sqrt(d);
  }

  static double _sqrt(double v) {
    // Raíz cuadrada por método de Newton: evita importar dart:math sólo por esto.
    if (v <= 0) return 0;
    var x = v;
    for (var i = 0; i < 40; i++) {
      x = 0.5 * (x + v / x);
    }
    return x;
  }

  /// Círculo de confusión con la regla diagonal/1500 (la más usada en cine).
  double get coc1500Mm => diagonalMm / 1500;

  /// Círculo de confusión con la regla diagonal/1730 (criterio Zeiss, más exigente).
  double get coc1730Mm => diagonalMm / 1730;

  double get pixelPitchMicrons => widthPx == 0 ? 0 : widthMm * 1000 / widthPx;
}

/// Catálogo de cámaras y modos de grabación.
class SensorCatalog {
  SensorCatalog._();

  static const List<SensorMode> all = [
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA 35', mode: '4.6K 3:2 Open Gate', widthPx: 4608, heightPx: 3164, widthMm: 27.99, heightMm: 19.22, baseIso: 800, notes: 'fabrica; 1.46:1'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA 35', mode: '4.6K 16:9', widthPx: 4608, heightPx: 2592, widthMm: 27.99, heightMm: 15.75, baseIso: 800, notes: 'fabrica; 1.78:1'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA 35', mode: '4K 16:9', widthPx: 4096, heightPx: 2304, widthMm: 24.88, heightMm: 14, baseIso: 800, notes: 'fabrica; 1.78:1'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA 35', mode: '3.8K 2.39:1', widthPx: 3840, heightPx: 1608, widthMm: 23.33, heightMm: 9.77, baseIso: 800, notes: 'fabrica; 2.39:1'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA 35', mode: '3.3K 6:5 ana 2x', widthPx: 3328, heightPx: 2790, widthMm: 20.22, heightMm: 16.95, baseIso: 800, notes: 'fabrica; 2.39:1 desplegado'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA 35 Xtreme', mode: '4.6K 3:2 Open Gate', widthPx: 4608, heightPx: 3164, widthMm: 27.99, heightMm: 19.22, baseIso: 800, notes: 'fabrica; 17 stops'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA 35 Xtreme', mode: '4.6K 16:9', widthPx: 4608, heightPx: 2592, widthMm: 27.99, heightMm: 15.75, baseIso: 800, notes: 'fabrica; 1.78:1'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA Mini LF', mode: '4.5K LF 3:2 Open Gate', widthPx: 4448, heightPx: 3096, widthMm: 36.7, heightMm: 25.54, baseIso: 800, notes: 'fabrica; 1.44:1'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA Mini LF', mode: '4.5K LF 2.39:1', widthPx: 4448, heightPx: 1856, widthMm: 36.7, heightMm: 15.31, baseIso: 800, notes: 'fabrica; 2.39:1'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA Mini LF', mode: '4.3K LF 16:9', widthPx: 4320, heightPx: 2430, widthMm: 35.64, heightMm: 20.05, baseIso: 800, notes: 'fabrica; 1.78:1'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA Mini LF', mode: '2.8K S35 4:3 ana 2x', widthPx: 2880, heightPx: 2160, widthMm: 23.76, heightMm: 17.81, baseIso: 800, notes: 'fabrica; 2.39:1 desplegado'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA 65', mode: '6.5K Open Gate 5-perf', widthPx: 6560, heightPx: 3100, widthMm: 54.12, heightMm: 25.58, baseIso: 800, notes: 'fabrica; 2.12:1'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA 65', mode: '2.39:1 recorte', widthPx: 6560, heightPx: 2745, widthMm: 54.12, heightMm: 22.65, baseIso: 800, notes: 'calculado; 2.39:1'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA 265', mode: '6.5K 2.12:1 Open Gate', widthPx: 6560, heightPx: 3100, widthMm: 54.12, heightMm: 25.58, baseIso: null, notes: 'fabrica; 15 stops'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA 265', mode: '5.1K 1.65:1', widthPx: 5120, heightPx: 3100, widthMm: 42.24, heightMm: 25.58, baseIso: null, notes: 'fabrica; 1.65:1'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA 265', mode: '4.5K LF 3:2', widthPx: 4448, heightPx: 3096, widthMm: 36.7, heightMm: 25.54, baseIso: null, notes: 'fabrica; 1.44:1'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA Mini', mode: '3.4K Open Gate', widthPx: 3424, heightPx: 2202, widthMm: 28.25, heightMm: 18.17, baseIso: 800, notes: 'fabrica; 1.55:1'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA Mini', mode: '3.2K 16:9', widthPx: 3200, heightPx: 1800, widthMm: 26.4, heightMm: 14.85, baseIso: 800, notes: 'fabrica; 1.78:1'),
    SensorMode(manufacturer: 'ARRI', camera: 'ALEXA Mini', mode: '2.8K 4:3 ana 2x', widthPx: 2880, heightPx: 2160, widthMm: 23.76, heightMm: 17.82, baseIso: 800, notes: 'fabrica; 2.39:1 desplegado'),
    SensorMode(manufacturer: 'RED', camera: 'V-RAPTOR 8K VV', mode: '8K 17:9', widthPx: 8192, heightPx: 4320, widthMm: 40.96, heightMm: 21.6, baseIso: 800, notes: 'fabrica; 1.89:1'),
    SensorMode(manufacturer: 'RED', camera: 'V-RAPTOR 8K VV', mode: '8K 2.4:1', widthPx: 8192, heightPx: 3456, widthMm: 40.96, heightMm: 17.28, baseIso: 800, notes: 'calculado; 2.37:1'),
    SensorMode(manufacturer: 'RED', camera: 'V-RAPTOR 8K VV', mode: '6K 17:9', widthPx: 6144, heightPx: 3240, widthMm: 30.72, heightMm: 16.2, baseIso: 800, notes: 'calculado; 1.89:1'),
    SensorMode(manufacturer: 'RED', camera: 'V-RAPTOR 8K VV', mode: '4K 17:9', widthPx: 4096, heightPx: 2160, widthMm: 20.48, heightMm: 10.8, baseIso: 800, notes: 'calculado; 1.89:1'),
    SensorMode(manufacturer: 'RED', camera: 'V-RAPTOR XL 8K VV', mode: '8K 17:9', widthPx: 8192, heightPx: 4320, widthMm: 40.96, heightMm: 21.6, baseIso: 800, notes: 'fabrica; montura PL/EF'),
    SensorMode(manufacturer: 'RED', camera: 'V-RAPTOR XL 8K VV', mode: '8K 2.4:1', widthPx: 8192, heightPx: 3456, widthMm: 40.96, heightMm: 17.28, baseIso: 800, notes: 'calculado; 2.37:1'),
    SensorMode(manufacturer: 'RED', camera: 'KOMODO-X', mode: '6K 17:9', widthPx: 6144, heightPx: 3240, widthMm: 27.03, heightMm: 14.26, baseIso: 800, notes: 'fabrica; 1.89:1'),
    SensorMode(manufacturer: 'RED', camera: 'KOMODO-X', mode: '6K 2.4:1', widthPx: 6144, heightPx: 2592, widthMm: 27.03, heightMm: 11.4, baseIso: 800, notes: 'calculado; 2.37:1'),
    SensorMode(manufacturer: 'RED', camera: 'KOMODO-X', mode: '4K 17:9', widthPx: 4096, heightPx: 2160, widthMm: 18.02, heightMm: 9.5, baseIso: 800, notes: 'calculado; 1.89:1'),
    SensorMode(manufacturer: 'RED', camera: 'MONSTRO 8K VV', mode: '8K Full Format', widthPx: 8192, heightPx: 4320, widthMm: 40.96, heightMm: 21.6, baseIso: 800, notes: 'fabrica; 1.89:1'),
    SensorMode(manufacturer: 'RED', camera: 'MONSTRO 8K VV', mode: '8K 2.4:1', widthPx: 8192, heightPx: 3456, widthMm: 40.96, heightMm: 17.28, baseIso: 800, notes: 'calculado; 2.37:1'),
    SensorMode(manufacturer: 'RED', camera: 'MONSTRO 8K VV', mode: '6K Full Format', widthPx: 6144, heightPx: 3240, widthMm: 30.72, heightMm: 16.2, baseIso: 800, notes: 'calculado; 1.89:1'),
    SensorMode(manufacturer: 'SONY', camera: 'VENICE 2 8.6K', mode: '8.6K 3:2', widthPx: 8640, heightPx: 5760, widthMm: 35.9, heightMm: 24, baseIso: 800, notes: 'fabrica; dual 800/3200'),
    SensorMode(manufacturer: 'SONY', camera: 'VENICE 2 8.6K', mode: '8.6K 17:9', widthPx: 8640, heightPx: 4556, widthMm: 35.9, heightMm: 19, baseIso: 800, notes: 'fabrica; 1.89:1'),
    SensorMode(manufacturer: 'SONY', camera: 'VENICE 2 8.6K', mode: '8.2K 2.39:1', widthPx: 8192, heightPx: 3432, widthMm: 34.1, heightMm: 14.3, baseIso: 800, notes: 'fabrica; 2.39:1'),
    SensorMode(manufacturer: 'SONY', camera: 'VENICE 2 8.6K', mode: '7.6K 16:9', widthPx: 7680, heightPx: 4320, widthMm: 32, heightMm: 18, baseIso: 800, notes: 'fabrica; 1.78:1'),
    SensorMode(manufacturer: 'SONY', camera: 'VENICE 2 8.6K', mode: '5.8K 4:3', widthPx: 5792, heightPx: 4276, widthMm: 24.1, heightMm: 17.8, baseIso: 800, notes: 'fabrica; 1.35:1'),
    SensorMode(manufacturer: 'SONY', camera: 'VENICE 2 8.6K', mode: '5.8K 6:5', widthPx: 5792, heightPx: 4854, widthMm: 24.1, heightMm: 20.2, baseIso: 800, notes: 'fabrica; 1.19:1'),
    SensorMode(manufacturer: 'SONY', camera: 'VENICE 2 6K', mode: '6K 3:2', widthPx: 6048, heightPx: 4032, widthMm: 35.9, heightMm: 24, baseIso: 500, notes: 'fabrica; dual 500/2500'),
    SensorMode(manufacturer: 'SONY', camera: 'VENICE 2 6K', mode: '6K 17:9', widthPx: 6054, heightPx: 3192, widthMm: 36, heightMm: 19, baseIso: 500, notes: 'fabrica; 1.89:1'),
    SensorMode(manufacturer: 'SONY', camera: 'VENICE 2 6K', mode: '6K 2.39:1', widthPx: 6048, heightPx: 2534, widthMm: 35.9, heightMm: 15, baseIso: 500, notes: 'fabrica; 2.39:1'),
    SensorMode(manufacturer: 'SONY', camera: 'VENICE 2 6K', mode: '4K 6:5', widthPx: 4096, heightPx: 3432, widthMm: 24.3, heightMm: 20.4, baseIso: 500, notes: 'fabrica; 1.19:1'),
    SensorMode(manufacturer: 'SONY', camera: 'BURANO', mode: 'FF 8.6K 16:9', widthPx: 8632, heightPx: 4856, widthMm: 35.9, heightMm: 20.2, baseIso: 800, notes: 'fabrica; dual 800/3200'),
    SensorMode(manufacturer: 'SONY', camera: 'BURANO', mode: 'FF 8.6K 17:9', widthPx: 8632, heightPx: 4552, widthMm: 35.9, heightMm: 18.9, baseIso: 800, notes: 'fabrica; 1.89:1'),
    SensorMode(manufacturer: 'SONY', camera: 'BURANO', mode: 'FFc 6K 17:9', widthPx: 6052, heightPx: 3192, widthMm: 33.6, heightMm: 17.7, baseIso: 800, notes: 'fabrica; 1.89:1'),
    SensorMode(manufacturer: 'SONY', camera: 'BURANO', mode: 'S35 5.8K 16:9', widthPx: 5760, heightPx: 3240, widthMm: 24, heightMm: 13.5, baseIso: 800, notes: 'fabrica; 1.78:1'),
    SensorMode(manufacturer: 'SONY', camera: 'BURANO', mode: 'S35 4.3K 4:3', widthPx: 4256, heightPx: 3192, widthMm: 23.6, heightMm: 17.7, baseIso: 800, notes: 'fabrica; 1.33:1'),
    SensorMode(manufacturer: 'SONY', camera: 'FX9', mode: '6K FF', widthPx: 6048, heightPx: 3192, widthMm: 35.7, heightMm: 18.8, baseIso: 800, notes: 'mm fabrica; px calculado'),
    SensorMode(manufacturer: 'SONY', camera: 'FX9', mode: '4K DCI FF', widthPx: 4096, heightPx: 2160, widthMm: 35.7, heightMm: 18.8, baseIso: 800, notes: 'calculado; 1.89:1'),
    SensorMode(manufacturer: 'SONY', camera: 'FX9', mode: '5K S35', widthPx: 5120, heightPx: 2700, widthMm: 30.2, heightMm: 15.9, baseIso: 800, notes: 'calculado; 1.89:1'),
    SensorMode(manufacturer: 'SONY', camera: 'FX6', mode: '4K DCI', widthPx: 4096, heightPx: 2160, widthMm: 35.6, heightMm: 18.8, baseIso: 800, notes: 'calculado; 1.89:1'),
    SensorMode(manufacturer: 'SONY', camera: 'FX6', mode: 'UHD 4K', widthPx: 3840, heightPx: 2160, widthMm: 35.6, heightMm: 20, baseIso: 800, notes: 'calculado; 1.78:1'),
    SensorMode(manufacturer: 'SONY', camera: 'FX3', mode: '4K DCI', widthPx: 4096, heightPx: 2160, widthMm: 35.6, heightMm: 18.8, baseIso: 800, notes: 'calculado; 1.89:1'),
    SensorMode(manufacturer: 'SONY', camera: 'FX3', mode: 'UHD 4K', widthPx: 3840, heightPx: 2160, widthMm: 35.6, heightMm: 20, baseIso: 800, notes: 'calculado; 1.78:1'),
    SensorMode(manufacturer: 'CANON', camera: 'EOS C400', mode: '6K FF', widthPx: 6000, heightPx: 3164, widthMm: 36, heightMm: 19, baseIso: 800, notes: 'fabrica; 1.90:1'),
    SensorMode(manufacturer: 'CANON', camera: 'EOS C400', mode: 'S35 4.3K', widthPx: 4368, heightPx: 2304, widthMm: 26.2, heightMm: 13.8, baseIso: 800, notes: 'calculado; 1.90:1'),
    SensorMode(manufacturer: 'CANON', camera: 'EOS C400', mode: 'S16 2.2K', widthPx: 2184, heightPx: 1152, widthMm: 13.1, heightMm: 6.9, baseIso: 800, notes: 'calculado; 1.90:1'),
    SensorMode(manufacturer: 'CANON', camera: 'EOS C500 Mark II', mode: '5.9K FF', widthPx: 5952, heightPx: 3140, widthMm: 38.1, heightMm: 20.1, baseIso: 800, notes: 'fabrica; 1.90:1'),
    SensorMode(manufacturer: 'CANON', camera: 'EOS C500 Mark II', mode: '4K DCI', widthPx: 4096, heightPx: 2160, widthMm: 26.2, heightMm: 13.8, baseIso: 800, notes: 'calculado; 1.90:1'),
    SensorMode(manufacturer: 'CANON', camera: 'EOS C500 Mark II', mode: 'UHD 4K', widthPx: 3840, heightPx: 2160, widthMm: 35.7, heightMm: 20.1, baseIso: 800, notes: 'fabrica; area 5580x3140'),
    SensorMode(manufacturer: 'CANON', camera: 'EOS C70', mode: '4K DCI', widthPx: 4096, heightPx: 2160, widthMm: 26.2, heightMm: 13.8, baseIso: 800, notes: 'fabrica; 1.90:1'),
    SensorMode(manufacturer: 'CANON', camera: 'EOS C70', mode: 'UHD 4K', widthPx: 3840, heightPx: 2160, widthMm: 24.6, heightMm: 13.8, baseIso: 800, notes: 'calculado; 1.78:1'),
    SensorMode(manufacturer: 'BLACKMAGIC', camera: 'URSA Cine 12K LF', mode: '12K 3:2 Open Gate', widthPx: 12288, heightPx: 8040, widthMm: 35.64, heightMm: 23.32, baseIso: 800, notes: 'fabrica; 1.53:1'),
    SensorMode(manufacturer: 'BLACKMAGIC', camera: 'URSA Cine 12K LF', mode: '12K 16:9', widthPx: 12288, heightPx: 6912, widthMm: 35.64, heightMm: 20.04, baseIso: 800, notes: 'calculado; 1.78:1'),
    SensorMode(manufacturer: 'BLACKMAGIC', camera: 'URSA Cine 12K LF', mode: '12K 17:9', widthPx: 12288, heightPx: 6480, widthMm: 35.64, heightMm: 18.79, baseIso: 800, notes: 'calculado; 1.89:1'),
    SensorMode(manufacturer: 'BLACKMAGIC', camera: 'URSA Cine 12K LF', mode: '12K 2.4:1', widthPx: 12288, heightPx: 5112, widthMm: 35.64, heightMm: 14.82, baseIso: 800, notes: 'calculado; 2.40:1'),
    SensorMode(manufacturer: 'BLACKMAGIC', camera: 'URSA Cine 12K LF', mode: '12K 6:5 ana 2x', widthPx: 9648, heightPx: 8040, widthMm: 27.98, heightMm: 23.32, baseIso: 800, notes: 'calculado; 2.40:1 desplegado'),
    SensorMode(manufacturer: 'BLACKMAGIC', camera: 'URSA Cine 12K LF', mode: '9K 3:2 S35', widthPx: 9408, heightPx: 6264, widthMm: 27.28, heightMm: 18.17, baseIso: 800, notes: 'calculado; 1.50:1'),
    SensorMode(manufacturer: 'BLACKMAGIC', camera: 'URSA Mini Pro 12K', mode: '12K DCI', widthPx: 12288, heightPx: 6480, widthMm: 27.03, heightMm: 14.25, baseIso: 800, notes: 'fabrica; 1.90:1'),
    SensorMode(manufacturer: 'BLACKMAGIC', camera: 'URSA Mini Pro 12K', mode: '12K 2.4:1', widthPx: 12288, heightPx: 5112, widthMm: 27.03, heightMm: 11.25, baseIso: 800, notes: 'calculado; 2.40:1'),
    SensorMode(manufacturer: 'BLACKMAGIC', camera: 'URSA Mini Pro 12K', mode: '8K DCI', widthPx: 8192, heightPx: 4320, widthMm: 18.02, heightMm: 9.5, baseIso: 800, notes: 'calculado; 1.90:1'),
    SensorMode(manufacturer: 'BLACKMAGIC', camera: 'PYXIS 6K', mode: '6K 3:2 Open Gate', widthPx: 6048, heightPx: 4032, widthMm: 36, heightMm: 24, baseIso: 400, notes: 'fabrica; dual 400/3200'),
    SensorMode(manufacturer: 'BLACKMAGIC', camera: 'PYXIS 6K', mode: '6K 6:5 ana 2x', widthPx: 4832, heightPx: 4032, widthMm: 28.7, heightMm: 23.95, baseIso: 400, notes: 'calculado; 2.40:1 desplegado'),
    SensorMode(manufacturer: 'BLACKMAGIC', camera: 'PYXIS 6K', mode: '6K 16:9', widthPx: 6048, heightPx: 3408, widthMm: 35.93, heightMm: 20.24, baseIso: 400, notes: 'calculado; 1.78:1'),
    SensorMode(manufacturer: 'BLACKMAGIC', camera: 'PYXIS 6K', mode: '4K S35 4:3', widthPx: 4096, heightPx: 3072, widthMm: 24.33, heightMm: 18.25, baseIso: 400, notes: 'calculado; 1.33:1'),
    SensorMode(manufacturer: 'BLACKMAGIC', camera: 'Pocket 6K Pro', mode: '6K', widthPx: 6144, heightPx: 3456, widthMm: 23.1, heightMm: 12.99, baseIso: 400, notes: 'fabrica; dual 400/3200'),
    SensorMode(manufacturer: 'BLACKMAGIC', camera: 'Pocket 6K Pro', mode: '6K 2.4:1', widthPx: 6144, heightPx: 2560, widthMm: 23.1, heightMm: 9.63, baseIso: 400, notes: 'calculado; 2.40:1'),
    SensorMode(manufacturer: 'BLACKMAGIC', camera: 'Pocket 6K Pro', mode: '3.7K 6:5 ana 2x', widthPx: 3728, heightPx: 3104, widthMm: 14.02, heightMm: 11.67, baseIso: 400, notes: 'calculado; 2.40:1 desplegado'),
    SensorMode(manufacturer: 'PANAVISION', camera: 'Millennium DXL2', mode: '8K Full Format', widthPx: 8192, heightPx: 4320, widthMm: 40.96, heightMm: 21.6, baseIso: 1600, notes: 'fabrica; 1.89:1'),
    SensorMode(manufacturer: 'PANAVISION', camera: 'Millennium DXL2', mode: '8K 2.4:1', widthPx: 8192, heightPx: 3456, widthMm: 40.96, heightMm: 17.28, baseIso: 1600, notes: 'calculado; 2.37:1'),
    SensorMode(manufacturer: 'PANAVISION', camera: 'Millennium DXL2', mode: '5K S35', widthPx: 5120, heightPx: 2700, widthMm: 25.6, heightMm: 13.5, baseIso: 1600, notes: 'calculado; 1.89:1'),
    SensorMode(manufacturer: 'PHANTOM', camera: 'Flex4K', mode: '4K 4096x2304', widthPx: 4096, heightPx: 2304, widthMm: 27.6, heightMm: 15.5, baseIso: 250, notes: 'fabrica; 1.78:1'),
    SensorMode(manufacturer: 'PHANTOM', camera: 'Flex4K', mode: '4K 16:9', widthPx: 4096, heightPx: 2160, widthMm: 27.6, heightMm: 14.6, baseIso: 250, notes: 'calculado; 1.90:1'),
  ];

  /// Cámaras disponibles, en orden de catálogo y sin repetir.
  static List<String> get cameras {
    final seen = <String>{};
    final names = <String>[];
    for (final m in all) {
      if (seen.add(m.cameraLabel)) names.add(m.cameraLabel);
    }
    return names;
  }

  static List<SensorMode> modesOf(String cameraLabel) =>
      all.where((m) => m.cameraLabel == cameraLabel).toList();

  /// Modos de una cámara buscando sólo por el nombre del modelo.
  static List<SensorMode> modesOfCamera(String camera) =>
      all.where((m) => m.camera == camera).toList();

  /// Primer modo de una cámara (para preseleccionar en la interfaz).
  static SensorMode? firstModeOf(String cameraLabel) {
    for (final m in all) {
      if (m.cameraLabel == cameraLabel) return m;
    }
    return null;
  }

  static SensorMode? byId(String manufacturer, String camera, String mode) {
    for (final m in all) {
      if (m.manufacturer == manufacturer && m.camera == camera && m.mode == mode) {
        return m;
      }
    }
    return null;
  }
}
