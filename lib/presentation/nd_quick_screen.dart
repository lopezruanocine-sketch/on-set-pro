import 'package:flutter/material.dart';

import '../core/cine_data.dart';
import '../data/catalogs/camera_filters.dart';
import '../domain/core/units.dart';
import '../theme/app_theme.dart';

/// Compensación rápida con ND: qué filtro hace falta para volver al diafragma.
class NdQuickScreen extends StatefulWidget {
  const NdQuickScreen({super.key});

  @override
  State<NdQuickScreen> createState() => _NdQuickScreenState();
}

class _NdQuickScreenState extends State<NdQuickScreen> {
  double baseAperture = 5.6;
  double desiredAperture = 2.8;
  double fps = 24;
  double shutterAngle = 180;

  @override
  Widget build(BuildContext context) {
    final seconds = Units.shutterSeconds(angleDegrees: shutterAngle, fps: fps);
    // Pasos entre el diafragma que da la luz y el que queremos usar.
    final stops = 2 * DMath.log2(baseAperture / desiredAperture);
    final nd = stops > 0 ? CameraFilters.closestNd(stops) : null;
    final error = nd == null ? 0.0 : (nd.stops - stops).abs();

    return Scaffold(
      backgroundColor: OnSetColors.background,
      appBar: AppBar(
        backgroundColor: OnSetColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'ND RÁPIDO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _resultCard(stops, nd, error),
            const SizedBox(height: 30),
            _apertureRow(),
            const SizedBox(height: 15),
            _section('OBTURADOR DEL PLANO'),
            Row(
              children: [
                Expanded(
                  child: _numberInput('FPS', fps, (v) => setState(() => fps = v)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _numberInput('ÁNGULO (°)', shutterAngle, (v) => setState(() => shutterAngle = v)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Equivale a 1/${(1 / seconds).toStringAsFixed(0)} s',
              style: const TextStyle(fontSize: 10, color: Colors.white38),
            ),
            const SizedBox(height: 30),
            _section('OTRAS OPCIONES'),
            ..._alternatives(stops),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(double stops, CameraFilter? nd, double error) {
    final color = stops <= 0.05
        ? OnSetColors.ok
        : (error <= 0.35 ? OnSetColors.brand : OnSetColors.power);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'PARA VOLVER A TU DIAFRAGMA',
            style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          Text(
            stops <= 0.05 ? 'NINGUNO' : (nd == null ? '—' : nd.name.split(' — ').first),
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontSize: 40, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 8),
          Text(
            stops <= 0.05
                ? 'El diafragma elegido ya es el que da la luz.'
                : 'Hay ${stops.toStringAsFixed(1)} pasos de más: el filtro tiene que quitar '
                    '${stops.toStringAsFixed(1)}. ${error > 0.35 ? 'El ND más cercano deja ${error.toStringAsFixed(1)} de diferencia.' : ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.white54, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _apertureRow() {
    return Row(
      children: [
        Expanded(child: _aperture('SIN ND, LA LUZ DA', baseAperture, (v) => setState(() => baseAperture = v))),
        const SizedBox(width: 12),
        Expanded(child: _aperture('QUIERO USAR', desiredAperture, (v) => setState(() => desiredAperture = v))),
      ],
    );
  }

  Widget _aperture(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section(label),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<double>(
              value: CineData.apertures.contains(value) ? value : null,
              isExpanded: true,
              dropdownColor: OnSetColors.surfaceHigh,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: CineData.apertures
                  .map((a) => DropdownMenuItem(
                        value: a,
                        child: Text('f/$a', style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ))
                  .toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _alternatives(double stops) {
    final options = <String>[];
    if (stops > 0.05) {
      // Sin filtro, qué diafragma queda con lo que hay de luz.
      options.add('Sin ND: cerrá a f/${baseAperture.toStringAsFixed(1)}');
      options.add('O bajá la luz ${stops.toStringAsFixed(1)} pasos');
      options.add('O poné el ND completo y ajustá con el diafragma');
    } else {
      options.add('No hace falta filtro');
    }
    return options
        .take(2)
        .map((text) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: OnSetColors.surface,
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ),
            ))
        .toList();
  }

  Widget _section(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      );

  Widget _numberInput(String label, double value, Function(double) onChanged) {
    return _NdField(label: label, value: value, onChanged: onChanged);
  }
}

class _NdField extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;

  const _NdField({required this.label, required this.value, required this.onChanged});

  @override
  State<_NdField> createState() => _NdFieldState();
}

class _NdFieldState extends State<_NdField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value.toString());

  @override
  void didUpdateWidget(covariant _NdField oldWidget) {
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
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            border: Border.all(color: Colors.white24),
          ),
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'monospace'),
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (v) {
              final n = double.tryParse(v);
              if (n != null) widget.onChanged(n);
            },
          ),
        ),
      ],
    );
  }
}
