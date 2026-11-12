import 'catalogs/film_formats.dart';
import 'catalogs/sensors.dart';

/// La cámara y el modo que el usuario tiene cargados en la app.
///
/// Es la pieza que conecta el catálogo con todas las pantallas: de acá salen el
/// círculo de confusión, el tamaño del sensor y el ISO base.
class CameraSelection {
  /// `digital` o `film`.
  final String kind;

  /// Cámara y modo (sólo digital).
  final String? manufacturer;
  final String? camera;
  final String? mode;

  /// Formato de película (sólo fílmico).
  final String? filmFormat;

  const CameraSelection({
    required this.kind,
    this.manufacturer,
    this.camera,
    this.mode,
    this.filmFormat,
  });

  bool get isFilm => kind == 'film';

  SensorMode? get sensor {
    if (isFilm) return null;
    final m = manufacturer;
    final c = camera;
    final d = mode;
    if (m == null || c == null || d == null) return null;
    return SensorCatalog.byId(m, c, d);
  }

  FilmFormat? get film => isFilm && filmFormat != null
      ? FilmFormats.byName(filmFormat!)
      : null;

  double get cocMm {
    final s = sensor;
    if (s != null) return s.coc1500Mm;
    final f = film;
    if (f != null) return f.cocMm;
    return 0.0298;
  }

  double get widthMm => sensor?.widthMm ?? film?.widthMm ?? 36.0;

  double get heightMm => sensor?.heightMm ?? film?.heightMm ?? 24.0;

  double? get baseIso => sensor?.baseIso;

  /// Texto para mostrar: "ARRI ALEXA 35 · 4.6K 3:2 Open Gate" o
  /// "Fílmico · 35mm 4-perf full".
  String get label {
    if (isFilm) return 'Fílmico · ${filmFormat ?? '—'}';
    if (camera == null) return '—';
    return '$camera${mode == null ? '' : ' · $mode'}';
  }

  String get manufacturerLabel => manufacturer ?? '';

  Map<String, String> toPrefs() => {
        'camera.kind': kind,
        'camera.manufacturer': manufacturer ?? '',
        'camera.camera': camera ?? '',
        'camera.mode': mode ?? '',
        'camera.film': filmFormat ?? '',
      };

  static CameraSelection? fromPrefs(Map<String, String?> prefs) {
    final kind = prefs['camera.kind'];
    if (kind == null || kind.isEmpty) return null;

    if (kind == 'film') {
      final name = prefs['camera.film'];
      if (name == null || FilmFormats.byName(name) == null) return null;
      return CameraSelection(kind: 'film', filmFormat: name);
    }

    final manufacturer = prefs['camera.manufacturer'];
    final camera = prefs['camera.camera'];
    final mode = prefs['camera.mode'];
    if (manufacturer == null ||
        camera == null ||
        mode == null ||
        SensorCatalog.byId(manufacturer, camera, mode) == null) {
      return null;
    }
    return CameraSelection(
      kind: 'digital',
      manufacturer: manufacturer,
      camera: camera,
      mode: mode,
    );
  }
}
