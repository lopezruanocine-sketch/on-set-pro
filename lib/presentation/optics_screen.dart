import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/catalogs/sensors.dart';
import '../domain/optics/optics_engine.dart';
import '../state/shot_state.dart';
import '../theme/app_theme.dart';

/// Campo de visión y equivalencia de lentes entre la cámara del plano y otra.
class OpticsScreen extends StatefulWidget {
  const OpticsScreen({super.key});

  @override
  State<OpticsScreen> createState() => _OpticsScreenState();
}

class _OpticsScreenState extends State<OpticsScreen> {
  double focalMm = 50;
  double distanceM = 5;
  String? targetCamera;
  String? targetMode;

  @override
  void initState() {
    super.initState();
    final source = ShotState.instance.camera;
    // Buscamos una cámara con otro tamaño de sensor: comparar dos iguales no
    // aporta nada al lens matching.
    final sourceDiagonal = source == null
        ? null
        : OpticsEngine.diagonalMm(source.widthMm, source.heightMm);
    String? fallback;
    for (final camera in SensorCatalog.cameras) {
      final mode = SensorCatalog.firstModeOf(camera);
      if (mode == null) continue;
      if (fallback == null &&
          camera != '${source?.manufacturer} ${source?.camera}') {
        fallback = camera;
      }
      final diagonal = OpticsEngine.diagonalMm(mode.widthMm, mode.heightMm);
      if (sourceDiagonal == null ||
          (diagonal - sourceDiagonal).abs() / sourceDiagonal > 0.1) {
        targetCamera = camera;
        break;
      }
    }
    targetCamera ??= fallback ?? SensorCatalog.cameras.first;
    targetMode = SensorCatalog.firstModeOf(targetCamera!)?.mode;
  }

  List<SensorMode> get _targetModes =>
      targetCamera == null ? const [] : SensorCatalog.modesOf(targetCamera!);

  SensorMode? get _target {
    if (targetCamera == null || targetMode == null) return null;
    return _targetModes.where((m) => m.mode == targetMode).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final source = ShotState.instance.camera;
    if (source == null) {
      return Scaffold(
        backgroundColor: OnSetColors.background,
        appBar: AppBar(title: const Text('ÓPTICA / FOV')),
        body: const Center(
          child: Text(
            'Elegí una cámara para calcular el campo de visión.',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    final sw = source.widthMm;
    final sh = source.heightMm;
    final fov = OpticsEngine.fieldOfView(
      sensorWidthMm: sw,
      sensorHeightMm: sh,
      focalMm: focalMm,
    );
    final frameW = OpticsEngine.frameWidthAt(
      sensorWidthMm: sw,
      focalMm: focalMm,
      distanceMm: distanceM,
    );
    final frameH = OpticsEngine.frameHeightAt(
      sensorHeightMm: sh,
      focalMm: focalMm,
      distanceMm: distanceM,
    );

    final target = _target;
    final crop = target == null
        ? null
        : OpticsEngine.cropFactor(
            sourceWidthMm: sw,
            sourceHeightMm: sh,
            targetWidthMm: target.widthMm,
            targetHeightMm: target.heightMm,
          );
    final equivalent = target == null
        ? null
        : OpticsEngine.equivalentFocal(
            focalMm: focalMm,
            sourceWidthMm: sw,
            sourceHeightMm: sh,
            targetWidthMm: target.widthMm,
            targetHeightMm: target.heightMm,
          );

    return Scaffold(
      backgroundColor: OnSetColors.background,
      appBar: AppBar(
        backgroundColor: OnSetColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'ÓPTICA / FOV',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 190,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white24),
              ),
              child: CustomPaint(
                painter: FOVPainter(
                  fovHorizontalRad: fov.horizontalDegrees * math.pi / 180,
                  distanceMeters: distanceM,
                  frameWidthMeters: frameW,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'ENCUADRE A ${distanceM.toStringAsFixed(1)} m · ${source.label}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${frameW.toStringAsFixed(2)} m  ×  ${frameH.toStringAsFixed(2)} m',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: Colors.white24),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _miniStat('FOV H', '${fov.horizontalDegrees.toStringAsFixed(1)}°'),
                      _miniStat('FOV V', '${fov.verticalDegrees.toStringAsFixed(1)}°'),
                      _miniStat('FOV DIAG', '${fov.diagonalDegrees.toStringAsFixed(1)}°'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _sectionTitle('A-CAM · ${source.label.split(' · ').first}'),
            Row(
              children: [
                Expanded(child: _numberInput('LENTE (mm)', focalMm, (v) => setState(() => focalMm = v))),
                const SizedBox(width: 15),
                Expanded(
                  child: _numberInput('DISTANCIA (m)', distanceM, (v) => setState(() => distanceM = v)),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: OnSetColors.surface,
                border: Border.all(color: OnSetColors.brand, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LENS MATCHER · B-CAM',
                    style: TextStyle(
                      color: OnSetColors.brand,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _stringDropdown(
                    'CÁMARA DESTINO',
                    targetCamera,
                    SensorCatalog.cameras,
                    (v) => setState(() {
                      targetCamera = v;
                      targetMode = SensorCatalog.firstModeOf(v)?.mode;
                    }),
                  ),
                  const SizedBox(height: 12),
                  _stringDropdown(
                    'MODO',
                    targetMode,
                    _targetModes.map((m) => m.mode).toList(),
                    (v) => setState(() => targetMode = v),
                  ),
                  const SizedBox(height: 20),
                  if (equivalent != null) ...[
                    const Text(
                      'LENTE EQUIVALENTE EN B-CAM',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      '${equivalent.toStringAsFixed(1)} mm',
                      style: const TextStyle(
                        color: OnSetColors.brand,
                        fontSize: 44,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Crop de B respecto de A: ${crop!.toStringAsFixed(2)}×',
                      style: const TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
      );

  Widget _miniStat(String label, String value) => Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w300,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      );

  Widget _numberInput(String label, double value, Function(double) onChanged) {
    return _OpticsField(label: label, value: value, onChanged: onChanged);
  }

  Widget _stringDropdown(
    String label,
    String? value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : null,
              isExpanded: true,
              hint: const Text('Elegí', style: TextStyle(color: Colors.white38, fontSize: 13)),
              dropdownColor: OnSetColors.surfaceHigh,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: options
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: const TextStyle(color: Colors.white, fontSize: 13)),
                      ))
                  .toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
      ],
    );
  }
}

/// Campo numérico con controlador propio (el anterior se recreaba en cada build).
class _OpticsField extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;

  const _OpticsField({required this.label, required this.value, required this.onChanged});

  @override
  State<_OpticsField> createState() => _OpticsFieldState();
}

class _OpticsFieldState extends State<_OpticsField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value.toString());

  @override
  void didUpdateWidget(covariant _OpticsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        double.tryParse(_controller.text) != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            border: Border.all(color: Colors.white24),
          ),
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'monospace',
            ),
            decoration: const InputDecoration(border: InputBorder.none),
            onSubmitted: (v) {
              final n = double.tryParse(v);
              if (n != null) widget.onChanged(n);
            },
          ),
        ),
      ],
    );
  }
}

/// Dibuja el cono de visión de la cámara y el ancho del encuadre.
class FOVPainter extends CustomPainter {
  final double fovHorizontalRad;
  final double distanceMeters;
  final double frameWidthMeters;

  const FOVPainter({
    required this.fovHorizontalRad,
    required this.distanceMeters,
    required this.frameWidthMeters,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cameraX = 22.0;
    final cameraY = size.height / 2;
    final right = size.width - 12;
    final usable = right - cameraX;

    final halfAngle = (fovHorizontalRad / 2).clamp(0.01, math.pi / 2 - 0.01);
    final halfHeight = math.tan(halfAngle) * usable;
    final topY = (cameraY - halfHeight).clamp(2.0, size.height);
    final bottomY = (cameraY + halfHeight).clamp(0.0, size.height - 2);

    final cone = Path()
      ..moveTo(cameraX, cameraY)
      ..lineTo(right, topY)
      ..lineTo(right, bottomY)
      ..close();

    canvas.drawPath(
      cone,
      Paint()..color = OnSetColors.brand.withValues(alpha: 0.10),
    );
    canvas.drawPath(
      cone,
      Paint()
        ..color = OnSetColors.brand.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    canvas.drawCircle(
      Offset(cameraX, cameraY),
      4,
      Paint()..color = Colors.white,
    );

    final label = TextPainter(
      text: TextSpan(
        text: '${frameWidthMeters.toStringAsFixed(1)} m a ${distanceMeters.toStringAsFixed(1)} m',
        style: const TextStyle(color: Colors.white70, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, Offset(right - label.width - 4, size.height - 18));
  }

  @override
  bool shouldRepaint(covariant FOVPainter old) =>
      old.fovHorizontalRad != fovHorizontalRad ||
      old.distanceMeters != distanceMeters ||
      old.frameWidthMeters != frameWidthMeters;
}
