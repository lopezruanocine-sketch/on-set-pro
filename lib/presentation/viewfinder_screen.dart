import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../data/camera_devices.dart';
import '../data/viewfinder_settings.dart';
import '../domain/optics/viewfinder_math.dart';
import '../theme/app_theme.dart';

/// Visor de dirección: muestra la vista de la cámara del dispositivo con el
/// encuadre de la cámara de cine dibujado encima.
///
/// Funciona con la cámara trasera, la frontal o la webcam de la computadora,
/// porque usa todas las cámaras que el sistema expone.
class ViewfinderScreen extends StatefulWidget {
  const ViewfinderScreen({super.key});

  @override
  State<ViewfinderScreen> createState() => _ViewfinderScreenState();
}

class _ViewfinderScreenState extends State<ViewfinderScreen> {
  List<CaptureCamera> devices = const [];
  CameraController? controller;
  CaptureCamera? current;
  bool loading = true;
  String? error;

  double sensorWidth = ViewfinderMath.s16WidthMm;
  double sensorHeight = ViewfinderMath.s16HeightMm;
  double focal = 25;
  double phoneFov = 70;
  bool squeeze2x = false;
  ViewfinderSettings settings = ViewfinderSettings.defaults;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  /// Recupera la memoria del visor y después busca las cámaras.
  Future<void> _boot() async {
    final saved = await ViewfinderSettings.load();
    if (!mounted) return;
    setState(() {
      settings = saved;
      sensorWidth = saved.sensorWidthMm;
      sensorHeight = saved.sensorHeightMm;
      focal = saved.focalMm;
      phoneFov = saved.phoneFov;
      squeeze2x = saved.squeeze;
    });
    await _loadDevices(preferredId: saved.cameraId);
  }


  /// Guarda el encuadre cada vez que cambia algo.
  Future<void> _persist() async {
    settings = settings.copyWith(
      cameraId: current?.id,
      sensorWidthMm: sensorWidth,
      sensorHeightMm: sensorHeight,
      focalMm: focal,
      phoneFov: phoneFov,
      squeeze: squeeze2x,
    );
    await settings.save();
  }

  Future<void> _loadDevices({String? preferredId}) async {
    // Si el sistema no responde (sin permiso o sin cámara), no dejamos la
    // pantalla girando para siempre.
    final found = await CameraDevices.list().timeout(
      const Duration(seconds: 8),
      onTimeout: () => const [],
    );
    if (!mounted) return;
    setState(() {
      devices = found;
      loading = false;
      if (found.isEmpty) {
        error = 'No hay cámaras disponibles. Aceptá el permiso de cámara '
            'y recargá la pantalla.';
      }
    });

    // La cámara guardada manda; si ya no está, se cae a la de siempre.
    CaptureCamera? pick;
    if (preferredId != null) {
      for (final d in found) {
        if (d.id == preferredId) {
          pick = d;
          break;
        }
      }
      if (pick == null && found.isNotEmpty) {
        error = 'La cámara guardada ya no está disponible: uso otra.';
      }
    }
    pick ??= CameraDevices.pick(found);
    if (pick != null) await _start(pick, remember: true);
  }

  Future<void> _start(CaptureCamera device, {bool remember = true}) async {
    await controller?.dispose();
    try {
      final next = CameraController(
        CameraDescription(
          name: device.id,
          lensDirection: device.direction,
          sensorOrientation: 90,
        ),
        ResolutionPreset.high,
        enableAudio: false,
      );
      await next.initialize();
      if (!mounted) {
        await next.dispose();
        return;
      }
      setState(() {
        controller = next;
        current = device;
      });
      if (remember) await _persist();
    } catch (e) {
      if (!mounted) return;
      setState(() => error = 'No se pudo abrir la cámara: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = ViewfinderMath.frame(
      phoneHorizontalFovDegrees: phoneFov,
      sensorWidthMm: sensorWidth,
      sensorHeightMm: sensorHeight,
      focalMm: focal,
      squeeze: squeeze2x ? 2 : 1,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'VISOR',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _chooseCamera,
              child: Container(
                color: Colors.black,
                child: _preview(frame),
              ),
            ),
          ),
          _controls(frame),
        ],
      ),
    );
  }

  Widget _preview(ViewfinderFrame frame) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: OnSetColors.brand));
    }
    if (error != null || controller == null || !controller!.value.isInitialized) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error ?? 'Sin cámara.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final frameW = w * frame.widthFraction;
        final frameH = frameW / frame.aspectRatio;
        return Stack(
          children: [
            Positioned.fill(child: CameraPreview(controller!)),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _FramePainter(
                    width: frameW,
                    height: frameH,
                    aspect: frame.aspectRatio,
                    covers: frame.coversSensor,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: Text(
                current?.label ?? '',
                style: const TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _controls(ViewfinderFrame frame) {
    return Container(
      color: OnSetColors.background,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _cameraRow(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _sensorPicker()),
              const SizedBox(width: 10),
              Expanded(child: _focalPicker()),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _numberField('FOV TELÉFONO (°)', phoneFov, (v) => setState(() => phoneFov = v))),
              const SizedBox(width: 10),
              Expanded(
                child: _chip('ANAMÓRFICO 2×', squeeze2x, () {
                  setState(() => squeeze2x = !squeeze2x);
                  _persist();
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Encuadre ${(frame.widthFraction * 100).toStringAsFixed(0)} % del ancho · '
            'aspecto ${frame.aspectRatio.toStringAsFixed(2)}:1 · '
            '${frame.coversSensor ? 'la óptica cubre el sensor' : 'RIESGO DE VIÑETEADO'}'
            '${devices.length > 1 ? ' · tocá la imagen para cambiar de cámara' : ''}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              color: frame.coversSensor ? Colors.white38 : OnSetColors.danger,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Selector visible: lista todas las cámaras y la elegida queda guardada.
  Future<void> _chooseCamera() async {
    if (devices.isEmpty) return;
    final chosen = await showModalBottomSheet<CaptureCamera>(
      context: context,
      backgroundColor: OnSetColors.surface,
      shape: const RoundedRectangleBorder(),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Row(
                children: [
                  Text(
                    'CÁMARA DE CAPTURA',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            for (final device in devices)
              ListTile(
                dense: true,
                leading: Icon(
                  device.isFront ? Icons.camera_front : Icons.camera_rear,
                  color: device.id == current?.id ? OnSetColors.brand : Colors.white38,
                  size: 20,
                ),
                title: Text(
                  device.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: device.id == current?.id ? OnSetColors.brand : Colors.white,
                  ),
                ),
                trailing: device.id == current?.id
                    ? const Icon(Icons.check, color: OnSetColors.brand, size: 16)
                    : null,
                onTap: () => Navigator.pop(context, device),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (chosen != null) await _start(chosen);
  }

  /// Muestra la cámara en uso y deja cambiarla.
  Widget _cameraRow() {
    final label = current?.label ?? (devices.isEmpty ? 'SIN CÁMARA' : 'ELEGÍ UNA CÁMARA');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: OnSetColors.surface,
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(
            current?.isFront == true ? Icons.camera_front : Icons.camera_rear,
            color: OnSetColors.brand,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: devices.isEmpty ? null : _chooseCamera,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: devices.isEmpty ? Colors.white12 : OnSetColors.brand,
                ),
              ),
              child: Text(
                'CAMBIAR',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                  color: devices.isEmpty ? Colors.white24 : OnSetColors.brand,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sensorPicker() {
    final options = <String, (double, double)>{
      'SÚPER 16': (12.52, 7.41),
      'SÚPER 35': (24.89, 18.66),
      'FULL FRAME': (36.0, 24.0),
      'ALEXA 35 4.6K': (27.99, 19.22),
    };
    String label(double w, double h) => options.entries
        .firstWhere((e) => (e.value.$1 - w).abs() < 0.05 && (e.value.$2 - h).abs() < 0.05,
            orElse: () => const MapEntry('PERSONALIZADO', (36.0, 24.0)))
        .key;

    return _dropdownBox(
      'SENSOR',
      label(sensorWidth, sensorHeight),
      options.keys.toList(),
      (v) {
        final size = options[v]!;
        setState(() {
          sensorWidth = size.$1;
          sensorHeight = size.$2;
        });
        _persist();
      },
    );
  }

  Widget _focalPicker() {
    const focales = [12.0, 14, 18, 21, 25, 32, 35, 40, 50, 65, 75, 85, 100, 135];
    return _dropdownBox(
      'FOCAL (mm)',
      focal.toStringAsFixed(0),
      focales.map((f) => f.toStringAsFixed(0)).toList(),
      (v) {
        setState(() => focal = double.parse(v));
        _persist();
      },
    );
  }

  Widget _dropdownBox(String label, String value, List<String> options, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: OnSetColors.surface, border: Border.all(color: Colors.white24)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : null,
              isExpanded: true,
              dropdownColor: OnSetColors.surfaceHigh,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
              items: options
                  .map((o) => DropdownMenuItem(
                        value: o,
                        child: Text(o, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ))
                  .toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        margin: const EdgeInsets.only(top: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? OnSetColors.surfaceHigh : Colors.transparent,
          border: Border.all(color: active ? OnSetColors.brand : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: active ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }

  Widget _numberField(String label, double value, Function(double) onChanged) {
    return _FovField(label: label, value: value, onChanged: onChanged);
  }
}

/// Dibuja el encuadre de cine sobre la vista de la cámara.
class _FramePainter extends CustomPainter {
  final double width;
  final double height;
  final double aspect;
  final bool covers;

  const _FramePainter({
    required this.width,
    required this.height,
    required this.aspect,
    required this.covers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: width,
      height: height,
    );

    // Oscurece todo lo que queda fuera del encuadre.
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRect(rect),
    );
    canvas.drawPath(outside, Paint()..color = Colors.black.withValues(alpha: 0.55));

    final line = Paint()
      ..color = covers ? OnSetColors.brand : OnSetColors.danger
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(rect, line);

    // Terceras y cruz central.
    final thin = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 0.8;
    for (var i = 1; i < 3; i++) {
      final x = rect.left + rect.width * i / 3;
      final y = rect.top + rect.height * i / 3;
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), thin);
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), thin);
    }
    canvas.drawLine(
      Offset(rect.center.dx - 10, rect.center.dy),
      Offset(rect.center.dx + 10, rect.center.dy),
      thin,
    );
    canvas.drawLine(
      Offset(rect.center.dx, rect.center.dy - 10),
      Offset(rect.center.dx, rect.center.dy + 10),
      thin,
    );
  }

  @override
  bool shouldRepaint(covariant _FramePainter old) =>
      old.width != width || old.height != height || old.covers != covers;
}

class _FovField extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;

  const _FovField({required this.label, required this.value, required this.onChanged});

  @override
  State<_FovField> createState() => _FovFieldState();
}

class _FovFieldState extends State<_FovField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value.toStringAsFixed(0));

  @override
  void didUpdateWidget(covariant _FovField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (double.tryParse(_controller.text) != widget.value) {
      _controller.text = widget.value.toStringAsFixed(0);
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
          style: const TextStyle(fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: OnSetColors.surface, border: Border.all(color: Colors.white24)),
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace'),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
            onChanged: (v) {
              final n = double.tryParse(v);
              if (n != null && n > 5 && n < 170) widget.onChanged(n);
            },
          ),
        ),
      ],
    );
  }
}
