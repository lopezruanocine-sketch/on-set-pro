import 'package:flutter/material.dart';

import '../domain/flicker/flicker_engine.dart';
import '../state/shot_state.dart';
import '../theme/app_theme.dart';

/// Parpadeo: qué obturaciones no captan el pulso de la red eléctrica.
class FlickerScreen extends StatefulWidget {
  const FlickerScreen({super.key});

  @override
  State<FlickerScreen> createState() => _FlickerScreenState();
}

class _FlickerScreenState extends State<FlickerScreen> {
  double gridHz = 50;
  bool angleMode = true;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ShotState.instance,
      builder: (context, _) {
        final shot = ShotState.instance;
        final windows = FlickerEngine.safeWindows(gridHz: gridHz, fps: shot.fps);
        final recommended = FlickerEngine.recommended(gridHz: gridHz, fps: shot.fps);
        final currentSafe = FlickerEngine.isSafe(
          gridHz: gridHz,
          fps: shot.fps,
          angle: shot.shutterAngle,
        );

        return Scaffold(
          backgroundColor: OnSetColors.background,
          appBar: AppBar(
            backgroundColor: OnSetColors.background,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'FLICKER / PARPADEO',
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
                _gridSelector(),
                const SizedBox(height: 10),
                const Text(
                  '50 Hz: Europa, Argentina, etc. · 60 Hz: EE. UU., México, Colombia, etc.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 9),
                ),
                const SizedBox(height: 25),
                _statusCard(shot, currentSafe, recommended),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'VENTANAS SEGURAS',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    _modeToggle(),
                  ],
                ),
                const SizedBox(height: 12),
                if (windows.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No hay ventanas seguras para este fps.',
                      style: TextStyle(color: OnSetColors.danger),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...windows.map((w) => _windowTile(w, recommended, shot)),
                const SizedBox(height: 20),
                const Text(
                  'Tocá una ventana para ponerla en el plano.',
                  style: TextStyle(fontSize: 9, color: Colors.white30),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _gridSelector() {
    return Container(
      height: 48,
      decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
      child: Row(
        children: [50.0, 60.0].map((hz) {
          final selected = gridHz == hz;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => gridHz = hz),
              child: Container(
                color: selected ? Colors.white : Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  '${hz.toStringAsFixed(0)} Hz',
                  style: TextStyle(
                    color: selected ? Colors.black : Colors.white54,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _modeToggle() {
    return GestureDetector(
      onTap: () => setState(() => angleMode = !angleMode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: OnSetColors.surfaceHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          angleMode ? 'ÁNGULO' : '1 / X',
          style: const TextStyle(
            fontSize: 9,
            color: OnSetColors.brand,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _statusCard(ShotState shot, bool safe, FlickerWindow? recommended) {
    final color = safe ? OnSetColors.ok : OnSetColors.danger;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'PLANO A ${shot.fps.toStringAsFixed(shot.fps % 1 == 0 ? 0 : 2)} FPS · '
            '${shot.shutterAngle.toStringAsFixed(1)}°',
            style: const TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            safe ? 'SIN PARPADEO' : 'PARPADEA',
            style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 6),
          Text(
            safe
                ? 'El obturador actual es múltiplo del pulso de la red.'
                : 'Cambiá el obturador: con esta red y este fps, este ángulo capta el parpadeo.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.white54, height: 1.4),
          ),
          if (recommended != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: OnSetColors.surface,
                border: Border.all(color: OnSetColors.brand),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'RECOMENDADO',
                    style: TextStyle(fontSize: 9, color: OnSetColors.brand, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${recommended.angle.toStringAsFixed(1)}° · '
                    '1/${recommended.shutterDenominator.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 13, color: Colors.white, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _windowTile(FlickerWindow w, FlickerWindow? recommended, ShotState shot) {
    final isRecommended = recommended != null && (w.angle - recommended.angle).abs() < 0.01;
    final isCurrent = (w.angle - shot.shutterAngle).abs() < 0.5;

    final main = angleMode
        ? '${w.angle.toStringAsFixed(1)}°'
        : '1/${w.shutterDenominator.toStringAsFixed(w.shutterDenominator % 1 == 0 ? 0 : 1)}';
    final sub = angleMode
        ? '1/${w.shutterDenominator.toStringAsFixed(w.shutterDenominator % 1 == 0 ? 0 : 1)}'
        : '${w.angle.toStringAsFixed(1)}°';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => shot.setShutterAngle(w.angle),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isCurrent ? OnSetColors.surfaceHigh : OnSetColors.surface,
            border: Border.all(
              color: isRecommended
                  ? OnSetColors.brand
                  : (isCurrent ? Colors.white38 : Colors.white10),
            ),
          ),
          child: Row(
            children: [
              Text(
                main,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300, fontFamily: 'monospace', color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                sub,
                style: const TextStyle(fontSize: 10, color: Colors.white38),
              ),
              const Spacer(),
              if (isRecommended)
                const Text(
                  'IDEAL',
                  style: TextStyle(fontSize: 9, color: OnSetColors.brand, fontWeight: FontWeight.bold, letterSpacing: 1),
                )
              else if (isCurrent)
                const Text(
                  'ACTUAL',
                  style: TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
