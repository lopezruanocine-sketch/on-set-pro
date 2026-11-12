/// Un formato de película con su cuadro y su consumo.
///
/// Dimensiones verificadas contra normas SMPTE y publicaciones de fabricante
/// (ver `docs/research/formatos-filmicos.md`).
class FilmFormat {
  final String name;
  final double widthMm;
  final double heightMm;
  final int perfsPerFrame;

  /// Consumo a 24 fps, en pies por minuto.
  final double feetPerMinute;

  /// Consumo a 24 fps, en metros por minuto.
  final double metresPerMinute;

  /// Círculo de confusión de referencia para este formato, en mm.
  final double cocMm;

  final String notes;

  const FilmFormat({
    required this.name,
    required this.widthMm,
    required this.heightMm,
    required this.perfsPerFrame,
    required this.feetPerMinute,
    required this.metresPerMinute,
    required this.cocMm,
    this.notes = '',
  });

  double get diagonalMm => _sqrt(widthMm * widthMm + heightMm * heightMm);

  double get aspectRatio => heightMm == 0 ? 0 : widthMm / heightMm;

  double minutesForFeet(double feet) => feetPerMinute == 0 ? 0 : feet / feetPerMinute;

  double feetForMinutes(double minutes) => minutes * feetPerMinute;

  double minutesForMetres(double metres) =>
      metresPerMinute == 0 ? 0 : metres / metresPerMinute;

  static double _sqrt(double v) {
    if (v <= 0) return 0;
    var x = v;
    for (var i = 0; i < 40; i++) {
      x = 0.5 * (x + v / x);
    }
    return x;
  }
}

/// Catálogo de formatos fílmicos.
class FilmFormats {
  FilmFormats._();

  static const List<FilmFormat> all = [
    FilmFormat(name: '65mm 5-perf (5/70)', widthMm: 52.48, heightMm: 23.01, perfsPerFrame: 5, feetPerMinute: 112.5, metresPerMinute: 34.29, cocMm: 0.048, notes: 'camara; paso 4.75; COC derivado diag/1200; 500 ft=4.44 min; 1000 ft=8.89 min'),
    FilmFormat(name: '65mm 8-perf (8/70)', widthMm: 52.63, heightMm: 37.72, perfsPerFrame: 8, feetPerMinute: 179.53, metresPerMinute: 54.72, cocMm: 0.054, notes: 'camara; paso 4.75 corto; COC derivado; 1000 ft=5.57 min calc; chasis no verificado'),
    FilmFormat(name: '65mm 15-perf IMAX', widthMm: 70.41, heightMm: 51.61, perfsPerFrame: 15, feetPerMinute: 335.91, metresPerMinute: 102.38, cocMm: 0.073, notes: 'camara; paso corto 4.74; COC derivado; 1000 ft=2.98 min'),
    FilmFormat(name: '35mm 4-perf full', widthMm: 24.92, heightMm: 18.67, perfsPerFrame: 4, feetPerMinute: 90, metresPerMinute: 27.43, cocMm: 0.0254, notes: 'full aperture/Super 35; COC ASC 0.001 in; 400 ft=4.44 min'),
    FilmFormat(name: '35mm 4-perf Academy', widthMm: 22, heightMm: 16, perfsPerFrame: 4, feetPerMinute: 90, metresPerMinute: 27.43, cocMm: 0.0254, notes: 'Academy; 21.95 en ASC; COC ASC; 400 ft=4.44 min'),
    FilmFormat(name: '35mm 3-perf', widthMm: 24.92, heightMm: 13.87, perfsPerFrame: 3, feetPerMinute: 67.5, metresPerMinute: 20.57, cocMm: 0.0254, notes: '3 perf; 0.75x consumo 4-perf; 400 ft=5.93 min'),
    FilmFormat(name: '35mm 2-perf Techniscope', widthMm: 22.05, heightMm: 9.47, perfsPerFrame: 2, feetPerMinute: 45, metresPerMinute: 13.72, cocMm: 0.0254, notes: 'Techniscope; 0.5x consumo 4-perf; 400 ft=8.89 min'),
    FilmFormat(name: 'Super 16', widthMm: 12.52, heightMm: 7.41, perfsPerFrame: 1, feetPerMinute: 36, metresPerMinute: 10.97, cocMm: 0.0125, notes: 'S16; COC Cooke 0.0125; ASC 16mm 0.0152 alternativa; 400 ft=11.11 min'),
    FilmFormat(name: '16mm estandar', widthMm: 10.26, heightMm: 7.49, perfsPerFrame: 1, feetPerMinute: 36, metresPerMinute: 10.97, cocMm: 0.0152, notes: '16mm; COC ASC 0.0006 in; 400 ft=11.11 min'),
    FilmFormat(name: 'Super 8', widthMm: 5.69, heightMm: 4.22, perfsPerFrame: 1, feetPerMinute: 20, metresPerMinute: 6.1, cocMm: 0.006, notes: 'camara; COC derivado; cartucho 50 ft=2.5 min'),
    FilmFormat(name: '8mm estandar', widthMm: 4.9, heightMm: 3.6, perfsPerFrame: 1, feetPerMinute: 18, metresPerMinute: 5.49, cocMm: 0.005, notes: 'Double 8; COC derivado; 25 ft doble 8=2.78 min a 24 fps'),
    FilmFormat(name: '9.5mm Pathe', widthMm: 8.5, heightMm: 6.5, perfsPerFrame: 1, feetPerMinute: 35.62, metresPerMinute: 10.86, cocMm: 0.009, notes: 'camara; COC derivado; 30 ft=0.84 min; 60 ft=1.68 min'),
  ];

  static FilmFormat? byName(String name) {
    for (final f in all) {
      if (f.name == name) return f;
    }
    return null;
  }

  /// Formatos 35 mm (los más usados en set).
  static List<FilmFormat> get thirtyFive =>
      all.where((f) => f.name.startsWith('35mm')).toList();
}
