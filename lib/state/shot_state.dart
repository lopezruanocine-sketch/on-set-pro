import 'package:flutter/foundation.dart';

import '../data/camera_selection.dart';
import '../data/catalogs/camera_filters.dart';
import '../data/catalogs/light_gels.dart';
import '../domain/core/units.dart';
import '../domain/exposure/exposure_engine.dart';

/// Estado del plano que comparten todas las herramientas de exposición.
///
/// Antes cada pestaña guardaba su propio ISO, fps y obturador, así que cambiar
/// uno en Compensar no se reflejaba en Fotometría. Ahora hay una sola fuente.
class ShotState extends ChangeNotifier {
  ShotState._();

  static final ShotState instance = ShotState._();

  CameraSelection? camera;
  double iso = 800;
  double fps = 24;
  double shutterAngle = 180;
  CameraFilter filter = CameraFilters.none;
  LightGel? gel;

  /// Carga la cámara elegida: toma su ISO base (o 800 si no está publicado).
  void setCamera(CameraSelection selection) {
    camera = selection;
    iso = selection.baseIso ?? 800;
    notifyListeners();
  }

  void setIso(double value) {
    if (value <= 0 || value == iso) return;
    iso = value;
    notifyListeners();
  }

  void setFps(double value) {
    if (value <= 0 || value == fps) return;
    fps = value;
    notifyListeners();
  }

  void setShutterAngle(double value) {
    if (value <= 0 || value == shutterAngle) return;
    shutterAngle = value;
    notifyListeners();
  }

  /// Fija el obturador a partir de una velocidad 1/x.
  void setShutterDenominator(double denominator) {
    if (denominator <= 0) return;
    setShutterAngle(Units.shutterAngle(fps: fps, shutterDenominator: denominator));
  }

  void setFilter(CameraFilter value) {
    filter = value;
    notifyListeners();
  }

  void setGel(LightGel? value) {
    gel = value;
    notifyListeners();
  }

  double get shutterTime =>
      Units.shutterSeconds(angleDegrees: shutterAngle, fps: fps);

  double get shutterDenominator => 1 / shutterTime;

  double get filterStops => filter.stops;

  double get gelStops => gel?.stops ?? 0;

  /// Configuración de cámara lista para el motor de exposición.
  ExposureSettings settingsFor(double aperture) => ExposureSettings(
        aperture: aperture,
        iso: iso,
        fps: fps,
        shutterAngle: shutterAngle,
        filterStops: filterStops,
        gelStops: gelStops,
      );

  /// Resumen para mostrar en pantalla: "ISO 800 · 1/48 s · sin ND".
  String get summary {
    final nd = filter.stops == 0 ? 'sin ND' : filter.name.split(' — ').first;
    return 'ISO ${iso.toStringAsFixed(0)} · 1/${shutterDenominator.toStringAsFixed(0)} s · $nd';
  }

  /// Vuelve a los valores de fábrica del plano (mantiene la cámara).
  void reset() {
    iso = camera?.baseIso ?? 800;
    fps = 24;
    shutterAngle = 180;
    filter = CameraFilters.none;
    gel = null;
    notifyListeners();
  }
}
