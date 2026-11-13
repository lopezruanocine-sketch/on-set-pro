import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Dibuja las guías del visor: cuadro, zonas seguras, tercios y cruz.
///
/// Vive aparte del visor porque las mismas guías se usan dos veces: encima
/// de la imagen en vivo y dentro de la foto capturada.
void paintViewfinderGuides(
  Canvas canvas,
  Rect frame, {
  double? safeAspect,
  bool titleSafe = true,
  bool thirds = true,
  Color frameColor = OnSetColors.brand,
  bool dimOutside = true,
  Size? canvasSize,
}) {
  if (dimOutside && canvasSize != null) {
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & canvasSize),
      Path()..addRect(frame),
    );
    canvas.drawPath(outside, Paint()..color = Colors.black.withValues(alpha: 0.55));
  }

  canvas.drawRect(
    frame,
    Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2,
  );

  // Zona segura de entrega (por ejemplo 9:16 dentro del cuadro).
  if (safeAspect != null) {
    var safeW = frame.width;
    var safeH = safeW / safeAspect;
    if (safeH > frame.height) {
      safeH = frame.height;
      safeW = safeH * safeAspect;
    }
    final safeRect = Rect.fromCenter(
      center: frame.center,
      width: safeW,
      height: safeH,
    );
    canvas.drawRect(
      safeRect,
      Paint()
        ..color = Colors.cyanAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  // Margen de acción y títulos: 90 % del cuadro.
  if (titleSafe) {
    canvas.drawRect(
      Rect.fromCenter(
        center: frame.center,
        width: frame.width * 0.9,
        height: frame.height * 0.9,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  final thin = Paint()
    ..color = Colors.white.withValues(alpha: 0.35)
    ..strokeWidth = 1.2;

  if (thirds) {
    for (var i = 1; i < 3; i++) {
      final x = frame.left + frame.width * i / 3;
      final y = frame.top + frame.height * i / 3;
      canvas.drawLine(Offset(x, frame.top), Offset(x, frame.bottom), thin);
      canvas.drawLine(Offset(frame.left, y), Offset(frame.right, y), thin);
    }
  }

  final cross = frame.shortestSide * 0.04;
  canvas.drawLine(
    Offset(frame.center.dx - cross, frame.center.dy),
    Offset(frame.center.dx + cross, frame.center.dy),
    thin,
  );
  canvas.drawLine(
    Offset(frame.center.dx, frame.center.dy - cross),
    Offset(frame.center.dx, frame.center.dy + cross),
    thin,
  );
}

/// Escribe una franja de datos al pie de la foto capturada.
Future<void> paintCaptureStamp(
  Canvas canvas,
  Size size,
  String text,
) async {
  final builder = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.left,
    fontSize: size.height * 0.028,
    fontFamily: 'sans-serif',
  ))
    ..pushStyle(ui.TextStyle(color: const Color(0xFF111111)))
    ..addText(text);
  final paragraph = builder.build()
    ..layout(ui.ParagraphConstraints(width: size.width * 0.94));

  final barHeight = paragraph.height + size.height * 0.02;
  canvas.drawRect(
    Rect.fromLTWH(0, size.height - barHeight, size.width, barHeight),
    Paint()..color = const Color(0xFFFFFFFF),
  );
  canvas.drawParagraph(
    paragraph,
    Offset(size.width * 0.03, size.height - barHeight + size.height * 0.01),
  );
}
