import 'package:flutter/material.dart';
import 'dart:math';
import '../core/localization.dart';
import '../core/pro_input.dart';

class DofCalculatorScreen extends StatefulWidget {
  final double coc;
  final String
  sensorName; // Agregado para mantener compatibilidad con tu Dashboard

  const DofCalculatorScreen({
    super.key,
    required this.coc,
    required this.sensorName,
  });

  @override
  State<DofCalculatorScreen> createState() => _DofCalculatorScreenState();
}

class _DofCalculatorScreenState extends State<DofCalculatorScreen> {
  double focal = 50, aperture = 2.8, dist = 2.0;

  @override
  Widget build(BuildContext context) {
    double fM = focal / 1000;
    double h = (pow(fM, 2) / (max(aperture, 0.1) * (widget.coc / 1000))) + fM;
    double near = (h * dist) / (h + (dist - fM));
    double far = (h * dist) / max((h - (dist - fM)), 0.0001);

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fondo oscuro Kaan Cine
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text(
          t('focus'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            _buildVisualizer(near, far, dist, h),
            const SizedBox(height: 20),
            ProInput(
              label: t('lens'),
              value: focal,
              min: 8,
              max: 300,
              unit: "mm",
              color: const Color(0xFF64B5F6),
              onChanged: (v) => setState(() => focal = v),
            ),
            ProInput(
              label: t('aper'),
              value: aperture,
              min: 0.95,
              max: 32,
              unit: "f/",
              color: const Color(0xFF64B5F6),
              onChanged: (v) => setState(() => aperture = v),
              isDecimal: true,
            ),
            ProInput(
              label: t('dist'),
              value: dist,
              min: 0.3,
              max: 100,
              unit: "m",
              color: const Color(0xFF64B5F6),
              onChanged: (v) => setState(() => dist = v),
              isDecimal: true,
            ),
            const Divider(height: 60, color: Colors.white10),
            _row(t('near'), "${near.toStringAsFixed(2)} m"),
            _row(
              t('far'),
              (far < 0 || far > 500)
                  ? "INFINITO"
                  : "${far.toStringAsFixed(2)} m",
            ),
            _row(
              t('hyp'),
              "${h.toStringAsFixed(2)} m",
              c: const Color(0xFFFFD700),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${t('coc')}: ${widget.coc.toStringAsFixed(3)} mm",
                style: const TextStyle(fontSize: 10, color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizer(double near, double far, double dist, double h) {
    double maxScale = max(h, dist) * 1.2;
    double toPercent(double d) => (d / maxScale).clamp(0.0, 1.0);
    bool inf = far > maxScale * 2 || far < 0;

    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          double w = constraints.maxWidth;
          double pNear = toPercent(near) * w;
          double pDist = toPercent(dist) * w;
          double pFar = inf ? w : toPercent(far) * w;
          double pHyp = toPercent(h) * w;

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                top: 60,
                left: 10,
                right: 10,
                child: Container(height: 1, color: Colors.white10),
              ),
              const Positioned(
                left: 10,
                top: 50,
                child: Icon(Icons.videocam, color: Colors.white38, size: 16),
              ),
              const Positioned(
                left: 10,
                top: 75,
                child: Text(
                  "0m",
                  style: TextStyle(fontSize: 8, color: Colors.white38),
                ),
              ),
              Positioned(
                left: pNear,
                width: max(pFar - pNear, 2.0),
                top: 55,
                bottom: 35,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF64B5F6).withOpacity(0.3),
                    borderRadius: BorderRadius.horizontal(
                      left: const Radius.circular(4),
                      right: inf ? Radius.zero : const Radius.circular(4),
                    ),
                    border: Border.all(
                      color: const Color(0xFF64B5F6).withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: pDist - 6,
                top: 56,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: pDist - 20,
                top: 35,
                child: SizedBox(
                  width: 40,
                  child: Text(
                    t('g_sub'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (pHyp < w) ...[
                Positioned(
                  left: pHyp,
                  top: 45,
                  bottom: 25,
                  child: Container(width: 2, color: const Color(0xFFFFD700)),
                ),
                Positioned(
                  left: pHyp - 30,
                  top: 25,
                  child: SizedBox(
                    width: 60,
                    child: Text(
                      t('g_hyp'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              Positioned(
                left: pNear,
                top: 75,
                child: Text(
                  t('g_dof'),
                  style: const TextStyle(fontSize: 8, color: Color(0xFF64B5F6)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String l, String v, {Color c = Colors.white}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white54,
            letterSpacing: 1,
          ),
        ),
        Text(
          v,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w300,
            color: c,
            fontFamily: 'monospace',
          ),
        ),
      ],
    ),
  );
}
