import 'package:camera/camera.dart';

/// Cámara de captura disponible en el dispositivo.
class CaptureCamera {
  final String name;
  final String id;
  final CameraLensDirection direction;

  const CaptureCamera({
    required this.name,
    required this.id,
    required this.direction,
  });

  bool get isFront => direction == CameraLensDirection.front;

  String get label => isFront ? 'FRONTAL · $name' : 'TRASERA · $name';
}

/// Descubre las cámaras del dispositivo (trasera, frontal, webcam).
///
/// En la computadora el "webcam" aparece como cámara externa o como trasera.
/// Si el sistema no da permiso, devuelve una lista vacía en vez de fallar.
class CameraDevices {
  CameraDevices._();

  static Future<List<CaptureCamera>> list() async {
    try {
      final cameras = await availableCameras();
      return cameras
          .map((c) => CaptureCamera(
                name: c.name,
                id: c.name,
                direction: c.lensDirection,
              ))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Elige una cámara: la primera trasera si existe, si no la primera.
  static CaptureCamera? pick(List<CaptureCamera> cameras) {
    if (cameras.isEmpty) return null;
    return cameras.where((c) => !c.isFront).firstOrNull ?? cameras.first;
  }
}
