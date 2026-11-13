import 'package:web/web.dart' as web;

web.HTMLStyleElement? _style;

/// Acerca la imagen de la cámara en el navegador.
///
/// Flutter web no puede transformar la vista de la cámara (la imagen vive en
/// una capa aparte del HTML), pero sí se le puede aplicar una regla CSS al
/// elemento de video. Es la única forma de que el visor llene la pantalla.
void setVideoZoom(double zoom) {
  final safe = zoom.isFinite ? zoom.clamp(1.0, 8.0) : 1.0;
  if (safe <= 1.001) {
    clearVideoZoom();
    return;
  }
  _style ??= web.HTMLStyleElement();
  _style!.textContent =
      'video{transform:scale($safe) !important;transform-origin:center center !important;}';
  if (!_style!.isConnected) {
    web.document.head!.append(_style!);
  }
}

void clearVideoZoom() {
  _style?.remove();
  _style = null;
}
