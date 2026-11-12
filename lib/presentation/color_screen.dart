import 'package:flutter/material.dart';

import '../data/catalogs/light_gels.dart';
import '../domain/color/color_engine.dart';
import '../domain/color/gel_advisor.dart';
import '../theme/app_theme.dart';

/// Temperatura y gelatinas: cuánto corrimiento hace falta y con qué gel.
class ColorScreen extends StatefulWidget {
  const ColorScreen({super.key});

  @override
  State<ColorScreen> createState() => _ColorScreenState();
}

class _ColorScreenState extends State<ColorScreen> {
  double sourceK = 3200;
  double targetK = 5600;
  String tint = 'normal';

  @override
  Widget build(BuildContext context) {
    final shift = ColorEngine.shiftTo(sourceKelvin: sourceK, targetKelvin: targetK);
    final options = GelAdvisor.recommend(
      sourceKelvin: sourceK,
      targetKelvin: targetK,
      limit: 3,
    );
    final best = options.isEmpty ? null : options.first;
    final tintGel = _tintGel();

    return Scaffold(
      backgroundColor: OnSetColors.background,
      appBar: AppBar(
        backgroundColor: OnSetColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'COLOR Y GELES',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            fontSize: 14,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _resultCard(shift, best),
            const SizedBox(height: 30),
            _sectionTitle('1. BALANCE DE TEMPERATURA'),
            _presetRow('FUENTE', [
              ('TUNGSTENO 3200', sourceK == 3200, () => setState(() => sourceK = 3200)),
              ('DIURNO 5600', sourceK == 5600, () => setState(() => sourceK = 5600)),
              ('HMI 6000', sourceK == 6000, () => setState(() => sourceK = 6000)),
              ('LED 6500', sourceK == 6500, () => setState(() => sourceK = 6500)),
            ]),
            _kelvinSlider('FOCO EN SET (ORIGEN)', sourceK, (v) => setState(() => sourceK = v), OnSetColors.power),
            const SizedBox(height: 10),
            const Text(
              'CÁMARA (OBJETIVO)',
              style: TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _presetRow('', [
              ('3200', targetK == 3200, () => setState(() => targetK = 3200)),
              ('4300', targetK == 4300, () => setState(() => targetK = 4300)),
              ('5600', targetK == 5600, () => setState(() => targetK = 5600)),
            ]),
            _kelvinSlider('OBJETIVO', targetK, (v) => setState(() => targetK = v), Colors.white),
            const SizedBox(height: 25),
            _sectionTitle('2. CORRECCIÓN DE TINTE'),
            _tintSelector(),
            if (tintGel != null) ...[
              const SizedBox(height: 12),
              _tintResult(tintGel),
            ],
            if (best != null) ...[
              const SizedBox(height: 25),
              _alternatives(options.skip(1).toList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _resultCard(ColorShift shift, GelMatch? best) {
    final mired = shift.shiftMired;
    final color = mired.abs() < 3
        ? OnSetColors.ok
        : (mired > 0 ? OnSetColors.power : Colors.blueAccent);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'DESFASE TÉRMICO (MIREDS)',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mired.abs() < 3 ? '0' : '${mired > 0 ? '+' : ''}${mired.toInt()}',
            style: TextStyle(
              color: color,
              fontSize: 48,
              fontWeight: FontWeight.w300,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mired.abs() < 3
                ? 'La fuente ya coincide con la cámara.'
                : (mired > 0
                    ? 'La fuente es más fría: hay que calentarla.'
                    : 'La fuente es más cálida: hay que enfriarla.'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.white54),
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            'GEL RECOMENDADA',
            style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 6),
          Text(
            best == null ? 'NINGUNA' : best.gel.label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: best == null ? Colors.white : OnSetColors.brand,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          if (best != null) ...[
            const SizedBox(height: 6),
            Text(
              'Queda en ${best.resultingKelvin.toStringAsFixed(0)} K · '
              'error ${best.errorMired.toStringAsFixed(0)} mireds · '
              'pierde ${best.gel.stops.toStringAsFixed(2)} stops',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.white38),
            ),
          ],
        ],
      ),
    );
  }

  Widget _alternatives(List<GelMatch> options) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('OTRAS OPCIONES'),
        ...options.map(
          (o) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: OnSetColors.surface,
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      o.gel.label,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  Text(
                    '${o.resultingKelvin.toStringAsFixed(0)} K',
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tintSelector() {
    const options = [
      ('greenStrong', 'MUY VERDE'),
      ('greenLight', 'ALGO VERDE'),
      ('normal', 'LIMPIA'),
      ('magentaLight', 'ALGO MAGENTA'),
      ('magentaStrong', 'MUY MAGENTA'),
    ];
    return Container(
      height: 44,
      decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
      child: Row(
        children: options.map((o) {
          final selected = tint == o.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => tint = o.$1),
              child: Container(
                color: selected ? OnSetColors.surfaceHigh : Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  o.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _tintResult(LightGel gel) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OnSetColors.surface,
        border: Border.all(color: OnSetColors.power),
      ),
      child: Row(
        children: [
          const Text(
            'PARA EL TINTE',
            style: TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            gel.label,
            style: const TextStyle(fontSize: 13, color: OnSetColors.power, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            '${gel.stops.toStringAsFixed(2)} st',
            style: const TextStyle(fontSize: 10, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  LightGel? _tintGel() {
    switch (tint) {
      case 'greenStrong':
        return LightGels.byCode('Lee', '247');
      case 'greenLight':
        return LightGels.byCode('Lee', '249');
      case 'magentaLight':
        return LightGels.byCode('Lee', '246');
      case 'magentaStrong':
        return LightGels.byCode('Lee', '244');
      default:
        return null;
    }
  }

  Widget _presetRow(String label, List<(String, bool, VoidCallback)> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: items
              .map((i) => Expanded(
                    child: GestureDetector(
                      onTap: i.$3,
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: i.$2 ? OnSetColors.surfaceHigh : Colors.transparent,
                          border: Border.all(color: i.$2 ? Colors.white24 : Colors.white10),
                        ),
                        child: Text(
                          i.$1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: i.$2 ? Colors.white : Colors.white38,
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _kelvinSlider(String label, double value, Function(double) onChanged, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold),
              ),
              Text(
                '${value.toStringAsFixed(0)} K',
                style: TextStyle(fontSize: 14, color: color, fontFamily: 'monospace'),
              ),
            ],
          ),
          Slider(
            value: value.clamp(2000, 10000),
            min: 2000,
            max: 10000,
            divisions: 80,
            activeColor: color,
            inactiveColor: Colors.white10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      );
}
