import 'package:shared_preferences/shared_preferences.dart';

import 'camera_selection.dart';

/// Lo que la app necesita saber antes del primer frame.
class AppBoot {
  final CameraSelection? camera;
  final String language;

  const AppBoot({this.camera, this.language = 'es'});
}

/// Persistencia mínima de la app: cámara activa e idioma.
class AppSettings {
  AppSettings._();

  static const _kLang = 'app.lang';
  static const _keys = ['camera.kind', 'camera.manufacturer', 'camera.camera', 'camera.mode', 'camera.film'];

  static Future<AppBoot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final values = <String, String?>{
      for (final k in _keys) k: prefs.getString(k),
    };
    return AppBoot(
      camera: CameraSelection.fromPrefs(values),
      language: prefs.getString(_kLang) ?? 'es',
    );
  }

  static Future<void> saveCamera(CameraSelection camera) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in camera.toPrefs().entries) {
      await prefs.setString(entry.key, entry.value);
    }
  }

  static Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLang, language);
  }
}
