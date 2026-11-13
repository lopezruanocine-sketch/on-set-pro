import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/cine_data.dart';
import '../core/localization.dart';
import '../core/pro_input.dart';
import '../domain/optics/optics_engine.dart';
import '../domain/optics/units_format.dart';
import '../state/shot_state.dart';
import '../theme/app_theme.dart';

/// Profundidad de campo con el sensor real de la cámara elegida.
class DofCalculatorScreen extends StatefulWidget {
  const DofCalculatorScreen({super.key});

  @override
  State<DofCalculatorScreen> createState() => _DofCalculatorScreenState();
}

class _DofCalculatorScreenState extends State<DofCalculatorScreen> {
  double focal = 50;
  double aperture = 2.8;
  double distanceM = 2.0;
  bool useFeet = false;

  static const double _ftPerM = 3.280839895;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ShotState.instance,
      builder: (context, _) {
        final selection = ShotState.instance.camera;
        if (selection == null) {
          return Scaffold(
            backgroundColor: OnSetColors.background,
            appBar: AppBar(title: Text(t('focus'))),
            body: const Center(
              child: Text(
                'Elegí una cámara para calcular la profundidad de campo.',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          );
        }

        final coc = selection.cocMm;
        final dof = OpticsEngine.depthOfField(
          focalMm: focal,
          aperture: aperture,
          subjectDistanceMm: distanceM * 1000,
          cocMm: coc,
        );

        return Scaffold(
          backgroundColor: OnSetColors.background,
          appBar: AppBar(
            backgroundColor: OnSetColors.background,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              t('focus'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Text(
                  'PLANO: ${selection.label}',
                  style: const TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 1),
                ),
                const SizedBox(height: 15),
                _visualizer(dof),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _unitChip('METROS', !useFeet, () => setState(() => useFeet = false)),
                    const SizedBox(width: 8),
                    _unitChip('PIES', useFeet, () => setState(() => useFeet = true)),
                  ],
                ),
                const SizedBox(height: 18),
                ProInput(
                  label: t('lens'),
                  value: focal,
                  min: 8,
                  max: 300,
                  unit: 'mm',
                  color: OnSetColors.camera,
                  onChanged: (v) => setState(() => focal = v),
                ),
                _aperturePicker(),
                ProInput(
                  label: t('dist'),
                  value: useFeet ? distanceM * _ftPerM : distanceM,
                  min: useFeet ? 1 : 0.3,
                  max: useFeet ? 330 : 100,
                  unit: useFeet ? 'ft' : 'm',
                  color: OnSetColors.camera,
                  onChanged: (v) => setState(
                    () => distanceM = useFeet ? v / _ftPerM : v,
                  ),
                  isDecimal: true,
                ),
                const Divider(height: 50, color: Colors.white10),
                _row(t('near'), _fmtMm(dof.nearLimitMm)),
                _row(t('far'), dof.isFarInfinite ? 'INFINITO' : _fmtMm(dof.farLimitMm)),
                _row(t('hyp'), _fmtMm(dof.hyperfocalMm), color: OnSetColors.brand),
                const Divider(height: 50, color: Colors.white10),
                _row('PROFUNDIDAD TOTAL',
                    dof.isFarInfinite ? 'INFINITA' : _fmtMm(dof.totalDepthMm)),
                _row('DELANTE DEL SUJETO', _fmtMm(dof.depthInFrontMm)),
                _row(
                  'DETRÁS DEL SUJETO',
                  dof.isFarInfinite ? 'INFINITO' : _fmtMm(dof.depthBehindMm),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${t('coc')}: ${coc.toStringAsFixed(4)} mm · '
                    '${selection.widthMm.toStringAsFixed(2)} × '
                    '${selection.heightMm.toStringAsFixed(2)} mm '
                    '(diagonal/1500)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _fmtMm(double mm) => formatDistance(
        millimetres: mm,
        useFeet: useFeet,
        feetPerMetre: _ftPerM,
      );

  Widget _aperturePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('aper').toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white38,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<double>(
              value: CineData.apertures.contains(aperture) ? aperture : 2.8,
              isExpanded: true,
              dropdownColor: OnSetColors.surfaceHigh,
              items: CineData.apertures
                  .map((a) => DropdownMenuItem(
                        value: a,
                        child: Text('f/$a', style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => aperture = v!),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _unitChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? OnSetColors.surfaceHigh : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? Colors.white24 : Colors.white10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1,
            color: active ? Colors.white : Colors.white38,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _visualizer(DepthOfField dof) {
    // La escala se ajusta a la zona nítida, no a la hiperfocal: si no, con una
    // hiperfocal de 40 m el sujeto a 2 m queda pegado al borde.
    final span = dof.isFarInfinite
        ? dof.subjectDistanceMm * 3
        : math.max(dof.farLimitMm, dof.subjectDistanceMm) * 1.35;
    final maxScale = math.max(span, dof.subjectDistanceMm * 1.2);
    double toPercent(double mm) => (mm / maxScale).clamp(0.0, 1.0);
    final inf = dof.isFarInfinite;
    final hypVisible = dof.hyperfocalMm <= maxScale;

    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: OnSetColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final w = constraints.maxWidth;
          final pNear = toPercent(dof.nearLimitMm) * w;
          final pDist = toPercent(dof.subjectDistanceMm) * w;
          final pFar = inf ? w : toPercent(dof.farLimitMm) * w;
          final pHyp = toPercent(dof.hyperfocalMm) * w;

          return Stack(
            children: [
              Positioned(
                top: 70,
                left: 10,
                right: 10,
                child: Container(height: 1, color: Colors.white10),
              ),
              const Positioned(
                left: 12,
                top: 60,
                child: Icon(Icons.videocam, color: Colors.white38, size: 16),
              ),
              Positioned(
                left: pNear,
                width: math.max(pFar - pNear, 2),
                top: 58,
                height: 26,
                child: Container(
                  decoration: BoxDecoration(
                    color: OnSetColors.camera.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.horizontal(
                      left: const Radius.circular(4),
                      right: inf ? Radius.zero : const Radius.circular(4),
                    ),
                    border: Border.all(color: OnSetColors.camera.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              Positioned(
                left: pDist - 5,
                top: 64,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),
              Positioned(
                left: pDist - 22,
                top: 38,
                width: 44,
                child: Text(
                  t('g_sub'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              if (!hypVisible)
                Positioned(
                  right: 12,
                  top: 30,
                  child: Text(
                    'H ${(dof.hyperfocalMm / 1000).toStringAsFixed(1)} m →',
                    style: const TextStyle(
                      fontSize: 8,
                      color: OnSetColors.brand,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (hypVisible) ...[
                Positioned(
                  left: pHyp,
                  top: 50,
                  height: 45,
                  child: Container(width: 2, color: OnSetColors.brand),
                ),
                Positioned(
                  left: (pHyp - 32).clamp(0.0, w - 64),
                  top: 28,
                  width: 64,
                  child: Text(
                    t('g_hyp'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 8,
                      color: OnSetColors.brand,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              Positioned(
                left: pNear + 4,
                top: 90,
                child: Text(
                  t('g_dof'),
                  style: const TextStyle(fontSize: 8, color: OnSetColors.camera),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, {Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white54, letterSpacing: 1),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
