import 'package:flutter/foundation.dart';

import '../data/camera_selection.dart';
import '../data/catalogs/camera_filters.dart';
import '../data/catalogs/light_gels.dart';
import '../domain/core/units.dart';
import '../domain/exposure/exposure_engine.dart';

/// Estado del plano que comparten todas las herramientas de exposición.
///
/// Separa las dos familias de filtros, porque en set se comportan distinto:
///
///  - **Filtros de cámara**: van delante del sensor (ND, polarizador, 85/80A).
///    Siempre restan luz y siempre hay que compensarlos.
///  - **Gelatinas en la luz**: van delante de la fuente (CTO/CTB, verde,
///    difusión). Restan luz, pero si la medición se hizo con la gelatina puesta
///    ya están dentro de la lectura del fotómetro.
class ShotState extends ChangeNotifier {
  ShotState._();

  static final ShotState instance = ShotState._();

  CameraSelection? camera;
  double iso = 800;
  double fps = 24;
  double shutterAngle = 180;

  /// Filtros delante del sensor (se pueden apilar: IRND + polarizador + 85).
  final List<CameraFilter> cameraFilters = [];

  /// Gelatinas en las fuentes (se pueden apilar: CTO + difusión).
  final List<LightGel> gels = [];

  /// `true` cuando la lectura del fotómetro se tomó con las gelatinas puestas:
  /// en ese caso no se vuelven a descontar.
  bool meterIncludesGels = false;

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

  void setShutterDenominator(double denominator) {
    if (denominator <= 0) return;
    setShutterAngle(Units.shutterAngle(fps: fps, shutterDenominator: denominator));
  }

  // --- filtros de cámara ---

  void addFilter(CameraFilter filter) {
    if (filter.stops == 0) return;
    cameraFilters.add(filter);
    notifyListeners();
  }

  void removeFilter(CameraFilter filter) {
    cameraFilters.remove(filter);
    notifyListeners();
  }

  void clearFilters() {
    cameraFilters.clear();
    notifyListeners();
  }

  // --- gelatinas en la luz ---

  void addGel(LightGel gel) {
    if (gel.stops == 0) return;
    gels.add(gel);
    notifyListeners();
  }

  void removeGel(LightGel gel) {
    gels.remove(gel);
    notifyListeners();
  }

  void clearGels() {
    gels.clear();
    notifyListeners();
  }

  void setMeterIncludesGels(bool value) {
    if (value == meterIncludesGels) return;
    meterIncludesGels = value;
    notifyListeners();
  }

  // --- cuentas ---

  double get shutterTime =>
      Units.shutterSeconds(angleDegrees: shutterAngle, fps: fps);

  double get shutterDenominator => 1 / shutterTime;

  /// Pérdida de luz de los filtros de cámara, en pasos (positivo = quita luz).
  double get filterStops =>
      cameraFilters.fold(0.0, (total, filter) => total + filter.stops);

  /// Pérdida de luz de las gelatinas, en pasos.
  double get gelStops => gels.fold(0.0, (total, gel) => total + gel.stops);

  /// Pérdida de las gelatinas que todavía NO está en la lectura del fotómetro.
  double get gelStopsToCompensate => meterIncludesGels ? 0 : gelStops;

  /// Pérdida total que hay que compensar (cámara + luz).
  double get lossStops => filterStops + gelStopsToCompensate;

  /// Corrimiento de color de los filtros de cámara, en mireds.
  double get cameraFilterMired => cameraFilters.fold(
        0.0,
        (total, filter) => total + (filter.mired ?? 0),
      );

  /// Corrimiento de color de las gelatinas, en mireds.
  double get gelMired =>
      gels.fold(0.0, (total, gel) => total + (gel.mired ?? 0));

  /// Configuración de cámara lista para el motor de exposición.
  ExposureSettings settingsFor(double aperture) => ExposureSettings(
        aperture: aperture,
        iso: iso,
        fps: fps,
        shutterAngle: shutterAngle,
        filterStops: filterStops,
        gelStops: gelStopsToCompensate,
      );

  /// Resumen para mostrar: "ISO 800 · 1/48 s · cámara −2.0 · luz −1.5".
  String get summary {
    final parts = <String>[
      'ISO ${iso.toStringAsFixed(0)}',
      '1/${shutterDenominator.toStringAsFixed(0)} s',
      if (filterStops != 0) 'cámara −${filterStops.toStringAsFixed(1)}',
      if (gelStops != 0) 'luz −${gelStops.toStringAsFixed(1)}',
    ];
    return parts.join(' · ');
  }

  void reset() {
    iso = camera?.baseIso ?? 800;
    fps = 24;
    shutterAngle = 180;
    cameraFilters.clear();
    gels.clear();
    meterIncludesGels = false;
    notifyListeners();
  }
}
