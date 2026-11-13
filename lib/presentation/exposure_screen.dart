import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/cine_data.dart';
import '../core/localization.dart';
import '../core/pro_input.dart';
import '../data/catalogs/camera_filters.dart';
import '../data/catalogs/light_gels.dart';
import '../data/shots_repository.dart';
import '../domain/exposure/exposure_engine.dart';
import '../domain/exposure/exposure_recipes.dart';
import '../state/shot_state.dart';
import '../theme/app_theme.dart';

/// Las cuatro herramientas de exposición, conectadas al motor de cálculo.
class ExpoFotoTabs extends StatelessWidget {
  /// Pestaña que se abre primero (0 = zonas, 1 = fall-off, 2 = compensar,
  /// 3 = fotometría).
  final int initialTab;

  const ExpoFotoTabs({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: initialTab.clamp(0, 3),
      child: Scaffold(
        backgroundColor: OnSetColors.background,
        appBar: AppBar(
          backgroundColor: OnSetColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            t('expo'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: OnSetColors.brand,
            labelColor: OnSetColors.brand,
            unselectedLabelColor: Colors.white38,
            tabs: [
              Tab(text: "MAPA DE ZONAS"),
              Tab(text: "FALL-OFF"),
              Tab(text: "COMPENSAR"),
              Tab(text: "FOTOMETRÍA (LUX/F)"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ZoneSystemScreen(),
            InverseSquareTool(),
            ExposureCompensationScreen(),
            LuxFStopUnifiedTool(),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// 1. MAPA DE ZONAS
// -----------------------------------------------------------------
class ZoneSystemScreen extends StatefulWidget {
  const ZoneSystemScreen({super.key});

  @override
  State<ZoneSystemScreen> createState() => _ZoneSystemScreenState();
}

class _ZoneSystemScreenState extends State<ZoneSystemScreen> {
  double cameraF = 2.8;
  double meteredF = 2.8;
  int targetZone = 5;

  static const List<Color> zoneColors = [
    Color(0xFF000000),
    Color(0xFF1A1A1A),
    Color(0xFF333333),
    Color(0xFF4D4D4D),
    Color(0xFF666666),
    Color(0xFF808080),
    Color(0xFF999999),
    Color(0xFFB3B3B3),
    Color(0xFFCCCCCC),
    Color(0xFFE6E6E6),
    Color(0xFFFFFFFF),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ShotState.instance,
      builder: (context, _) {
        final shot = ShotState.instance;
        final reading = ExposureEngine.zoneReading(
          meterAperture: meteredF,
          cameraAperture: cameraF,
          targetZone: targetZone.toDouble(),
          lossStops: shot.lossStops,
        );
        final nd = reading.correctionStops < -0.15
            ? CameraFilters.closestNd(reading.correctionStops)
            : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _planContext(shot),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _dropdown(
                      "f/ EN CÁMARA",
                      cameraF,
                      CineData.apertures,
                      (v) => setState(() => cameraF = v),
                      isFstop: true,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _manualInput(
                      "LECTURA FOTÓMETRO",
                      meteredF,
                      (v) => setState(() => meteredF = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              const Text(
                "TOCA LA ZONA DESTINO",
                style: TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              _zoneStrip(reading.zone),
              const SizedBox(height: 10),
              Row(
                children: [
                  _legendDot(Colors.redAccent, 'LA LECTURA CAE ACÁ'),
                  const SizedBox(width: 16),
                  _legendDot(OnSetColors.brand, 'ZONA DESTINO'),
                ],
              ),
              const SizedBox(height: 30),
              _resultCard(
                stops: reading.correctionStops,
                title: 'INSTRUCCIÓN PARA ILUMINACIÓN',
                subtitle: _zoneSubtitle(reading, nd),
              ),
              if (nd != null) ...[
                const SizedBox(height: 12),
                _hint('O resolvelo con ${nd.name}'),
              ],
            ],
          ),
        );
      },
    );
  }

  String _zoneSubtitle(ZoneReading reading, CameraFilter? nd) {
    if (reading.isOnTarget) return 'La escena ya está en la zona elegida.';
    if (reading.correctionStops > 0) {
      return 'La escena está en zona ${reading.rawZone.toStringAsFixed(1)}: '
          'hay que añadir luz o abrir diafragma.';
    }
    return 'La escena está en zona ${reading.rawZone.toStringAsFixed(1)}: '
        'hay que quitar luz, cerrar diafragma${nd == null ? '' : ' o usar ND'}.';
  }

  Widget _zoneStrip(int currentZone) {
    return SizedBox(
      height: 80,
      child: Row(
        children: List.generate(11, (index) {
          final isCurrent = index == currentZone;
          final isTarget = index == targetZone;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => targetZone = index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: zoneColors[index],
                  border: Border.all(
                    color: isTarget
                        ? OnSetColors.brand
                        : (isCurrent ? Colors.redAccent : Colors.transparent),
                    width: isTarget || isCurrent ? 3 : 0,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    index == 5 ? "V" : "$index",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: index < 5 ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// -----------------------------------------------------------------
// 2. FALL-OFF (INVERSA DEL CUADRADO)
// -----------------------------------------------------------------
class InverseSquareTool extends StatefulWidget {
  const InverseSquareTool({super.key});

  @override
  State<InverseSquareTool> createState() => _ISTState();
}

class _ISTState extends State<InverseSquareTool> {
  double d1 = 2;
  double d2 = 4;
  bool useFeet = false;

  static const double _ftPerM = 3.280839895;
  double _show(double metres) => useFeet ? metres * _ftPerM : metres;
  double _store(double shown) => useFeet ? shown / _ftPerM : shown;

  @override
  Widget build(BuildContext context) {
    final result = ExposureEngine.fallOff(referenceDistance: d1, newDistance: d2);
    final isLoss = result.stops < 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          _fallOffDiagram(result),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _unitChip('METROS', !useFeet, () => setState(() => useFeet = false)),
              const SizedBox(width: 10),
              _unitChip('PIES', useFeet, () => setState(() => useFeet = true)),
            ],
          ),
          const SizedBox(height: 20),
          ProInput(
            label: 'DISTANCIA DE REFERENCIA',
            value: _show(d1),
            min: useFeet ? 0.3 : 0.1,
            max: useFeet ? 100 : 30,
            unit: useFeet ? 'ft' : 'm',
            color: Colors.redAccent,
            onChanged: (v) => setState(() => d1 = _store(v)),
            isDecimal: true,
          ),
          ProInput(
            label: 'NUEVA DISTANCIA',
            value: _show(d2),
            min: useFeet ? 0.3 : 0.1,
            max: useFeet ? 100 : 30,
            unit: useFeet ? 'ft' : 'm',
            color: Colors.redAccent,
            onChanged: (v) => setState(() => d2 = _store(v)),
            isDecimal: true,
          ),
          const SizedBox(height: 25),
          _resultCard(
            stops: result.stops,
            title: 'PÉRDIDA / GANANCIA',
            subtitle: isLoss
                ? 'La fuente pierde ${result.stops.abs().toStringAsFixed(1)} stops al alejarse. '
                    'Abrí ese diafragma, subí la intensidad o acercá la fuente.'
                : 'La fuente gana ${result.stops.toStringAsFixed(1)} stops al acercarse. '
                    'Cerrá el diafragma, bajá la intensidad o alejá la fuente.',
          ),
          if (d2 < 1 || d1 < 1) ...[
            const SizedBox(height: 12),
            _hint('A menos de 1 m la ley inversa deja de ser exacta: '
                'el tamaño de la fuente ya pesa.'),
          ],
          const SizedBox(height: 12),
          _hint('Vale para fuentes puntuales. Con difusores grandes, '
              'booklights o rebotes la caída es menor.'),
        ],
      ),
    );
  }

  Widget _fallOffDiagram(FallOffResult result) {
    return Container(
      height: 130,
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: OnSetColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (ctx, box) {
          final w = box.maxWidth;
          final maxDist = math.max(math.max(d1, d2), 5.0) * 1.15;
          const subjectX = 40.0;
          double xOf(double d) => subjectX + (d / maxDist) * (w - 80);
          final refX = xOf(d1);
          final lightX = xOf(d2);
          final intensity = result.intensityRatio.clamp(0.15, 1.0);

          return Stack(
            children: [
              Positioned(
                top: 95,
                left: 12,
                right: 12,
                child: Container(height: 1, color: Colors.white10),
              ),
              // Referencia: dónde estaba la fuente
              Positioned(
                left: refX - 1,
                top: 60,
                child: Container(width: 2, height: 36, color: Colors.white24),
              ),
              Positioned(
                left: refX - 26,
                top: 100,
                width: 54,
                child: Text(
                  'd₁ ${_show(d1).toStringAsFixed(1)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9, color: Colors.white38),
                ),
              ),
              // Haz de luz: de la fuente al sujeto
              if (lightX > subjectX + 20)
                Positioned(
                  left: subjectX + 10,
                  top: 45,
                  width: lightX - subjectX - 10,
                  height: 34,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.yellowAccent.withValues(alpha: 0.05),
                          Colors.yellowAccent.withValues(alpha: 0.55),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: subjectX - 16,
                top: 42,
                child: Icon(
                  Icons.person,
                  size: 32,
                  color: Colors.white.withValues(alpha: intensity),
                ),
              ),
              Positioned(
                left: lightX - 10,
                top: 48,
                child: const Icon(Icons.lightbulb, color: Colors.yellowAccent, size: 22),
              ),
              Positioned(
                left: lightX - 26,
                top: 72,
                width: 54,
                child: Text(
                  'd₂ ${_show(d2).toStringAsFixed(1)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9, color: Colors.white54),
                ),
              ),
            ],
          );
        },
      ),
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
}

// -----------------------------------------------------------------
// 3. COMPENSAR
// -----------------------------------------------------------------
class ExposureCompensationScreen extends StatefulWidget {
  const ExposureCompensationScreen({super.key});

  @override
  State<ExposureCompensationScreen> createState() =>
      _ExposureCompensationScreenState();
}

class _ExposureCompensationScreenState extends State<ExposureCompensationScreen> {
  double desiredF = 4.0;
  double meteredF = 4.0;
  bool angleMode = true;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ShotState.instance,
      builder: (context, _) {
        final shot = ShotState.instance;
        // La lectura del fotómetro se toma en la base: ISO base de la cámara,
        // 24 fps y 180°.
        final meter = MeterReading(
          aperture: meteredF,
          iso: shot.camera?.baseIso ?? 800,
          fps: 24,
          shutterAngle: 180,
        );
        final camera = shot.settingsFor(desiredF);
        final result = ExposureEngine.compensate(meter: meter, camera: camera);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _dropdown(
                      "f/ DESEADO",
                      desiredF,
                      CineData.apertures,
                      (v) => setState(() => desiredF = v),
                      isFstop: true,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _manualInput(
                      "LECTURA (ISO BASE · 1/48)",
                      meteredF,
                      (v) => setState(() => meteredF = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _sectionLabel('AJUSTES DEL PLANO'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _dropdown(
                      "ISO",
                      shot.iso,
                      CineData.isos,
                      (v) => shot.setIso(v),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _dropdown(
                      "FPS",
                      shot.fps,
                      CineData.fps,
                      (v) => shot.setFps(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _shutterControl(shot),
              const SizedBox(height: 25),
              _sectionLabel('FILTROS DE CÁMARA (DELANTE DEL SENSOR)'),
              const SizedBox(height: 8),
              _lossList(
                items: [
                  for (final f in shot.cameraFilters) (f.name, f.stops),
                ],
                options: CameraFilters.all
                    .where((f) => f.stops > 0)
                    .map((f) => f.name)
                    .toList(),
                emptyText: 'Sin filtros: la lente está limpia.',
                onAdd: (name) => shot.addFilter(CameraFilters.byName(name)),
                onRemove: (i) => shot.removeFilter(shot.cameraFilters[i]),
              ),
              const SizedBox(height: 20),
              _sectionLabel('GELATINAS EN LA LUZ (DELANTE DE LA FUENTE)'),
              const SizedBox(height: 8),
              _lossList(
                items: [
                  for (final g in shot.gels) (g.label, g.stops),
                ],
                options: LightGels.all.map((g) => g.label).toList(),
                emptyText: 'Sin gelatinas: la fuente va limpia.',
                onAdd: (label) => shot.addGel(
                  LightGels.all.firstWhere((g) => g.label == label),
                ),
                onRemove: (i) => shot.removeGel(shot.gels[i]),
              ),
              const SizedBox(height: 12),
              _manualInput(
                'FUENTE PRINCIPAL A (m)',
                shot.keyLightDistanceM,
                (v) => shot.setKeyLightDistance(v),
                prefix: '',
              ),
              const SizedBox(height: 10),
              _meterGelToggle(shot),
              const SizedBox(height: 12),
              _lossTotal(shot),
              const SizedBox(height: 30),
              _resultCard(
                stops: result.stops,
                title: 'CORRECCIÓN NECESARIA',
                subtitle: _compensationSubtitle(result),
              ),
              const SizedBox(height: 16),
              _breakdown(result, shot),
              const SizedBox(height: 16),
              _recipes(result, shot),
              const SizedBox(height: 20),
              _savePlanButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _savePlanButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: OnSetColors.surface,
        foregroundColor: OnSetColors.brand,
        elevation: 0,
        side: const BorderSide(color: OnSetColors.brand),
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: _savePlan,
      child: const Text(
        'GUARDAR PLANO',
        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Future<void> _savePlan() async {
    final shot = ShotState.instance;
    final camera = shot.camera;
    if (camera == null) return;
    final meter = MeterReading(
      aperture: meteredF,
      iso: camera.baseIso ?? 800,
      fps: 24,
      shutterAngle: 180,
    );
    final result = ExposureEngine.compensate(
      meter: meter,
      camera: shot.settingsFor(desiredF),
    );
    final question = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OnSetColors.surface,
        title: const Text('Guardar plano', style: TextStyle(fontSize: 15, color: Colors.white)),
        content: TextField(
          controller: question,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Nota opcional: escena, toma, para qué es…',
            hintStyle: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('GUARDAR', style: TextStyle(color: OnSetColors.brand, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (saved != true) return;
    await ShotsRepository.instance.savePlan(
      camera: camera,
      iso: shot.iso,
      fps: shot.fps,
      shutterAngle: shot.shutterAngle,
      filters: shot.cameraFilters,
      gels: shot.gels,
      meterReading: meteredF,
      correctionStops: result.stops,
      note: question.text.trim().isEmpty ? null : question.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plano guardado en PLANOS Y NOTAS.')),
    );
  }

  String _compensationSubtitle(CompensationResult result) {
    if (result.isBalanced) return 'La exposición coincide con la lectura.';
    if (result.stops > 0) {
      return 'Falta luz: abrí diafragma, subí ISO, alargá el obturador o sumá luz.';
    }
    return 'Sobra luz: cerrá diafragma, bajá ISO, acortá el obturador o poné ND.';
  }

  Widget _shutterControl(ShotState shot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('OBTURADOR'),
            GestureDetector(
              onTap: () => setState(() => angleMode = !angleMode),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: OnSetColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  angleMode ? 'ÁNGULO' : 'VELOCIDAD',
                  style: const TextStyle(
                    fontSize: 9,
                    color: OnSetColors.brand,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (angleMode)
          _dropdown(
            "GRADOS",
            shot.shutterAngle,
            CineData.shutterAngles,
            (v) => shot.setShutterAngle(v),
          )
        else
          _dropdown(
            "1/x SEGUNDOS",
            _nearestDenominator(shot.shutterDenominator),
            _shutterSpeeds,
            (v) => shot.setShutterDenominator(v),
            prefix: '1/',
          ),
      ],
    );
  }

  static const List<double> _shutterSpeeds = [
    24, 25, 30, 48, 50, 60, 96, 100, 120, 125, 200, 250, 500, 1000, 2000, 4000,
  ];

  double _nearestDenominator(double d) {
    var best = _shutterSpeeds.first;
    var diff = double.infinity;
    for (final s in _shutterSpeeds) {
      final delta = (s - d).abs();
      if (delta < diff) {
        diff = delta;
        best = s;
      }
    }
    return best;
  }

  Widget _breakdown(CompensationResult result, ShotState shot) {
    final baseIso = shot.camera?.baseIso ?? 800;
    // Cada fila es su aporte a la CORRECCIÓN (mismo signo que el resultado):
    // si un ajuste suma luz, hay que corregir en contra.
    final breakdown = ExposureEngine.breakdown(camera: shot.settingsFor(desiredF));
    final rows = <(String, double)>[
      (
        'ISO ${shot.iso.toStringAsFixed(0)} vs base ${baseIso.toStringAsFixed(0)}',
        breakdown.isoCorrection,
      ),
      (
        '${shot.fps.toStringAsFixed(shot.fps % 1 == 0 ? 0 : 2)} fps a ${shot.shutterAngle.toStringAsFixed(0)}°',
        breakdown.shutterCorrection,
      ),
      if (shot.filterStops != 0)
        ('FILTROS DE CÁMARA', breakdown.filterCorrection),
      if (shot.gelStopsToCompensate != 0)
        ('GELATINAS EN LA LUZ', breakdown.gelCorrection),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OnSetColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('DE DÓNDE SALE'),
          const SizedBox(height: 10),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      r.$1,
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ),
                  Text(
                    '${r.$2 >= 0 ? '+' : ''}${r.$2.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: r.$2.abs() < 0.05
                          ? Colors.white38
                          : (r.$2 > 0 ? OnSetColors.brand : OnSetColors.danger),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 1),
              ),
              Text(
                '${rows.fold<double>(0, (a, b) => a + b.$2) >= 0 ? '+' : ''}'
                '${rows.fold<double>(0, (a, b) => a + b.$2).toStringAsFixed(1)} stops',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recipes(CompensationResult result, ShotState shot) {
    if (result.isBalanced) return const SizedBox.shrink();

    final recipes = ExposureRecipes.suggest(
      stops: result.stops,
      aperture: desiredF,
      iso: shot.iso,
      shutterAngle: shot.shutterAngle,
      apertureScale: CineData.apertures,
      isoScale: CineData.isos,
      filters: [
        for (final f in shot.cameraFilters) (f.name, f.stops),
      ],
      lightDistanceM: shot.keyLightDistanceM,
    );

    if (recipes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('RECETARIO'),
          const SizedBox(height: 8),
          _hint(
            result.stops > 0
                ? 'No alcanza con una sola variable: hace falta sumar luz en la escena.'
                : 'No alcanza con una sola variable: hace falta quitar luz en la escena o duplicar el filtro.',
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('RECETARIO'),
        const SizedBox(height: 10),
        ...recipes.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: OnSetColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Text(
                    _recipeKindLabel(r.kind),
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white38,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _recipeValueLabel(r, result.stops),
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _recipeKindLabel(RecipeKind kind) => switch (kind) {
        RecipeKind.aperture => 'DIAFRAGMA',
        RecipeKind.iso => 'SENSIBILIDAD',
        RecipeKind.shutter => 'OBTURADOR',
        RecipeKind.nd => 'PONER FILTRO',
        RecipeKind.removeFilter => 'QUITAR FILTRO',
        RecipeKind.moveLight => 'MOVER LA FUENTE',
      };

  String _recipeValueLabel(ExposureRecipe recipe, double stops) {
    switch (recipe.kind) {
      case RecipeKind.aperture:
        final f = recipe.value.toStringAsFixed(1).replaceAll('.0', '');
        return stops > 0 ? 'Abrí a f/$f' : 'Cerrá a f/$f';
      case RecipeKind.iso:
        return 'ISO ${recipe.value.toStringAsFixed(0)}';
      case RecipeKind.shutter:
        return 'Obturador ${recipe.value.toStringAsFixed(0)}°';
      case RecipeKind.nd:
        final name = recipe.filterName ?? 'ND';
        return name.split(' — ').first;
      case RecipeKind.removeFilter:
        final name = recipe.filterName ?? 'filtro';
        return 'Quitá ${name.split(' — ').first}';
      case RecipeKind.moveLight:
        final metres = recipe.value.toStringAsFixed(1);
        return stops > 0
            ? 'Acercá la fuente a $metres m'
            : 'Alejá la fuente a $metres m';
    }
  }

}

// -----------------------------------------------------------------
// 4. FOTOMETRÍA (LUX ⇄ F)
// -----------------------------------------------------------------
class LuxFStopUnifiedTool extends StatefulWidget {
  const LuxFStopUnifiedTool({super.key});

  @override
  State<LuxFStopUnifiedTool> createState() => _LFSUState();
}

class _LFSUState extends State<LuxFStopUnifiedTool> {
  bool isLuxToFStop = true;
  double val = 1000.0;
  double calibration = Photometry.incidentFlat;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ShotState.instance,
      builder: (context, _) {
        final shot = ShotState.instance;
        final result = isLuxToFStop
            ? ExposureEngine.apertureForLux(
                lux: val,
                iso: shot.iso,
                shutterTime: shot.shutterTime,
                calibration: calibration,
                lossStops: shot.lossStops,
              )
            : ExposureEngine.luxForAperture(
                aperture: val,
                iso: shot.iso,
                shutterTime: shot.shutterTime,
                calibration: calibration,
                lossStops: shot.lossStops,
              );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              _toggle(),
              const SizedBox(height: 12),
              Text(
                'Calculado con ${shot.summary}',
                style: const TextStyle(fontSize: 10, color: Colors.white38),
              ),
              const SizedBox(height: 25),
              ProInput(
                label: isLuxToFStop ? "LUX" : "f/",
                value: val,
                min: isLuxToFStop ? 1 : 0.7,
                max: isLuxToFStop ? 20000 : 45,
                color: Colors.blueAccent,
                onChanged: (v) => setState(() => val = v),
                isDecimal: !isLuxToFStop,
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _calibrationChip('PLANO (C=250)', Photometry.incidentFlat),
                  const SizedBox(width: 8),
                  _calibrationChip('DOMO (C=340)', Photometry.incidentDome),
                ],
              ),
              const SizedBox(height: 30),
              _result(result),
            ],
          ),
        );
      },
    );
  }

  Widget _toggle() {
    return GestureDetector(
      onTap: () => setState(() {
        isLuxToFStop = !isLuxToFStop;
        val = isLuxToFStop ? 1000 : 4;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: OnSetColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLuxToFStop ? Icons.light_mode : Icons.camera,
              color: Colors.blueAccent,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              isLuxToFStop ? "A f-STOP" : "A LUX",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.swap_horiz, color: Colors.blueAccent, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _calibrationChip(String label, double value) {
    final active = calibration == value;
    return GestureDetector(
      onTap: () => setState(() => calibration = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? OnSetColors.surfaceHigh : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? Colors.white24 : Colors.white10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 1,
            color: active ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }

  Widget _result(double result) {
    final nearest = isLuxToFStop ? _nearestAperture(result) : null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: OnSetColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        children: [
          Text(
            isLuxToFStop ? "DIAFRAGMA" : "INTENSIDAD",
            style: const TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 1.5),
          ),
          Text(
            isLuxToFStop ? "f / ${result.toStringAsFixed(1)}" : "${result.toInt()} LX",
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w300,
              color: Colors.blueAccent,
            ),
          ),
          if (nearest != null)
            Text(
              'El diafragma más cercano es f/$nearest',
              style: const TextStyle(fontSize: 11, color: Colors.white38),
            ),
        ],
      ),
    );
  }

  double _nearestAperture(double v) {
    var best = CineData.apertures.first;
    var diff = double.infinity;
    for (final a in CineData.apertures) {
      final d = (a - v).abs();
      if (d < diff) {
        diff = d;
        best = a;
      }
    }
    return best;
  }
}

// -----------------------------------------------------------------
// HELPERS
// -----------------------------------------------------------------
Widget _planContext(ShotState shot) {
  return Text(
    'PLANO: ${shot.summary}',
    style: const TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 1),
  );
}

Widget _sectionLabel(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 9,
      color: Colors.white54,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
  );
}

Widget _hint(String text) {
  return Text(
    text,
    style: const TextStyle(fontSize: 10, color: Colors.white30, height: 1.4),
  );
}

Widget _legendDot(Color color, String label) {
  return Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 9, color: Colors.white38)),
    ],
  );
}

Widget _resultCard({
  required double stops,
  required String title,
  String? subtitle,
}) {
  final balanced = stops.abs() < 0.05;
  final accent = balanced
      ? OnSetColors.ok
      : (stops > 0 ? OnSetColors.brand : OnSetColors.danger);

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
    decoration: BoxDecoration(
      color: OnSetColors.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: accent, width: 1.5),
    ),
    child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.white38, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        Text(
          balanced ? 'OK' : '${stops > 0 ? '+' : ''}${stops.toStringAsFixed(1)} STOPS',
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: accent),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.white54, height: 1.4),
          ),
        ],
      ],
    ),
  );
}

Widget _dropdown(
  String label,
  double val,
  List<double> options,
  Function(double) onChanged, {
  bool isFstop = false,
  String prefix = '',
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionLabel(label),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: OnSetColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<double>(
            value: options.contains(val) ? val : options.first,
            isExpanded: true,
            dropdownColor: OnSetColors.surfaceHigh,
            items: options
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      isFstop ? "f/$e" : '$prefix${e.toString().replaceAll('.0', '')}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => onChanged(v!),
          ),
        ),
      ),
    ],
  );
}

Widget _manualInput(
  String label,
  double val,
  Function(double) onChanged, {
  String prefix = 'f/ ',
}) {
  return _ManualField(
    label: label,
    value: val,
    onChanged: onChanged,
    prefix: prefix,
  );
}

/// Campo numérico con su propio controlador: el anterior creaba uno nuevo en
/// cada build y perdía el cursor mientras se escribía.
class _ManualField extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;
  final String prefix;

  const _ManualField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.prefix = 'f/ ',
  });

  @override
  State<_ManualField> createState() => _ManualFieldState();
}

class _ManualFieldState extends State<_ManualField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value.toString());

  @override
  void didUpdateWidget(covariant _ManualField oldWidget) {
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
        _sectionLabel(widget.label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixText: widget.prefix,
              prefixStyle: const TextStyle(color: Colors.white54),
            ),
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

/// Lista de filtros o gelatinas aplicados, con la opción de agregar y quitar.
///
/// Se pueden apilar: un ND + polarizador delante del sensor, un CTO + difusión
/// delante de la fuente. Cada uno aporta sus pasos y el total se muestra aparte.
Widget _lossList({
  required List<(String, double)> items,
  required List<String> options,
  required String emptyText,
  required void Function(String) onAdd,
  required void Function(int) onRemove,
}) {
  final selected = items.map((i) => i.$1).toSet();
  final available = options.where((o) => !selected.contains(o)).toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (items.isEmpty)
        Text(
          emptyText,
          style: const TextStyle(fontSize: 10, color: Colors.white38),
        )
      else
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var i = 0; i < items.length; i++)
              _lossChip(items[i].$1, items[i].$2, () => onRemove(i)),
          ],
        ),
      if (available.isNotEmpty) ...[
        const SizedBox(height: 8),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: null,
              hint: const Text(
                '+ AGREGAR',
                style: TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 1),
              ),
              isExpanded: true,
              dropdownColor: OnSetColors.surfaceHigh,
              icon: const Icon(Icons.add, color: Colors.white38, size: 18),
              items: available
                  .map((o) => DropdownMenuItem(
                        value: o,
                        child: Text(
                          o,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) onAdd(v);
              },
            ),
          ),
        ),
      ],
    ],
  );
}

Widget _lossChip(String label, double stops, VoidCallback onRemove) {
  return GestureDetector(
    onTap: onRemove,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: OnSetColors.surface,
        border: Border.all(color: OnSetColors.danger.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
          const SizedBox(width: 8),
          Text(
            '−${stops.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 11,
              color: OnSetColors.danger,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.close, size: 12, color: Colors.white38),
        ],
      ),
    ),
  );
}

/// Aclara si la lectura del fotómetro ya incluye las gelatinas de la luz.
Widget _meterGelToggle(ShotState shot) {
  return GestureDetector(
    onTap: () => shot.setMeterIncludesGels(!shot.meterIncludesGels),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: shot.meterIncludesGels ? OnSetColors.surfaceHigh : Colors.transparent,
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(
            shot.meterIncludesGels ? Icons.check_box : Icons.check_box_outline_blank,
            size: 18,
            color: shot.meterIncludesGels ? OnSetColors.brand : Colors.white38,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LA LECTURA YA INCLUYE LAS GELATINAS',
                  style: TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                SizedBox(height: 3),
                Text(
                  'Si mediste con la gelatina puesta, no se vuelve a descontar.',
                  style: TextStyle(fontSize: 9, color: Colors.white38),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Pérdida total del plano, separada por familia.
Widget _lossTotal(ShotState shot) {
  final total = shot.lossStops;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.black,
      border: Border.all(color: total > 0 ? OnSetColors.danger : Colors.white12),
    ),
    child: Row(
      children: [
        const Text(
          'PÉRDIDA DE LUZ DEL PLANO',
          style: TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const Spacer(),
        Text(
          'cámara −${shot.filterStops.toStringAsFixed(1)} · luz −${shot.gelStops.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 9, color: Colors.white38),
        ),
        const SizedBox(width: 10),
        Text(
          total == 0 ? '0' : '−${total.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'monospace',
            color: total > 0 ? OnSetColors.danger : Colors.white38,
          ),
        ),
      ],
    ),
  );
}
