import 'package:flutter/material.dart';

import '../core/localization.dart';
import '../data/app_settings.dart';
import '../data/camera_selection.dart';
import '../data/catalogs/film_formats.dart';
import '../data/catalogs/sensors.dart';
import '../state/shot_state.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

/// Pantalla de inicio: elegir cámara real (del catálogo) y el modo de grabación.
class CameraSetupScreen extends StatefulWidget {
  final VoidCallback? onLangChange;
  final CameraSelection? initial;

  const CameraSetupScreen({super.key, this.onLangChange, this.initial});

  @override
  State<CameraSetupScreen> createState() => _CameraSetupScreenState();
}

class _CameraSetupScreenState extends State<CameraSetupScreen> {
  String? kind;
  String? cameraLabel;
  String? modeName;
  String? filmName;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      kind = initial.kind;
      cameraLabel = initial.camera == null ? null : '${initial.manufacturer} ${initial.camera}';
      modeName = initial.mode;
      filmName = initial.filmFormat;
    }
  }

  List<SensorMode> get _modes =>
      cameraLabel == null ? const [] : SensorCatalog.modesOf(cameraLabel!);

  CameraSelection? get _selection {
    if (kind == 'film') {
      if (filmName == null) return null;
      return CameraSelection(kind: 'film', filmFormat: filmName);
    }
    if (kind == 'digital') {
      final m = _modes.where((x) => x.mode == modeName).toList();
      if (m.isEmpty) return null;
      return CameraSelection(
        kind: 'digital',
        manufacturer: m.first.manufacturer,
        camera: m.first.camera,
        mode: m.first.mode,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnSetColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _flagBtn("🇪🇸 ", "es"),
                    const SizedBox(width: 20),
                    _flagBtn("🇺🇸 ", "en"),
                    const SizedBox(width: 20),
                    _flagBtn("🇧🇷 ", "pt"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.camera, size: 50, color: Colors.white10),
              const SizedBox(height: 10),
              const Text(
                "ON SET PRO",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 6,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              Row(
                children: [
                  _modeCard(t('film'), Icons.movie_creation_outlined, 'film', Colors.amber),
                  const SizedBox(width: 15),
                  _modeCard(t('dig'), Icons.sensor_window_outlined, 'digital', Colors.blueAccent),
                ],
              ),
              if (kind == 'digital') ...[
                const SizedBox(height: 30),
                _dropdown(
                  label: 'CÁMARA',
                  hint: 'Elegí la cámara',
                  value: cameraLabel,
                  items: SensorCatalog.cameras,
                  onChanged: (v) => setState(() {
                    cameraLabel = v;
                    modeName = v == null ? null : SensorCatalog.firstModeOf(v)?.mode;
                  }),
                ),
                const SizedBox(height: 15),
                _dropdown(
                  label: 'MODO DE GRABACIÓN',
                  hint: cameraLabel == null ? 'Primero elegí la cámara' : 'Elegí el modo',
                  value: modeName,
                  items: _modes.map((m) => m.mode).toList(),
                  onChanged: cameraLabel == null
                      ? null
                      : (v) => setState(() => modeName = v),
                ),
                if (_selection != null) _details(_selection!),
              ],
              if (kind == 'film') ...[
                const SizedBox(height: 30),
                _dropdown(
                  label: 'FORMATO FÍLMICO',
                  hint: 'Elegí el formato',
                  value: filmName,
                  items: FilmFormats.all.map((f) => f.name).toList(),
                  onChanged: (v) => setState(() => filmName = v),
                ),
                if (_selection != null) _details(_selection!),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: OnSetColors.brand,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _selection == null ? null : _enter,
                child: Text(
                  t('enter'),
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _enter() async {
    final selection = _selection;
    if (selection == null) return;
    await AppSettings.saveCamera(selection);
    ShotState.instance.setCamera(selection);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (c) => DashboardScreen(selection: selection)),
    );
  }

  Widget _details(CameraSelection s) {
    final sensor = s.sensor;
    final film = s.film;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Text(
        [
          if (sensor != null) '${sensor.widthMm} × ${sensor.heightMm} mm',
          if (sensor?.baseIso != null) 'ISO base ${sensor!.baseIso!.toStringAsFixed(0)}',
          if (film != null) '${film.widthMm} × ${film.heightMm} mm',
          if (film != null) '${film.feetPerMinute.toStringAsFixed(0)} ft/min a 24 fps',
          'CoC ${s.cocMm.toStringAsFixed(4)} mm',
        ].join('   ·   '),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, color: OnSetColors.textSecondary, height: 1.6),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: OnSetColors.textMuted,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(hint, style: const TextStyle(color: Colors.white38, fontSize: 13)),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white24),
              dropdownColor: OnSetColors.surfaceHigh,
              items: items
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: const TextStyle(fontSize: 13, color: Colors.white)),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _flagBtn(String flag, String code) {
    return GestureDetector(
      onTap: () {
        setState(() => lang = code);
        AppSettings.saveLanguage(code);
        widget.onLangChange?.call();
      },
      child: Opacity(
        opacity: lang == code ? 1.0 : 0.3,
        child: Text(flag, style: const TextStyle(fontSize: 22)),
      ),
    );
  }

  Widget _modeCard(String txt, IconData i, String v, Color c) {
    final sel = kind == v;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          kind = v;
          cameraLabel = null;
          modeName = null;
          filmName = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 100,
          decoration: BoxDecoration(
            color: sel ? OnSetColors.surfaceHigh : OnSetColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: sel ? c.withValues(alpha: 0.5) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(i, color: sel ? c : Colors.white24, size: 30),
              const SizedBox(height: 8),
              Text(
                txt,
                style: TextStyle(
                  color: sel ? Colors.white : Colors.white24,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
