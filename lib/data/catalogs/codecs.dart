/// Tasas de datos de códecs, verificadas contra documentación de fabricante.
///
/// `mbps` está en MEGABITS por segundo. Para pasar a MB/s se divide por 8.
/// Fuente de cada fila: `docs/research/codecs-data.md`.
class CodecRate {
  final String codec;
  final String resolution;
  final double fps;
  final double mbps;
  final String notes;

  const CodecRate({
    required this.codec,
    required this.resolution,
    required this.fps,
    required this.mbps,
    this.notes = '',
  });

  /// GB por hora a esta tasa (GB decimales, 1000 MB).
  double get gigabytesPerHour => mbps * 3600 / 8 / 1000;

  /// MB por segundo.
  double get megabytesPerSecond => mbps / 8;

  String get label => '$codec $resolution';
}

/// Catálogo de códecs.
class Codecs {
  Codecs._();

  static const List<CodecRate> all = [
    CodecRate(codec: 'ARRIRAW', resolution: '4608x3164', fps: 24.0, mbps: 4549.0, notes: 'ALEXA 35 13-bit Log; 568,6 MB/s; 2047 GB/h calc (ARRI: 2.055 GB/h c/audio); OFICIAL+CALC'),
    CodecRate(codec: 'ARRIRAW', resolution: '4608x3164', fps: 25.0, mbps: 4738.0, notes: 'ALEXA 35; 592,3 MB/s; CALC'),
    CodecRate(codec: 'ARRIRAW', resolution: '4608x3164', fps: 30.0, mbps: 5686.0, notes: 'ALEXA 35; 710,8 MB/s; CALC'),
    CodecRate(codec: 'ARRIRAW', resolution: '4608x3164', fps: 48.0, mbps: 9098.0, notes: 'ALEXA 35; 1137,2 MB/s; CALC'),
    CodecRate(codec: 'ARRIRAW', resolution: '4608x3164', fps: 60.0, mbps: 11372.0, notes: 'ALEXA 35; 1421,5 MB/s; max 60fps (75fps con 2TB); CALC'),
    CodecRate(codec: 'ARRIRAW', resolution: '4448x3096', fps: 24.0, mbps: 3966.0, notes: 'ALEXA Mini LF 12-bit; 495,8 MB/s; 1785 GB/h; ARRI 0:32 en 1TB; OFICIAL+CALC'),
    CodecRate(codec: 'ARRIRAW', resolution: '4448x3096', fps: 25.0, mbps: 4131.0, notes: 'ALEXA Mini LF; 516,4 MB/s; CALC'),
    CodecRate(codec: 'ARRIRAW', resolution: '4448x3096', fps: 30.0, mbps: 4958.0, notes: 'ALEXA Mini LF; 619,7 MB/s; CALC'),
    CodecRate(codec: 'ARRIRAW', resolution: '4448x3096', fps: 40.0, mbps: 6610.0, notes: 'ALEXA Mini LF; 826,3 MB/s; max 40fps; CALC'),
    CodecRate(codec: 'ProRes 422 Proxy', resolution: '1920x1080', fps: 29.97, mbps: 45.0, notes: '5,6 MB/s; tabla Apple 60i/30p; OFICIAL'),
    CodecRate(codec: 'ProRes 422 LT', resolution: '1920x1080', fps: 29.97, mbps: 102.0, notes: '12,8 MB/s; OFICIAL'),
    CodecRate(codec: 'ProRes 422', resolution: '1920x1080', fps: 29.97, mbps: 147.0, notes: '18,4 MB/s; OFICIAL'),
    CodecRate(codec: 'ProRes 422 HQ', resolution: '1920x1080', fps: 29.97, mbps: 220.0, notes: '27,5 MB/s; OFICIAL'),
    CodecRate(codec: 'ProRes 4444', resolution: '1920x1080', fps: 29.97, mbps: 330.0, notes: '41,2 MB/s; sin alfa; OFICIAL'),
    CodecRate(codec: 'ProRes 4444 XQ', resolution: '1920x1080', fps: 29.97, mbps: 495.0, notes: '61,9 MB/s; sin alfa; texto Apple dice ~500; OFICIAL'),
    CodecRate(codec: 'ProRes 422 Proxy', resolution: '3840x2160', fps: 30.0, mbps: 182.0, notes: '22,8 MB/s; OFICIAL'),
    CodecRate(codec: 'ProRes 422 LT', resolution: '3840x2160', fps: 30.0, mbps: 410.0, notes: '51,2 MB/s; OFICIAL'),
    CodecRate(codec: 'ProRes 422', resolution: '3840x2160', fps: 30.0, mbps: 589.0, notes: '73,6 MB/s; OFICIAL'),
    CodecRate(codec: 'ProRes 422 HQ', resolution: '3840x2160', fps: 30.0, mbps: 884.0, notes: '110,5 MB/s; OFICIAL'),
    CodecRate(codec: 'ProRes 4444', resolution: '3840x2160', fps: 30.0, mbps: 1326.0, notes: '165,8 MB/s; sin alfa; OFICIAL'),
    CodecRate(codec: 'ProRes 4444 XQ', resolution: '3840x2160', fps: 30.0, mbps: 1989.0, notes: '248,6 MB/s; sin alfa; OFICIAL'),
    CodecRate(codec: 'ProRes 422 Proxy', resolution: '4096x2160', fps: 30.0, mbps: 194.0, notes: '24,2 MB/s; OFICIAL'),
    CodecRate(codec: 'ProRes 422 LT', resolution: '4096x2160', fps: 30.0, mbps: 437.0, notes: '54,6 MB/s; OFICIAL'),
    CodecRate(codec: 'ProRes 422', resolution: '4096x2160', fps: 30.0, mbps: 629.0, notes: '78,6 MB/s; OFICIAL'),
    CodecRate(codec: 'ProRes 422 HQ', resolution: '4096x2160', fps: 30.0, mbps: 943.0, notes: '117,9 MB/s; OFICIAL'),
    CodecRate(codec: 'ProRes 4444', resolution: '4096x2160', fps: 30.0, mbps: 1414.0, notes: '176,8 MB/s; sin alfa; OFICIAL'),
    CodecRate(codec: 'ProRes 4444 XQ', resolution: '4096x2160', fps: 30.0, mbps: 2121.0, notes: '265,1 MB/s; sin alfa; OFICIAL'),
    CodecRate(codec: 'X-OCN XT', resolution: '8640x5760', fps: 24.0, mbps: 5345.0, notes: 'VENICE2 8.6K 3:2; 668,1 MB/s; ~3,6:1 vs 16-bit lin; OFICIAL'),
    CodecRate(codec: 'X-OCN ST', resolution: '8640x5760', fps: 24.0, mbps: 3658.0, notes: 'VENICE2 8.6K 3:2; 457,3 MB/s; ~5,2:1; OFICIAL'),
    CodecRate(codec: 'X-OCN LT', resolution: '8640x5760', fps: 24.0, mbps: 2155.0, notes: 'VENICE2 8.6K 3:2; 269,4 MB/s; ~8,8:1; OFICIAL'),
    CodecRate(codec: 'X-OCN XT', resolution: '8640x4576', fps: 24.0, mbps: 4233.0, notes: 'VENICE2 8.6K 17:9; 529,1 MB/s; OFICIAL'),
    CodecRate(codec: 'X-OCN ST', resolution: '8640x4576', fps: 24.0, mbps: 2897.0, notes: 'VENICE2 8.6K 17:9; 362,1 MB/s; OFICIAL'),
    CodecRate(codec: 'X-OCN LT', resolution: '8640x4576', fps: 24.0, mbps: 1706.0, notes: 'VENICE2 8.6K 17:9; 213,3 MB/s; confirmado en texto Sony; OFICIAL'),
    CodecRate(codec: 'X-OCN XT', resolution: '6048x4032', fps: 24.0, mbps: 2631.0, notes: 'VENICE2 6K 3:2; 328,9 MB/s; OFICIAL'),
    CodecRate(codec: 'X-OCN ST', resolution: '6048x4032', fps: 24.0, mbps: 1800.0, notes: 'VENICE2 6K 3:2; 225,0 MB/s; OFICIAL'),
    CodecRate(codec: 'X-OCN LT', resolution: '6048x4032', fps: 24.0, mbps: 1061.0, notes: 'VENICE2 6K 3:2; 132,6 MB/s; OFICIAL'),
    CodecRate(codec: 'REDCODE 3:1', resolution: '8192x4320', fps: 24.0, mbps: 4530.0, notes: '566,2 MB/s; base 16-bit; CALC validado'),
    CodecRate(codec: 'REDCODE 5:1', resolution: '8192x4320', fps: 24.0, mbps: 2718.0, notes: '339,7 MB/s; CALC'),
    CodecRate(codec: 'REDCODE 6:1', resolution: '8192x4320', fps: 24.0, mbps: 2265.0, notes: '283,1 MB/s; RED publica 275 MB/s max en HELIUM; CALC validado'),
    CodecRate(codec: 'REDCODE 8:1', resolution: '8192x4320', fps: 24.0, mbps: 1699.0, notes: '212,3 MB/s; CALC'),
    CodecRate(codec: 'REDCODE 12:1', resolution: '8192x4320', fps: 24.0, mbps: 1132.0, notes: '141,6 MB/s; CALC'),
    CodecRate(codec: 'REDCODE 18:1', resolution: '8192x4320', fps: 24.0, mbps: 755.0, notes: '94,4 MB/s; CALC'),
    CodecRate(codec: 'REDCODE 5:1', resolution: '8192x4320', fps: 60.0, mbps: 6794.0, notes: '849,3 MB/s; CALC'),
    CodecRate(codec: 'REDCODE 5:1', resolution: '4096x2160', fps: 24.0, mbps: 680.0, notes: '84,9 MB/s; CALC'),
    CodecRate(codec: 'REDCODE 8:1', resolution: '4096x2160', fps: 24.0, mbps: 425.0, notes: '53,1 MB/s; CALC'),
    CodecRate(codec: 'BRAW 3:1', resolution: '12288x8040', fps: 24.0, mbps: 9552.0, notes: 'URSA Cine 12K LF; 1194 MB/s; OFICIAL'),
    CodecRate(codec: 'BRAW 8:1', resolution: '12288x8040', fps: 24.0, mbps: 3584.0, notes: 'URSA Cine 12K; 448 MB/s; OFICIAL'),
    CodecRate(codec: 'BRAW 12:1', resolution: '12288x8040', fps: 24.0, mbps: 2392.0, notes: 'URSA Cine 12K; 299 MB/s; OFICIAL'),
    CodecRate(codec: 'BRAW 18:1', resolution: '12288x8040', fps: 24.0, mbps: 1592.0, notes: 'URSA Cine 12K; 199 MB/s; OFICIAL'),
    CodecRate(codec: 'BRAW Q0', resolution: '12288x8040', fps: 24.0, mbps: 11464.0, notes: 'VBR 398-1433 MB/s; usar max para storage; OFICIAL'),
    CodecRate(codec: 'BRAW Q1', resolution: '12288x8040', fps: 24.0, mbps: 6368.0, notes: 'VBR 326-796 MB/s; OFICIAL'),
    CodecRate(codec: 'BRAW Q3', resolution: '12288x8040', fps: 24.0, mbps: 3584.0, notes: 'VBR 179-448 MB/s; OFICIAL'),
    CodecRate(codec: 'BRAW Q5', resolution: '12288x8040', fps: 24.0, mbps: 2864.0, notes: 'VBR 120-358 MB/s; OFICIAL'),
    CodecRate(codec: 'BRAW 5:1', resolution: '12288x6480', fps: 24.0, mbps: 4624.0, notes: 'URSA Mini Pro 12K; 578 MB/s; OFICIAL'),
    CodecRate(codec: 'BRAW 8:1', resolution: '12288x6480', fps: 24.0, mbps: 2888.0, notes: 'URSA Mini Pro 12K; 361 MB/s; OFICIAL'),
    CodecRate(codec: 'BRAW 12:1', resolution: '12288x6480', fps: 24.0, mbps: 1928.0, notes: 'URSA Mini Pro 12K; 241 MB/s; OFICIAL'),
    CodecRate(codec: 'BRAW 18:1', resolution: '12288x6480', fps: 24.0, mbps: 1280.0, notes: 'URSA Mini Pro 12K; 160 MB/s; OFICIAL'),
    CodecRate(codec: 'BRAW 5:1', resolution: '8192x4320', fps: 24.0, mbps: 2056.0, notes: 'URSA Mini Pro 12K 8K; 257 MB/s; OFICIAL'),
    CodecRate(codec: 'BRAW 8:1', resolution: '8192x4320', fps: 24.0, mbps: 1288.0, notes: 'URSA Mini Pro 12K 8K; 161 MB/s; OFICIAL'),
    CodecRate(codec: 'BRAW 5:1', resolution: '6144x3240', fps: 24.0, mbps: 1168.0, notes: 'URSA Mini Pro 12K 6K S16; 146 MB/s; OFICIAL'),
    CodecRate(codec: 'XAVC-I', resolution: '3840x2160', fps: 59.94, mbps: 600.0, notes: '75,0 MB/s; CBG; OFICIAL'),
    CodecRate(codec: 'XAVC-I', resolution: '4096x2160', fps: 29.97, mbps: 300.0, notes: '37,5 MB/s; VBR max; Class 300; OFICIAL'),
    CodecRate(codec: 'XAVC-I', resolution: '3840x2160', fps: 29.97, mbps: 300.0, notes: '37,5 MB/s; Class 300; OFICIAL'),
    CodecRate(codec: 'XAVC-I', resolution: '4096x2160', fps: 23.98, mbps: 240.0, notes: '30,0 MB/s; OFICIAL'),
    CodecRate(codec: 'XAVC-I HD', resolution: '1920x1080', fps: 59.94, mbps: 222.0, notes: '27,8 MB/s; CBG; OFICIAL'),
    CodecRate(codec: 'XAVC-I HD', resolution: '1920x1080', fps: 29.97, mbps: 111.0, notes: '13,9 MB/s; CBG; OFICIAL'),
    CodecRate(codec: 'XAVC-I HD', resolution: '1920x1080', fps: 23.98, mbps: 89.0, notes: '11,1 MB/s; CBG; OFICIAL'),
    CodecRate(codec: 'XAVC-L', resolution: '3840x2160', fps: 59.94, mbps: 150.0, notes: '18,8 MB/s; VBR max; OFICIAL'),
    CodecRate(codec: 'XAVC-L', resolution: '3840x2160', fps: 29.97, mbps: 100.0, notes: '12,5 MB/s; VBR max; OFICIAL'),
    CodecRate(codec: 'XAVC-L HD', resolution: '1920x1080', fps: 59.94, mbps: 50.0, notes: '6,3 MB/s; modo 50M; OFICIAL'),
    CodecRate(codec: 'XAVC-L HD', resolution: '1920x1080', fps: 29.97, mbps: 35.0, notes: '4,4 MB/s; modo 35M; OFICIAL'),
    CodecRate(codec: 'XAVC HS', resolution: '3840x2160', fps: 59.94, mbps: 200.0, notes: '25,0 MB/s; HEVC 4:2:2 10-bit; OFICIAL'),
    CodecRate(codec: 'XAVC HS', resolution: '3840x2160', fps: 59.94, mbps: 150.0, notes: '18,8 MB/s; HEVC 4:2:0; OFICIAL'),
    CodecRate(codec: 'XAVC HS', resolution: '3840x2160', fps: 29.97, mbps: 100.0, notes: '12,5 MB/s; HEVC; OFICIAL'),
    CodecRate(codec: 'XAVC HS', resolution: '3840x2160', fps: 119.88, mbps: 280.0, notes: '35,0 MB/s; HEVC 4:2:2; OFICIAL'),
    CodecRate(codec: 'H.264 generico', resolution: '1920x1080', fps: 29.97, mbps: 50.0, notes: '6,3 MB/s; rango 10-150 segun encoder; NO VERIFICADO exacto'),
    CodecRate(codec: 'H.265 generico', resolution: '3840x2160', fps: 29.97, mbps: 100.0, notes: '12,5 MB/s; rango 30-280; VBR agresivo; NO VERIFICADO exacto'),
  ];

  /// Busca una tasa exacta. Devuelve `null` si no está en el catálogo.
  static CodecRate? find(String codec, String resolution, double fps) {
    for (final r in all) {
      if (r.codec == codec && r.resolution == resolution && (r.fps - fps).abs() < 0.01) {
        return r;
      }
    }
    return null;
  }

  /// Todas las variantes de un códec, por resolución.
  static List<CodecRate> of(String codec) =>
      all.where((r) => r.codec == codec).toList();

  /// Nombres de códec disponibles (sin repetir), en orden de catálogo.
  static List<String> get codecNames {
    final seen = <String>{};
    final names = <String>[];
    for (final r in all) {
      if (seen.add(r.codec)) names.add(r.codec);
    }
    return names;
  }
}
