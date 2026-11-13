import 'package:flutter/material.dart';
import '../presentation/cine_calculator_screen.dart';

class ProInput extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final Color color;
  final Function(double) onChanged;
  final bool isDecimal;

  const ProInput({
    super.key, required this.label, required this.value, required this.min, required this.max,
    this.unit = "", required this.color, required this.onChanged, this.isDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, color: Colors.white38, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
          GestureDetector(
            onTap: () => Future.microtask(() async {
              if (!context.mounted) return;
              // Un toque abre la calculadora con el valor actual: se puede
              // escribir un número o hacer una cuenta (1/48, 3*24).
              final picked = await showCineCalculator(
                context,
                initial: value,
                title: label.toUpperCase(),
              );
              if (picked != null) onChanged(picked);
            }),
            child: Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
              Text(isDecimal ? value.toStringAsFixed(1) : value.toInt().toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: color, fontFamily: 'monospace')),
              const SizedBox(width: 4), 
              Text(unit, style: const TextStyle(fontSize: 12, color: Colors.white30))
            ]),
          ),
        ]),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color, 
            inactiveTrackColor: Colors.white10,
            thumbColor: Colors.white,
            overlayColor: color.withValues(alpha: 0.1), // Actualizado para evitar warnings
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(value: value.clamp(min, max), min: min, max: max, divisions: isDecimal ? ((max - min) * 10).toInt() : (max - min).toInt(), onChanged: onChanged),
        ),
      ]),
    );
  }
}
