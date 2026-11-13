import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/distro_presets.dart';
import '../../domain/power/distro.dart';
import '../../domain/power/power_engine.dart';
import '../../theme/app_theme.dart';

/// Reparto de cargas en una distro trifásica.
///
/// Vive como pestaña dentro de Electricidad: es la misma pregunta
/// (¿cuánta corriente tengo?) con varias cargas repartidas en fases.
class DistroPanel extends StatefulWidget {
  /// Tensión entre fases del soporte elegido en la otra pestaña.
  final double voltage;

  /// Monofásico o trifásico: define la tensión con la que se calcula cada fase.
  final Phases phases;

  /// Corriente que el soporte aguanta por fase. `null` = todavía no hay dato.
  final double? limitAmps;

  /// Texto que explica de dónde sale ese límite.
  final String sourceLabel;

  const DistroPanel({
    super.key,
    required this.voltage,
    required this.phases,
    required this.limitAmps,
    required this.sourceLabel,
  });

  @override
  State<DistroPanel> createState() => _DistroPanelState();
}

class _DistroPanelState extends State<DistroPanel> {
  /// Arranca vacío: la distro se arma con lo que hay en el camión, y los
  /// watts son el único dato que la app necesita. No hace falta un catálogo
  /// de luces: cambia todos los años y nunca está completo.
  final List<_DistroLoad> loads = [];
  String? selectedPreset;

  @override
  void initState() {
    super.initState();
    DistroPresets.instance.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  double get limitAmps => widget.limitAmps ?? 0;

  /// Tensión a la que trabaja cada carga: en trifásico es la de fase,
  /// en monofásico es la de red.
  double get phaseVoltage => widget.phases == Phases.three
      ? widget.voltage / math.sqrt(3)
      : widget.voltage;

  @override
  Widget build(BuildContext context) {
    final plan = DistroEngine.distribute(
      loads: [
        for (final l in loads)
          Load(name: l.name, watts: l.watts, phase: l.phase),
      ],
      voltage: widget.voltage,
      limitAmps: limitAmps,
    );
    final imbalance = DistroEngine.imbalancePercent(plan.phaseWatts);

    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _supportStrip(),
            const SizedBox(height: 12),
            _presetBar(),
            const SizedBox(height: 14),
            _summary(plan, imbalance),
            const SizedBox(height: 18),
            _phases(plan),
            const SizedBox(height: 22),
            _section('CARGAS'),
            if (loads.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Cargá las luminarias con sus watts (los que dice la lámpara o el '
                  'balasto). La app reparte sola: cada carga va a la fase más liviana.',
                  style: const TextStyle(fontSize: 10, color: Colors.white38, height: 1.4),
                ),
              ),
            ..._loadRows(plan),
            const SizedBox(height: 10),
            _addLoad(),
            if (loads.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GestureDetector(
                  onTap: () => setState(() {
                    loads.addAll([
                      _DistroLoad(name: '2 kW (HMI)', watts: 2000),
                      _DistroLoad(name: '2 kW (HMI)', watts: 2000),
                      _DistroLoad(name: 'Panel LED', watts: 900),
                      _DistroLoad(name: 'Panel LED', watts: 900),
                      _DistroLoad(name: 'LED chico', watts: 200),
                    ]);
                  }),
                  child: const Text(
                    'CARGAR UN EJEMPLO',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 9,
                      color: OnSetColors.power,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 22),
            const SizedBox(height: 8),
            Text(
              imbalance < 15
                  ? 'Desbalance ${imbalance.toStringAsFixed(0)} %: bien repartido.'
                  : 'Desbalance ${imbalance.toStringAsFixed(0)} %: el neutro trabaja de más. '
                      'Movés una carga de la fase ${plan.heaviestPhase} a la más liviana.',
              style: TextStyle(
                fontSize: 10,
                height: 1.4,
                color: imbalance < 15 ? OnSetColors.ok : OnSetColors.power,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'La corriente se calcula con la tensión de fase (tensión / √3) porque cada '
              'luminaria va entre fase y neutro. El reparto no corrige térmicas ni cables: '
              'eso se revisa en la otra pestaña.',
              style: TextStyle(fontSize: 9, color: Colors.white38, height: 1.4),
            ),
          ],
        ),
    );
  }

  /// Límite que viene del soporte elegido en CIRCUITO: una sola fuente de
  /// verdad para el tablero, el generador o la batería.
  Widget _supportStrip() {
    final limit = widget.limitAmps;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: limit == null ? Colors.white12 : OnSetColors.power),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, size: 14, color: OnSetColors.power),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              limit == null
                  ? 'Elegí el soporte en CIRCUITO para tener el límite por fase.'
                  : '${widget.sourceLabel} · ${widget.voltage.toStringAsFixed(0)} V · '
                      'límite ${limit.toStringAsFixed(1)} A',
              style: TextStyle(
                fontSize: 10,
                height: 1.3,
                color: limit == null ? Colors.white38 : Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Repartos guardados: cargar uno, guardar el actual o borrar.
  Widget _presetBar() {
    final presets = DistroPresets.instance.presets;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: OnSetColors.surface,
              border: Border.all(color: Colors.white24),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: presets.any((p) => p.id == selectedPreset) ? selectedPreset : null,
                hint: const Text(
                  'CARGAR UN REPARTO',
                  style: TextStyle(fontSize: 9, color: Colors.white38, letterSpacing: 1),
                ),
                isExpanded: true,
                dropdownColor: OnSetColors.surfaceHigh,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
                items: presets
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            '${p.name}  ·  ${p.totalWatts.toStringAsFixed(0)} W',
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ))
                    .toList(),
                onChanged: (id) {
                  if (id == null) return;
                  final preset = presets.firstWhere((p) => p.id == id);
                  setState(() {
                    selectedPreset = id;
                    loads
                      ..clear()
                      ..addAll(preset.loads.map(
                        (l) => _DistroLoad(name: l.name, watts: l.watts, phase: l.phase),
                      ));
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: loads.isEmpty ? null : _savePreset,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: loads.isEmpty ? Colors.white12 : OnSetColors.power),
            ),
            child: Text(
              'GUARDAR',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
                color: loads.isEmpty ? Colors.white24 : OnSetColors.power,
              ),
            ),
          ),
        ),
        if (selectedPreset != null) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _deletePreset,
            child: Container(
              height: 40,
              width: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(border: Border.all(color: Colors.white12)),
              child: const Icon(Icons.delete_outline, size: 16, color: Colors.white38),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _savePreset() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OnSetColors.surface,
        title: const Text('Guardar reparto', style: TextStyle(fontSize: 15, color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Ej: entrevista 2 puntos',
            hintStyle: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text(
              'GUARDAR',
              style: TextStyle(color: OnSetColors.power, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (name == null) return;
    final preset = await DistroPresets.instance.save(
      name: name,
      loads: [
        for (final l in loads) PresetLoad(name: l.name, watts: l.watts, phase: l.phase),
      ],
    );
    if (!mounted) return;
    setState(() => selectedPreset = preset.id);
  }

  Future<void> _deletePreset() async {
    final id = selectedPreset;
    if (id == null) return;
    await DistroPresets.instance.delete(id);
    if (!mounted) return;
    setState(() => selectedPreset = null);
  }

  Widget _summary(DistroPlan plan, double imbalance) {
    final color = plan.isOverloaded ? OnSetColors.danger : (imbalance > 15 ? OnSetColors.power : OnSetColors.ok);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.isOverloaded ? 'SOBRECARGA EN LA FASE ${plan.heaviestPhase}' : 'DISTRO BALANCEADA',
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            '${plan.maxPhaseAmps.toStringAsFixed(1)} A en la fase más cargada · '
            'límite ${limitAmps.toStringAsFixed(0)} A',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            '${plan.phaseWatts.fold<double>(0, (a, b) => a + b).toStringAsFixed(0)} W totales · '
            '${plan.assigned.length} cargas',
            style: const TextStyle(fontSize: 11, color: Colors.white38),
          ),
          if (plan.assigned.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'La más pesada fue a la fase más liviana: así el neutro no se carga '
              'de más. Si una carga tiene que ir sí o sí en una fase, la podés '
              'mover tocando su número de fase.',
              style: TextStyle(
                fontSize: 9,
                height: 1.4,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _phases(DistroPlan plan) {
    const names = ['FASE 1', 'FASE 2', 'FASE 3'];
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        names[i],
                        style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: (plan.phaseAmps[i] / (limitAmps == 0 ? 1 : limitAmps)).clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: Colors.white10,
                          color: plan.phaseAmps[i] > limitAmps ? OnSetColors.danger : OnSetColors.power,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 92,
                      child: Text(
                        '${plan.phaseAmps[i].toStringAsFixed(1)} A · ${plan.phaseWatts[i].toStringAsFixed(0)} W',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 10, color: Colors.white70, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> _loadRows(DistroPlan plan) {
    // Asignación final después del reparto: la manual manda.
    final assignedPhase = <int, int>{};
    for (var i = 0; i < plan.assigned.length; i++) {
      final p = plan.assigned[i].phase;
      if (p != null) assignedPhase[i] = p;
    }

    final perVoltage = phaseVoltage;
    final perPhaseLimit = limitAmps;

    return [
      for (var i = 0; i < loads.length; i++)
        _loadRow(i, assignedPhase[i], perVoltage, perPhaseLimit),
    ];
  }

  Widget _loadRow(int index, int? effectivePhase, double phaseVoltage, double perPhaseLimit) {
    final load = loads[index];
    final manual = load.phase != null;
    // Una sola carga que ya no entra en una fase, ni repartida.
    final tooBig = perPhaseLimit > 0 && load.watts / phaseVoltage > perPhaseLimit;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: OnSetColors.surface,
          border: Border.all(
            color: tooBig ? OnSetColors.danger : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            // La fase se toca para moverla a mano o volver a automático.
            GestureDetector(
              onTap: () => _cyclePhase(index),
              child: Container(
                width: 46,
                padding: const EdgeInsets.symmetric(vertical: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: manual ? OnSetColors.surfaceHigh : Colors.transparent,
                  border: Border.all(
                    color: tooBig
                        ? OnSetColors.danger
                        : (manual ? OnSetColors.power : Colors.white12),
                  ),
                ),
                child: Text(
                  manual ? 'F${load.phase! + 1}' : 'AUTO',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: tooBig
                        ? OnSetColors.danger
                        : (manual ? Colors.white : Colors.white38),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _editLoad(index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      load.name,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tooBig
                          ? 'No entra en una fase: ${(load.watts / phaseVoltage).toStringAsFixed(1)} A'
                          : '${effectivePhase == null ? '' : 'Fase ${effectivePhase + 1} · '}tocar para editar',
                      style: TextStyle(
                        fontSize: 8,
                        color: tooBig ? OnSetColors.danger : Colors.white24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 62,
              child: Text(
                '${load.watts.toStringAsFixed(0)} W',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white54,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _duplicateLoad(index),
              child: const Icon(Icons.copy, size: 13, color: Colors.white24),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => loads.removeAt(index)),
              child: const Icon(Icons.close, size: 14, color: Colors.white24),
            ),
          ],
        ),
      ),
    );
  }

  /// Copia una carga: lo habitual es tener dos luminarias iguales.
  void _duplicateLoad(int index) {
    final original = loads[index];
    setState(() {
      loads.insert(
        index + 1,
        _DistroLoad(name: original.name, watts: original.watts),
      );
    });
  }

  /// AUTO → F1 → F2 → F3 → AUTO: mover una carga de fase con un toque.
  void _cyclePhase(int index) {
    setState(() {
      final current = loads[index].phase;
      loads[index].phase = current == null ? 0 : (current >= 2 ? null : current + 1);
    });
  }

  /// Edita nombre y watts de una carga sin borrarla y volver a crearla.
  Future<void> _editLoad(int index) async {
    final load = loads[index];
    final nameController = TextEditingController(text: load.name);
    final wattsController = TextEditingController(text: load.watts.toStringAsFixed(0));

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OnSetColors.surface,
        title: const Text('Editar carga', style: TextStyle(fontSize: 15, color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Qué está conectado',
                labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: wattsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Watts',
                labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'GUARDAR',
              style: TextStyle(color: OnSetColors.power, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (saved != true) return;
    final watts = double.tryParse(wattsController.text);
    if (watts == null || watts <= 0) return;
    setState(() {
      load.name = nameController.text.trim().isEmpty ? 'Carga' : nameController.text.trim();
      load.watts = watts;
    });
  }

  Widget _addLoad() {
    final nameController = TextEditingController();
    final wattsController = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.white12)),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Qué está conectado',
                hintStyle: TextStyle(color: Colors.white24, fontSize: 11),
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: wattsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Watts',
                hintStyle: TextStyle(color: Colors.white24, fontSize: 11),
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: OnSetColors.power, size: 20),
            onPressed: () {
              final watts = double.tryParse(wattsController.text);
              if (watts == null || watts <= 0) return;
              setState(() {
                loads.add(_DistroLoad(
                  name: nameController.text.trim().isEmpty ? 'Carga' : nameController.text.trim(),
                  watts: watts,
                ));
              });
              nameController.clear();
              wattsController.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _section(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
      );
}

class _DistroLoad {
  String name;
  double watts;

  /// Fase elegida a mano (0, 1, 2). `null` = que la app la reparta.
  int? phase;

  _DistroLoad({required this.name, required this.watts, this.phase});
}

class _DistroField extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;

  const _DistroField({required this.label, required this.value, required this.onChanged});

  @override
  State<_DistroField> createState() => _DistroFieldState();
}

class _DistroFieldState extends State<_DistroField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value.toString());

  @override
  void didUpdateWidget(covariant _DistroField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (double.tryParse(_controller.text) != widget.value) {
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
          style: const TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            border: Border.all(color: Colors.white24),
          ),
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'monospace'),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
            onChanged: (v) {
              final n = double.tryParse(v);
              if (n != null && n > 0) widget.onChanged(n);
            },
          ),
        ),
      ],
    );
  }
}
