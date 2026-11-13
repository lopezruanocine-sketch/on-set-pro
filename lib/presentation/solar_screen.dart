import 'package:flutter/material.dart';

import '../domain/astro/solar_calculator.dart';
import '../theme/app_theme.dart';

/// Planificador de luz solar: cuándo hay azul, cuándo hay dorada y dónde está
/// el sol. Funciona sin internet: sólo necesita el lugar.
class SolarScreen extends StatefulWidget {
  const SolarScreen({super.key});

  @override
  State<SolarScreen> createState() => _SolarScreenState();
}

class _SolarScreenState extends State<SolarScreen> {
  double latitude = -34.6037;
  double longitude = -58.3816;
  double utcOffsetHours = -3;
  DateTime day = DateTime.now();

  static const _places = {
    'BUENOS AIRES': (-34.6037, -58.3816, -3.0),
    'CÓRDOBA (AR)': (-31.4201, -64.1888, -3.0),
    'SALTA': (-24.7821, -65.4232, -3.0),
    'UYUNI (BO, 3700 m)': (-20.4597, -66.8250, -4.0),
    'LA PAZ (BO)': (-16.4897, -68.1193, -4.0),
    'LIMA (PE)': (-12.0464, -77.0428, -5.0),
    'CIUDAD DE MÉXICO': (19.4326, -99.1332, -6.0),
    'MADRID': (40.4168, -3.7038, 2.0),
    'LISBOA': (38.7223, -9.1393, 1.0),
  };

  @override
  Widget build(BuildContext context) {
    final offset = Duration(minutes: (utcOffsetHours * 60).round());
    final utcDay = DateTime.utc(day.year, day.month, day.day, 12);
    final windows = SolarCalculator.windows(
      day: utcDay,
      latitude: latitude,
      longitude: longitude,
      utcOffset: offset,
    );
    final events = SolarCalculator.events(
      day: utcDay,
      latitude: latitude,
      longitude: longitude,
      utcOffset: offset,
    );
    final now = SolarCalculator.position(
      when: DateTime.now().toUtc(),
      latitude: latitude,
      longitude: longitude,
    );

    return Scaffold(
      backgroundColor: OnSetColors.background,
      appBar: AppBar(
        backgroundColor: OnSetColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'LUZ SOLAR',
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
            _placeChips(),
            const SizedBox(height: 14),
            _sunNow(now),
            const SizedBox(height: 22),
            _section('VENTANAS DE LUZ · ${_fmtDate(day)}'),
            ...windows.map(_windowTile),
            const SizedBox(height: 22),
            _section('EVENTOS DEL DÍA'),
            ...events.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        _fmtTime(e.time),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        e.label,
                        style: const TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _coordinates(),
            const SizedBox(height: 12),
            const Text(
              'Calculado con las fórmulas solares de NOAA. Se equivoca como mucho '
              'un par de minutos en el día. Para el horario del lugar, ajustá el huso.',
              style: TextStyle(fontSize: 9, color: Colors.white30, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _places.entries.map((e) {
        final selected = (latitude - e.value.$1).abs() < 0.01;
        return GestureDetector(
          onTap: () => setState(() {
            latitude = e.value.$1;
            longitude = e.value.$2;
            utcOffsetHours = e.value.$3;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? OnSetColors.surfaceHigh : Colors.transparent,
              border: Border.all(color: selected ? OnSetColors.brand : Colors.white24),
            ),
            child: Text(
              e.key,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.white38,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sunNow(SunPosition now) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: now.isUp ? OnSetColors.brand : Colors.white24),
      ),
      child: Row(
        children: [
          Icon(
            now.isUp ? Icons.wb_sunny_outlined : Icons.nightlight_round,
            color: now.isUp ? OnSetColors.brand : Colors.white38,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  now.isUp ? 'SOL SOBRE EL HORIZONTE' : 'SOL DEBAJO DEL HORIZONTE',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: now.isUp ? OnSetColors.brand : Colors.white38,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${now.altitudeDegrees.toStringAsFixed(1)}° de altura · '
                  'acimut ${now.azimuthDegrees.toStringAsFixed(0)}° (${now.cardinal})',
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _windowTile(LightWindow w) {
    final isGold = w.label.contains('DORADA');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: OnSetColors.surface,
          border: Border.all(color: isGold ? OnSetColors.brand : Colors.blueAccent),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                w.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isGold ? OnSetColors.brand : Colors.blueAccent,
                ),
              ),
            ),
            Text(
              '${_fmtTime(w.start)} – ${_fmtTime(w.end)}',
              style: const TextStyle(fontSize: 13, color: Colors.white, fontFamily: 'monospace'),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 44,
              child: Text(
                '${w.duration.inMinutes} min',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 10, color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coordinates() {
    return Row(
      children: [
        Expanded(child: _smallField('LATITUD', latitude, (v) => setState(() => latitude = v))),
        const SizedBox(width: 10),
        Expanded(child: _smallField('LONGITUD', longitude, (v) => setState(() => longitude = v))),
        const SizedBox(width: 10),
        Expanded(child: _smallField('HUSO (h)', utcOffsetHours, (v) => setState(() => utcOffsetHours = v))),
      ],
    );
  }

  Widget _smallField(String label, double value, Function(double) onChanged) {
    return _SolarField(label: label, value: value, onChanged: onChanged);
  }

  Widget _section(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white54,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      );

  String _fmtTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _fmtDate(DateTime t) {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${t.day} ${months[t.month - 1]}';
  }
}

class _SolarField extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;

  const _SolarField({required this.label, required this.value, required this.onChanged});

  @override
  State<_SolarField> createState() => _SolarFieldState();
}

class _SolarFieldState extends State<_SolarField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value.toString());

  @override
  void didUpdateWidget(covariant _SolarField oldWidget) {
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
          style: const TextStyle(fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            border: Border.all(color: Colors.white24),
          ),
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace'),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
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
