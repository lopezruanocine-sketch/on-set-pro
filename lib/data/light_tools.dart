import 'package:flutter/services.dart';

/// Control del flash del teléfono.
///
/// Usa el canal que expone el sistema para la linterna del dispositivo.
/// En web o en computadora no existe: [isAvailable] devuelve `false` y la
/// pantalla lo avisa en vez de fallar.
class TorchController {
  static const MethodChannel _channel =
      MethodChannel('onset/torch');

  Future<bool> get isAvailable async {
    try {
      final available = await _channel.invokeMethod<bool>('isAvailable');
      return available ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setOn(bool on) async {
    try {
      await _channel.invokeMethod<bool>('set', {'on': on});
      return true;
    } catch (_) {
      return false;
    }
  }
}
