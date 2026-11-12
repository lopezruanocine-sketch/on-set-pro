class MediaConstants {
  // --- DATA FÍLMICA ---
  // Pies por minuto a 24 FPS estándar.
  static const Map<String, double> filmFeetPerMinute = {
    '16mm': 36.0,
    '35mm (2-perf)': 45.0,
    '35mm (3-perf)': 67.5,
    '35mm (4-perf)': 90.0,
    '65mm (5-perf)': 112.5,
  };

  // Tamaños de chasis comunes en pies
  static const List<int> commonMagSizes = [100, 400, 1000];

  // --- DATA DIGITAL (Tasas de bits Base en Mbps a 24fps) ---
  // Extraído de las hojas blancas de Apple ProRes
  static const Map<String, Map<String, double>> proResBitrates = {
    '1080p (FHD)': {
      'ProRes Proxy': 36.0,
      'ProRes LT': 82.0,
      'ProRes 422': 117.0,
      'ProRes HQ': 176.0,
      'ProRes 4444': 264.0,
    },
    '4K (UHD)': {
      'ProRes Proxy': 145.0,
      'ProRes LT': 328.0,
      'ProRes 422': 471.0,
      'ProRes HQ': 707.0,
      'ProRes 4444': 1058.0, // Más de 1 Gigabit por segundo
    }
  };
}