// lib/presentation/optical_screen.dart
import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/pro_input.dart';
import '../domain/optical_engine.dart'; // Tu motor auditado

class OpticalScreen extends StatefulWidget { 
  final double cocMm; // Ahora recibe el CoC de nuestra base de datos auditada
  const OpticalScreen({super.key, required this.cocMm}); 
  @override State<OpticalScreen> createState() => _OpticalScreenState(); 
}

class _OpticalScreenState extends State<OpticalScreen> {
  double focal = 50, aperture = 2.8, dist = 2.0;

  @override
  Widget build(BuildContext context) {
    // LLAMAMOS AL MOTOR CIEGO (Clean Architecture)
    double hyperfocalMm = OpticalEngine.calculateHyperfocal(
      focalLengthMm: focal, 
      aperture: aperture, 
      cocMm: widget.cocMm
    );
    double nearMm = OpticalEngine.calculateNearLimit(
      hyperfocalMm: hyperfocalMm, 
      subjectDistanceMm: dist * 1000, 
      focalLengthMm: focal
    );
    double farMm = OpticalEngine.calculateFarLimit(
      hyperfocalMm: hyperfocalMm, 
      subjectDistanceMm: dist * 1000, 
      focalLengthMm: focal
    );

    // Convertimos a metros para tu UI
    double h = hyperfocalMm / 1000;
    double near = nearMm / 1000;
    double far = farMm / 1000;

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Tu fondo Cinema Black Refined
      appBar: AppBar(
        title: Text(t('focus'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.0, color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(30), child: Column(children: [
        ProInput(label: t('lens'), value: focal, min: 8, max: 300, unit: "mm", color: const Color(0xFF64B5F6), onChanged: (v) => setState(() => focal = v)),
        ProInput(label: t('aper'), value: aperture, min: 0.95, max: 32, unit: "f/", color: const Color(0xFF64B5F6), onChanged: (v) => setState(() => aperture = v), isDecimal: true),
        ProInput(label: t('dist'), value: dist, min: 0.3, max: 100, unit: "m", color: const Color(0xFF64B5F6), onChanged: (v) => setState(() => dist = v), isDecimal: true),
        
        const Divider(height: 60, color: Colors.white10),
        
        _row("${t('near')}:", "${near.toStringAsFixed(2)} m"),
        _row("${t('far')}:", farMm == double.infinity ? "INFINITO" : "${far.toStringAsFixed(2)} m"),
        _row("${t('hyp')}:", "${h.toStringAsFixed(2)} m", c: const Color(0xFFFFD700)),
        
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(border: Border.all(color: Colors.white12), borderRadius: BorderRadius.circular(12)),
          child: Text("${t('coc')}: ${widget.cocMm.toStringAsFixed(3)} mm", style: const TextStyle(fontSize: 10, color: Colors.white38)),
        ),
      ])),
    );
  }

  Widget _row(String l, String v, {Color c = Colors.white}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(fontSize: 12, color: Colors.white54, letterSpacing: 1)),
      Text(v, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300, color: c, fontFamily: 'monospace'))
    ])
  );
}