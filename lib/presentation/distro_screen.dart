import 'package:flutter/material.dart';

import '../domain/power/distro.dart';
import '../theme/app_theme.dart';

/// Reparto de cargas en una distro trifásica.
class DistroScreen extends StatefulWidget {
  const DistroScreen({super.key});

  @override
  State<DistroScreen> createState() => _DistroScreenState();
}

class _DistroScreenState extends State<DistroScreen> {
  final List<_DistroLoad> loads = [
    _DistroLoad(name: 'M18', watts: 1800),
    _DistroLoad(name: 'M18', watts: 1800),
    _DistroLoad(name: 'Skypanel S60', watts: 900),
    _DistroLoad(name: 'Skypanel S60', watts: 900),
    _DistroLoad(name: 'LED panel', watts: 200),
  ];
  double voltage = 380;
  double limitAmps = 32;

  @override
  Widget build(BuildContext context) {
    final plan = DistroEngine.distribute(
      loads: [for (final l in loads) Load(name: l.name, watts: l.watts)],
      voltage: voltage,
      limitAmps: limitAmps,
    );
    final imbalance = DistroEngine.imbalancePercent(plan.phaseWatts);

    return Scaffold(
      backgroundColor: OnSetColors.background,
      appBar: AppBar(
        backgroundColor: OnSetColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'DISTRO ELÉCTRICA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _summary(plan, imbalance),
            const SizedBox(height: 18),
            _phases(plan),
            const SizedBox(height: 22),
            _section('CARGAS'),
            ..._loadRows(plan),
            const SizedBox(height: 10),
            _addLoad(),
            const SizedBox(height: 22),
            _settings(),
            const SizedBox(height: 18),
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
              'La corriente se calcula con la tensión de fase (${"tensión"} / √3) porque cada '
              'luminaria va entre fase y neutro. El reparto no corrige térmicas ni cables: '
              'eso se revisa en Electricidad.',
              style: TextStyle(fontSize: 9, color: Colors.white38, height: 1.4),
            ),
          ],
        ),
      ),
    );
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
    final phasesByName = <String, int>{};
    for (final a in plan.assigned) {
      if (a.phase != null) phasesByName['${a.name}-${a.watts}'] = a.phase!;
    }
    return [
      for (var i = 0; i < loads.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: OnSetColors.surface,
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Text(
                    'F${(phasesByName['${loads[i].name}-${loads[i].watts}'] ?? 0) + 1}',
                    style: const TextStyle(fontSize: 10, color: OnSetColors.power, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    loads[i].name,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    '${loads[i].watts.toStringAsFixed(0)} W',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 11, color: Colors.white54, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => setState(() => loads.removeAt(i)),
                  child: const Icon(Icons.close, size: 14, color: Colors.white24),
                ),
              ],
            ),
          ),
        ),
    ];
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
                hintText: 'M18',
                hintStyle: TextStyle(color: Colors.white24, fontSize: 12),
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
                hintText: '1800 W',
                hintStyle: TextStyle(color: Colors.white24, fontSize: 12),
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

  Widget _settings() {
    return Row(
      children: [
        Expanded(child: _numField('TENSIÓN ENTRE FASES (V)', voltage, (v) => setState(() => voltage = v))),
        const SizedBox(width: 12),
        Expanded(child: _numField('LÍMITE POR FASE (A)', limitAmps, (v) => setState(() => limitAmps = v))),
      ],
    );
  }

  Widget _numField(String label, double value, Function(double) onChanged) {
    return _DistroField(label: label, value: value, onChanged: onChanged);
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
  final String name;
  final double watts;

  const _DistroLoad({required this.name, required this.watts});
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
