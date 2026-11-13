import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/camera_devices.dart';
import '../data/viewfinder_settings.dart';
import '../domain/optics/viewfinder_math.dart';
import '../state/shot_state.dart';
import '../theme/app_theme.dart';
import 'viewfinder_guides.dart';

/// Visor de dirección: la imagen de la cámara del teléfono con el encuadre de
/// la cámara de cine encima.
///
/// El cuadro ocupa siempre lo máximo posible de la pantalla; al elegir una
/// focal más larga no se achica el cuadro: se agranda la imagen (zoom digital),
/// igual que en un visor profesional.
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

  String safeZone = 'NINGUNA';
  bool titleSafe = true;
  bool thirds = true;
  bool capturing = false;

  /// En vertical, los controles se pliegan para dejar la imagen a pantalla
  /// completa: se desliza el tirador hacia arriba o abajo.
  bool controlsOpen = true;

  /// Zoom que aplicó la propia cámara del dispositivo. La vista no se toca:
  /// es la cámara la que acerca la imagen, como en la app de cámara.
  double appliedZoom = 1;

  /// El dispositivo no permite zoom por software.
  bool zoomUnsupported = false;

  /// Zoom por dibujo (agranda la imagen en pantalla). Se usa sólo cuando la
  /// cámara no puede acercar; algunos navegadores lo muestran en negro, así
  /// que se puede apagar.
  bool visualZoom = true;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // Si el almacenamiento falla, el visor tiene que abrir igual.
    ViewfinderSettings saved;
    try {
      saved = await ViewfinderSettings.load();
    } catch (_) {
      saved = ViewfinderSettings.defaults;
    }
    // Si el visor no tiene sensor guardado, usa el de la cámara elegida al
    // entrar a la app: no tiene sentido preguntarlo dos veces.
    final active = ShotState.instance.camera;
    if (!mounted) return;
    setState(() {
      settings = saved;
      sensorWidth = saved.sensorWidthMm ?? active?.widthMm ?? ViewfinderMath.s16WidthMm;
      sensorHeight = saved.sensorHeightMm ?? active?.heightMm ?? ViewfinderMath.s16HeightMm;
      focal = saved.focalMm;
      phoneFov = saved.phoneFov;
      squeeze2x = saved.squeeze;
    });
    await _loadDevices(preferredId: saved.cameraId);
  }

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
    if (pick != null) await _start(pick);
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
        error = null;
      });
      await _applyCameraZoom(_frame);
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

  double? get _safeAspect {
    switch (safeZone) {
      case '16:9':
        return 16 / 9;
      case '9:16':
        return 9 / 16;
      case '4:3':
        return 4 / 3;
      case '2.39:1':
        return 2.39;
      case '1.85:1':
        return 1.85;
      default:
        return null;
    }
  }

  ViewfinderFrame get _frame => ViewfinderMath.frame(
        phoneHorizontalFovDegrees: phoneFov,
        sensorWidthMm: sensorWidth,
        sensorHeightMm: sensorHeight,
        focalMm: focal,
        squeeze: squeeze2x ? 2 : 1,
      );

  @override
  Widget build(BuildContext context) {
    final frame = _frame;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final landscape = orientation == Orientation.landscape;
            return landscape
                ? Row(
                    children: [
                      Expanded(child: _preview(frame)),
                      SizedBox(width: 300, child: _controls(frame, compact: true)),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(child: _preview(frame)),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        height: controlsOpen ? 360 : 46,
                        child: Column(
                          children: [
                            _handle(),
                            if (controlsOpen) Expanded(child: _controls(frame, compact: false)),
                          ],
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ vista ---

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
        // El cuadro ocupa lo máximo posible con la proporción de la cámara.
        final frameRect = _fitRect(box.maxWidth, box.maxHeight, frame.aspectRatio);
        return Stack(
          children: [
            Positioned.fill(child: _zoomedPreview(frame)),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GuidesPainter(
                    frame: frameRect,
                    safeAspect: _safeAspect,
                    titleSafe: titleSafe,
                    thirds: thirds,
                    covers: frame.coversSensor,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 10,
              child: _readout(frame),
            ),
            Positioned(
              right: 12,
              top: 10,
              child: _closeButton(),
            ),
          ],
        );
      },
    );
  }

  /// La imagen, con zoom digital para igualar el campo de visión del lente.
  /// La vista de la cámara.
  ///
  /// Primero intenta que acerque la propia cámara (queda igual que en la app
  /// de cámara). Si el dispositivo no puede, y el usuario lo permite, se
  /// agranda la imagen al dibujarla: eso no cambia el tamaño de la vista, que
  /// es lo que dejaba la pantalla en negro.
  Widget _zoomedPreview(ViewfinderFrame frame) {
    final wantsZoom = !zoomUnsupported && appliedZoom <= 1.02;
    final raw = frame.widthFraction <= 0 ? 1.0 : 1 / frame.widthFraction;
    final visual = visualZoom && wantsZoom && raw.isFinite
        ? raw.clamp(1.0, 8.0)
        : 1.0;

    if (visual <= 1.02) return CameraPreview(controller!);

    return ClipRect(
      child: Transform.scale(
        scale: visual,
        child: CameraPreview(controller!),
      ),
    );
  }

  /// Cuánto se está acercando la imagen que se ve.
  double _visibleZoom(ViewfinderFrame frame) {
    if (appliedZoom > 1.02 && !zoomUnsupported) return appliedZoom;
    final raw = frame.widthFraction <= 0 ? 1.0 : 1 / frame.widthFraction;
    if (!visualZoom || raw.isNaN) return 1;
    return raw.clamp(1.0, 8.0);
  }

  /// Pide a la cámara que acerque lo necesario para igualar el lente elegido.
  Future<void> _applyCameraZoom(ViewfinderFrame frame) async {
    final cam = controller;
    if (cam == null || !cam.value.isInitialized) return;

    final raw = frame.widthFraction <= 0 ? 1.0 : 1 / frame.widthFraction;
    final desired = raw.isFinite ? raw.clamp(1.0, 8.0) : 1.0;

    try {
      final minZoom = await cam.getMinZoomLevel();
      final maxZoom = await cam.getMaxZoomLevel();
      final target = desired.clamp(minZoom, maxZoom).toDouble();
      await cam.setZoomLevel(target);
      if (!mounted) return;
      setState(() {
        appliedZoom = target;
        zoomUnsupported = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        appliedZoom = 1;
        zoomUnsupported = desired > 1.02;
      });
    }
  }

  Rect _fitRect(double maxW, double maxH, double aspect) {
    var w = maxW;
    var h = w / aspect;
    if (h > maxH) {
      h = maxH;
      w = h * aspect;
    }
    return Rect.fromCenter(
      center: Offset(maxW / 2, maxH / 2),
      width: w,
      height: h,
    );
  }

  Widget _readout(ViewfinderFrame frame) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${focal.toStringAsFixed(0)} mm · ${_sensorLabel()}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            shadows: [Shadow(blurRadius: 6, color: Colors.black)],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          frame.widthFraction >= 0.999
              ? 'MÁS ANGULAR QUE LA CÁMARA DEL TELÉFONO'
              : _visibleZoom(frame) > 1.02
                  ? 'ZOOM ${_visibleZoom(frame).toStringAsFixed(1)}×'
                  : 'ENCUADRE COMPLETO · SIN ZOOM',
          style: TextStyle(
            color: frame.widthFraction >= 0.999 ? OnSetColors.danger : Colors.white54,
            fontSize: 9,
            shadows: const [Shadow(blurRadius: 6, color: Colors.black)],
          ),
        ),
      ],
    );
  }

  Widget _closeButton() {
    return GestureDetector(
      onTap: () => Navigator.maybePop(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        color: Colors.black.withValues(alpha: 0.45),
        child: const Icon(Icons.close, color: Colors.white70, size: 16),
      ),
    );
  }

  String _sensorLabel() {
    if ((sensorWidth - 27.99).abs() < 0.1) return 'ALEXA 35';
    if ((sensorWidth - 36.0).abs() < 0.1) return 'FULL FRAME';
    if ((sensorWidth - 24.89).abs() < 0.1) return 'SÚPER 35';
    if ((sensorWidth - 12.52).abs() < 0.1) return 'SÚPER 16';
    return '${sensorWidth.toStringAsFixed(1)} mm';
  }

  /// Tirador para plegar los controles con el dedo.
  Widget _handle() {
    return GestureDetector(
      onTap: () => setState(() => controlsOpen = !controlsOpen),
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -50) setState(() => controlsOpen = true);
        if (velocity > 50) setState(() => controlsOpen = false);
      },
      child: Container(
        height: 46,
        color: OnSetColors.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controlsOpen ? 'OCULTAR CONTROLES' : 'MOSTRAR CONTROLES',
                  style: const TextStyle(
                    fontSize: 8,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white38,
                  ),
                ),
                Icon(
                  controlsOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                  size: 14,
                  color: Colors.white38,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- controles ---

  Widget _controls(ViewfinderFrame frame, {required bool compact}) {
    return Container(
      color: OnSetColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _cameraRow(),
            const SizedBox(height: 8),
            _focalRow(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _sensorPicker()),
                const SizedBox(width: 8),
                Expanded(child: _safeZonePicker()),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _toggle('TERCIOS', thirds, () {
                    setState(() => thirds = !thirds);
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _toggle('MARGEN 90 %', titleSafe, () {
                    setState(() => titleSafe = !titleSafe);
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _toggle('ANAMÓRFICO', squeeze2x, () {
                    setState(() => squeeze2x = !squeeze2x);
                    _persist();
                  }),
                ),
              ],
            ),
            if (appliedZoom <= 1.02) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _toggle('ZOOM VISUAL', visualZoom, () {
                      setState(() => visualZoom = !visualZoom);
                    }),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Acerca la imagen en pantalla cuando la cámara '
                      'no puede hacerlo.',
                      style: TextStyle(fontSize: 8, color: Colors.white24, height: 1.3),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            _fovField(),
            const SizedBox(height: 10),
            _captureButton(),
          ],
        ),
      ),
    );
  }

  /// Una sola fila con los lentes del dispositivo: elegir y ver cuál está
  /// activo es lo mismo, así no hay dos listas iguales en pantalla.
  Widget _cameraRow() {
    if (devices.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: OnSetColors.surface,
          border: Border.all(color: Colors.white24),
        ),
        child: const Text(
          'SIN CÁMARA',
          style: TextStyle(fontSize: 10, color: Colors.white38),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final device in devices)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => _start(device),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: device.id == current?.id
                        ? OnSetColors.brand
                        : OnSetColors.surface,
                    border: Border.all(
                      color: device.id == current?.id
                          ? OnSetColors.brand
                          : Colors.white24,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        device.isFront ? Icons.camera_front : Icons.camera_rear,
                        size: 13,
                        color: device.id == current?.id ? Colors.black : Colors.white38,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _lensTag(device),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: device.id == current?.id ? Colors.black : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          GestureDetector(
            onTap: _chooseCamera,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(border: Border.all(color: Colors.white12)),
              child: const Text(
                'VER TODAS',
                style: TextStyle(fontSize: 9, color: Colors.white38, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _lensTag(CaptureCamera device) {
    final name = device.name.toLowerCase();
    if (device.isFront) return 'FRONTAL';
    if (name.contains('ultra')) return 'GRAN ANGULAR';
    if (name.contains('tele')) return 'TELE';
    if (name.contains('wide')) return 'NORMAL';
    return 'CÁMARA';
  }

  Widget _focalRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text(
              'FOCAL (mm)',
              style: TextStyle(fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              focal.toStringAsFixed(focal % 1 == 0 ? 0 : 1),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Cualquier focal escrita a mano: 80 mm, 37 mm, la que exista.
        _FocalField(
          value: focal,
          onChanged: (v) {
            setState(() => focal = v);
            _persist();
          },
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final f in const <double>[12, 14, 18, 21, 25, 32, 35, 40, 50, 65, 75, 80, 85, 100, 135])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => focal = f);
                      _persist();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: (focal - f).abs() < 0.01 ? OnSetColors.brand : Colors.transparent,
                        border: Border.all(
                          color: (focal - f).abs() < 0.01
                              ? OnSetColors.brand
                              : Colors.white24,
                        ),
                      ),
                      child: Text(
                        f.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: (focal - f).abs() < 0.01 ? Colors.black : Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sensorPicker() {
    final options = <String, (double, double)>{
      'SÚPER 16': (12.52, 7.41),
      'SÚPER 35': (24.89, 18.66),
      'ALEXA 35': (27.99, 19.22),
      'FULL FRAME': (36.0, 24.0),
    };
    final current = options.entries
        .where((e) =>
            (e.value.$1 - sensorWidth).abs() < 0.05 &&
            (e.value.$2 - sensorHeight).abs() < 0.05)
        .map((e) => e.key)
        .firstOrNull;

    return _dropdown(
      'SENSOR',
      current ?? 'PERSONALIZADO',
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

  Widget _safeZonePicker() {
    const options = ['NINGUNA', '16:9', '9:16', '4:3', '2.39:1', '1.85:1'];
    return _dropdown(
      'ZONA SEGURA',
      safeZone,
      options,
      (v) {
        setState(() => safeZone = v);
      },
    );
  }

  Widget _dropdown(String label, String value, List<String> options, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : null,
              hint: Text(value, style: const TextStyle(color: Colors.white, fontSize: 11)),
              isExpanded: true,
              dropdownColor: OnSetColors.surfaceHigh,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
              items: options
                  .map((o) => DropdownMenuItem(
                        value: o,
                        child: Text(o, style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ))
                  .toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggle(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? OnSetColors.surfaceHigh : Colors.transparent,
          border: Border.all(color: active ? OnSetColors.brand : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: active ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }

  Widget _fovField() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'CAMPO DE VISIÓN DEL TELÉFONO',
            style: TextStyle(fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: 64,
          child: _SmallField(
            value: phoneFov,
            onChanged: (v) {
              setState(() => phoneFov = v);
              _persist();
            },
          ),
        ),
        const Text('°', style: TextStyle(fontSize: 10, color: Colors.white54)),
      ],
    );
  }

  Widget _captureButton() {
    return GestureDetector(
      onTap: capturing || controller == null ? null : _capture,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: capturing ? OnSetColors.surfaceHigh : OnSetColors.brand,
          border: Border.all(color: OnSetColors.brand),
        ),
        child: Text(
          capturing ? 'GUARDANDO…' : 'CAPTURAR CUADRO',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            color: capturing ? OnSetColors.brand : Colors.black,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- acciones ---

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
              child: Text(
                'CÁMARA DE CAPTURA',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                ),
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
                onTap: () => Navigator.pop(context, device),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (chosen != null) await _start(chosen);
  }

  /// Toma la foto con la cámara, la recorta al encuadre y le dibuja las guías.
  ///
  /// No se captura la pantalla porque en web la imagen de la cámara vive en
  /// una capa aparte y no entra en la captura: sólo saldrían las guías.
  Future<void> _capture() async {
    final cam = controller;
    if (cam == null) return;
    setState(() => capturing = true);
    try {
      final file = await cam.takePicture();
      final bytes = await file.readAsBytes();
      final composed = await _composeCapture(bytes);
      if (composed == null) return;

      final stamp = DateTime.now();
      final name = 'onset_${stamp.year}${stamp.month.toString().padLeft(2, '0')}'
          '${stamp.day.toString().padLeft(2, '0')}_'
          '${stamp.hour.toString().padLeft(2, '0')}'
          '${stamp.minute.toString().padLeft(2, '0')}.png';
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(composed, mimeType: 'image/png')],
          fileNameOverrides: [name],
          text: 'On Set Pro · ${focal.toStringAsFixed(0)} mm · ${_sensorLabel()}',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo capturar el cuadro: $e')),
      );
    } finally {
      if (mounted) setState(() => capturing = false);
    }
  }

  Future<Uint8List?> _composeCapture(Uint8List photoBytes) async {
    final frame = _frame;
    final photo = await decodeImageFromList(photoBytes);

    // Recorte central: la parte de la imagen que corresponde al campo de
    // visión de la cámara de cine.
    final fraction = frame.widthFraction.clamp(0.02, 1.0).toDouble();
    var cropW = photo.width * fraction;
    var cropH = cropW / frame.aspectRatio;
    if (cropH > photo.height) {
      cropH = photo.height.toDouble();
      cropW = cropH * frame.aspectRatio;
    }
    final src = Rect.fromCenter(
      center: Offset(photo.width / 2, photo.height / 2),
      width: cropW,
      height: cropH,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(cropW, cropH);
    canvas.drawImageRect(photo, src, Offset.zero & size, Paint());

    paintViewfinderGuides(
      canvas,
      Offset.zero & size,
      safeAspect: _safeAspect,
      titleSafe: titleSafe,
      thirds: thirds,
      dimOutside: false,
    );

    final stamp = DateTime.now();
    await paintCaptureStamp(
      canvas,
      size,
      'On Set Pro · ${focal.toStringAsFixed(0)} mm · ${_sensorLabel()} · '
      '${current?.label ?? ''} · '
      '${stamp.day.toString().padLeft(2, '0')}/${stamp.month.toString().padLeft(2, '0')} '
      '${stamp.hour.toString().padLeft(2, '0')}:${stamp.minute.toString().padLeft(2, '0')}',
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.round(), size.height.round());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }
}

/// Pinta las guías sobre la imagen en vivo.
class _GuidesPainter extends CustomPainter {
  final Rect frame;
  final double? safeAspect;
  final bool titleSafe;
  final bool thirds;
  final bool covers;

  const _GuidesPainter({
    required this.frame,
    required this.safeAspect,
    required this.titleSafe,
    required this.thirds,
    required this.covers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    paintViewfinderGuides(
      canvas,
      frame,
      safeAspect: safeAspect,
      titleSafe: titleSafe,
      thirds: thirds,
      frameColor: covers ? OnSetColors.brand : OnSetColors.danger,
      canvasSize: size,
    );
  }

  @override
  bool shouldRepaint(covariant _GuidesPainter old) =>
      old.frame != frame ||
      old.safeAspect != safeAspect ||
      old.titleSafe != titleSafe ||
      old.thirds != thirds ||
      old.covers != covers;
}

/// Campo para escribir cualquier focal, incluidas las que no son redondas.
class _FocalField extends StatefulWidget {
  final double value;
  final Function(double) onChanged;

  const _FocalField({required this.value, required this.onChanged});

  @override
  State<_FocalField> createState() => _FocalFieldState();
}

class _FocalFieldState extends State<_FocalField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value.toStringAsFixed(0));

  @override
  void didUpdateWidget(covariant _FocalField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (double.tryParse(_controller.text) != widget.value) {
      _controller.text = widget.value.toStringAsFixed(
        widget.value % 1 == 0 ? 0 : 1,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: OnSetColors.surface,
        border: Border.all(color: OnSetColors.brand.withValues(alpha: 0.6)),
      ),
      child: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontFamily: 'monospace',
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          suffixText: 'mm',
          suffixStyle: TextStyle(color: Colors.white38, fontSize: 11),
        ),
        onChanged: (v) {
          final n = double.tryParse(v.replaceAll(',', '.'));
          if (n != null && n >= 4 && n <= 400) widget.onChanged(n);
        },
      ),
    );
  }
}

/// Campo chico para el ángulo del teléfono.
class _SmallField extends StatefulWidget {
  final double value;
  final Function(double) onChanged;

  const _SmallField({required this.value, required this.onChanged});

  @override
  State<_SmallField> createState() => _SmallFieldState();
}

class _SmallFieldState extends State<_SmallField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value.toStringAsFixed(0));

  @override
  void didUpdateWidget(covariant _SmallField oldWidget) {
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
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: OnSetColors.surface,
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.right,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
        onChanged: (v) {
          final n = double.tryParse(v);
          if (n != null && n > 5 && n < 170) widget.onChanged(n);
        },
      ),
    );
  }
}
