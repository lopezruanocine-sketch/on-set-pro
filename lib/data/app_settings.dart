import 'package:shared_preferences/shared_preferences.dart';

import 'camera_formats.dart';

/// Cámara activa elegida por el usuario.
class SavedCamera {
  final String mode; // 'film' o 'digital'
  final String format;

  const SavedCamera({required this.mode, required this.format});

  bool get isFilm => CameraFormats.isFilm(mode);

  /// CoC en mm del formato. Nunca falla: si el formato ya no existe usa 0.030.
  double get coc => CameraFormats.cocFor(mode, format) ?? 0.030;
}

/// Lo que la app necesita saber antes del primer frame.
class AppBoot {
  final SavedCamera? camera;
  final String language;

  const AppBoot({this.camera, this.language = 'es'});
}

/// Persistencia mínima de la app: cámara activa e idioma.
class AppSettings {
  AppSettings._();

  static const _kMode = 'setup.mode';
  static const _kFormat = 'setup.format';
  static const _kLang = 'app.lang';

  static Future<AppBoot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_kMode);
    final format = prefs.getString(_kFormat);
    final language = prefs.getString(_kLang) ?? 'es';

    SavedCamera? camera;
    if (mode != null && format != null && CameraFormats.isValid(mode, format)) {
      camera = SavedCamera(mode: mode, format: format);
    }
    return AppBoot(camera: camera, language: language);
  }

  static Future<void> saveCamera(SavedCamera camera) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMode, camera.mode);
    await prefs.setString(_kFormat, camera.format);
  }

  static Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLang, language);
  }
}
