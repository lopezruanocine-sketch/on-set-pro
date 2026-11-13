import 'package:shared_preferences/shared_preferences.dart';

/// Memoria del visor: qué cámara de captura usás y con qué encuadre.
///
/// Se guarda en el dispositivo, así al volver al visor aparece la misma cámara
/// y la misma focal sin tener que elegirlas de nuevo.
class ViewfinderSettings {
  /// Identificador de la cámara de captura (trasera, frontal, webcam).
  final String? cameraId;

  /// Cámara de cine: tamaño del sensor en mm.
  final double sensorWidthMm;
  final double sensorHeightMm;

  /// Focal de la óptica, en mm.
  final double focalMm;

  /// Campo de visión horizontal de la cámara del dispositivo.
  final double phoneFov;

  /// Si se simula anamórfico 2×.
  final bool squeeze;

  const ViewfinderSettings({
    this.cameraId,
    this.sensorWidthMm = 12.52,
    this.sensorHeightMm = 7.41,
    this.focalMm = 25,
    this.phoneFov = 70,
    this.squeeze = false,
  });

  static const defaults = ViewfinderSettings();

  ViewfinderSettings copyWith({
    String? cameraId,
    double? sensorWidthMm,
    double? sensorHeightMm,
    double? focalMm,
    double? phoneFov,
    bool? squeeze,
  }) {
    return ViewfinderSettings(
      cameraId: cameraId ?? this.cameraId,
      sensorWidthMm: sensorWidthMm ?? this.sensorWidthMm,
      sensorHeightMm: sensorHeightMm ?? this.sensorHeightMm,
      focalMm: focalMm ?? this.focalMm,
      phoneFov: phoneFov ?? this.phoneFov,
      squeeze: squeeze ?? this.squeeze,
    );
  }

  // --- persistencia ---

  static const _kCamera = 'viewfinder.cameraId';
  static const _kSensorW = 'viewfinder.sensorWidth';
  static const _kSensorH = 'viewfinder.sensorHeight';
  static const _kFocal = 'viewfinder.focal';
  static const _kFov = 'viewfinder.phoneFov';
  static const _kSqueeze = 'viewfinder.squeeze';

  static Future<ViewfinderSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ViewfinderSettings(
      cameraId: prefs.getString(_kCamera),
      sensorWidthMm: prefs.getDouble(_kSensorW) ?? defaults.sensorWidthMm,
      sensorHeightMm: prefs.getDouble(_kSensorH) ?? defaults.sensorHeightMm,
      focalMm: prefs.getDouble(_kFocal) ?? defaults.focalMm,
      phoneFov: prefs.getDouble(_kFov) ?? defaults.phoneFov,
      squeeze: prefs.getBool(_kSqueeze) ?? false,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    if (cameraId != null) {
      await prefs.setString(_kCamera, cameraId!);
    }
    await prefs.setDouble(_kSensorW, sensorWidthMm);
    await prefs.setDouble(_kSensorH, sensorHeightMm);
    await prefs.setDouble(_kFocal, focalMm);
    await prefs.setDouble(_kFov, phoneFov);
    await prefs.setBool(_kSqueeze, squeeze);
  }
}
