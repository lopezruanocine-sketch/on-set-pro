import 'package:flutter/material.dart';
import 'localization.dart';

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
            onTap: () => Future.microtask(() {
              if (!context.mounted) return;
              _showManualInput(context);
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

  void _showManualInput(BuildContext context) {
    TextEditingController ctrl = TextEditingController(text: isDecimal ? value.toStringAsFixed(1) : value.toInt().toString());
    showDialog(context: context, builder: (c) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text("${t('edit')} $label", style: TextStyle(color: color, fontSize: 14)),
      content: TextField(controller: ctrl, keyboardType: TextInputType.numberWithOptions(decimal: isDecimal), autofocus: true, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w300), decoration: InputDecoration(suffixText: unit, enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: color)))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("CANCEL", style: TextStyle(color: Colors.white38))),
        TextButton(onPressed: () { double? n = double.tryParse(ctrl.text); if (n != null) onChanged(n); Navigator.pop(c); }, child: Text("OK", style: TextStyle(color: color, fontWeight: FontWeight.bold))),
      ],
    ));
  }
}