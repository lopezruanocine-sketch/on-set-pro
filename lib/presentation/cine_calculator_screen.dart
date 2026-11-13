import 'package:flutter/material.dart';

import '../domain/calculator/cine_math.dart';
import '../theme/app_theme.dart';

/// Abre la calculadora de cine y devuelve el número elegido.
///
/// Se puede llamar desde cualquier campo: si se pasa [initial], la calculadora
/// arranca con ese valor para seguir sumando o invertirlo.
Future<double?> showCineCalculator(
  BuildContext context, {
  double? initial,
  String title = 'CALCULADORA',
}) {
  return Navigator.of(context).push<double>(
    MaterialPageRoute(
      builder: (_) => CineCalculatorScreen(initial: initial, title: title),
    ),
  );
}

/// Calculadora de cine: trabaja en pasos, fracciones e inversas.
class CineCalculatorScreen extends StatefulWidget {
  final double? initial;
  final String title;

  const CineCalculatorScreen({
    super.key,
    this.initial,
    this.title = 'CALCULADORA',
  });

  @override
  State<CineCalculatorScreen> createState() => _CineCalculatorScreenState();
}

class _CineCalculatorScreenState extends State<CineCalculatorScreen> {
  String expression = '';
  bool treatAsTime = false;

  CalcResult? get result => CineMath.evaluate(expression, treatAsTime: treatAsTime);

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      expression = CineMath.formatNumber(initial);
    }
  }

  void _tap(String value) {
    setState(() {
      switch (value) {
        case 'C':
          expression = '';
        case '⌫':
          if (expression.isNotEmpty) {
            expression = expression.substring(0, expression.length - 1);
          }
        case '1/x':
          // Dos casos: invertir lo evaluado (48 → 1/48) o invertir el número
          // que se está escribiendo (48 → 1/48).
          final current = result;
          if (current == null || current.value == 0) break;
          final typed = double.tryParse(expression);
          expression = '1/${CineMath.formatNumber(typed ?? current.value)}';
          treatAsTime = true;
        default:
          expression += value;
      }
    });
  }

  void _use() {
    final r = result;
    if (r == null) return;
    Navigator.of(context).pop(r.value);
  }

  @override
  Widget build(BuildContext context) {
    final r = result;
    return Scaffold(
      backgroundColor: OnSetColors.background,
      appBar: AppBar(
        backgroundColor: OnSetColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: r == null ? null : _use,
            child: const Text(
              'USAR',
              style: TextStyle(color: OnSetColors.brand, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      expression.isEmpty ? '0' : expression,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 20,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      r?.display ?? '—',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 46,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  if (r?.shutterFraction != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _timeInfo(r!),
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: OnSetColors.brand, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _toggles(),
          ),
          const SizedBox(height: 6),
          Expanded(child: _keypad()),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _timeInfo(CalcResult r) {
    final parts = <String>['= 1/${r.shutterFraction!.toStringAsFixed(0)} s'];
    final stops = r.stopsFrom48;
    if (stops != null && stops.abs() > 0.02) {
      parts.add('${stops > 0 ? '+' : ''}${stops.toStringAsFixed(2)} pasos vs 1/48');
    }
    return parts.join('   ·   ');
  }

  Widget _toggles() {
    return Row(
      children: [
        Expanded(
          child: _chip(
            'MOSTRAR COMO TIEMPO (1/x, pasos)',
            treatAsTime,
            () => setState(() => treatAsTime = !treatAsTime),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap, {bool enabled = true}) {
    return Opacity(
      opacity: enabled ? 1 : 0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? OnSetColors.surfaceHigh : Colors.transparent,
            border: Border.all(color: active ? OnSetColors.brand : Colors.white24),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8,
              letterSpacing: 0.5,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _keypad() {
    // La altura disponible se reparte entre las filas: en un iPhone chico
    // las teclas se achican pero nunca quedan fuera de pantalla.
    // Cada tecla lleva 8 px de separación (4 arriba y 4 abajo) y no puede
    // bajar de un tamaño cómodo: si no entra, se hace scroll en vez de cortarse.
    return LayoutBuilder(
      builder: (context, constraints) {
        const rows = 6;
        final available = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 6 * 58.0;
        final keyHeight = ((available - rows * 8) / rows).clamp(30.0, 58.0);
        // Sin scroll y sin desbordar: las teclas se adaptan a lo que hay.
        return _keypadRows(keyHeight, totalHeight: keyHeight * rows + rows * 8);
      },
    );
  }

  Widget _keypadRows(double keyHeight, {required double totalHeight}) {
    const keys = [
      ['(', ')', '^', '⌫'],
      ['7', '8', '9', '÷'],
      ['4', '5', '6', '×'],
      ['1', '2', '3', '-'],
      ['0', '.', '1/x', '+'],
    ];
    const bottom = ['C', '=', '', ''];

    // Cada celda es flexible en ancho y toma el alto de su fila: seis filas
    // configuradas con Expanded llenan el espacio disponible sin salirse.
    Widget cell(Widget child, {int flex = 1}) => Expanded(
          flex: flex,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: child,
          ),
        );

    Widget buildRow(List<String> rowKeys) => Expanded(
          child: Row(
            children: [
              for (final k in rowKeys)
                if (k.isEmpty)
                  cell(const SizedBox())
                else if (k == '=')
                  cell(_key(k, accent: true, tight: true), flex: 3)
                else if (k == 'C')
                  cell(_key(k, danger: true, tight: true))
                else
                  cell(_key(k, tight: true)),
            ],
          ),
        );

    return Column(
      children: [
        for (final row in keys) buildRow(row),
        buildRow(bottom),
      ],
    );
  }

  Widget _key(
    String label, {
    bool accent = false,
    bool danger = false,
    double height = 56,
    bool tight = false,
  }) {
    const operators = {'+', '-', '×', '÷', '^', '(', ')', '⌫', '1/x'};
    final isOperator = operators.contains(label);
    final color = accent
        ? OnSetColors.brand
        : danger
            ? OnSetColors.danger
            : (isOperator ? Colors.white70 : Colors.white);
    // En el teclado el alto es el de la celda (con su relleno): si se suma el
    // relleno dos veces, las seis filas no entran en un teléfono.
    final box = Container(
      // En el teclado la altura la impone la celda; fuera de él, se fija.
      height: tight ? null : height,
      alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent ? OnSetColors.brand.withValues(alpha: 0.15) : OnSetColors.surface,
          border: Border.all(color: accent ? OnSetColors.brand : Colors.white12),
        ),
      child: Text(
        label,
        style: TextStyle(
          color: accent ? OnSetColors.brand : color,
          fontSize: label.length > 1 ? 16 : 22,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w300,
        ),
      ),
    );
    return GestureDetector(onTap: () => _tap(label), child: box);
  }
}
