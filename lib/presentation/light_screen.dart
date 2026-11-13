import 'package:flutter/material.dart';

import '../data/light_tools.dart';
import '../theme/app_theme.dart';

/// Linterna de trabajo: pantalla blanca regulable o flash del teléfono.
class LightScreen extends StatefulWidget {
  const LightScreen({super.key});

  @override
  State<LightScreen> createState() => _LightScreenState();
}

class _LightScreenState extends State<LightScreen> {
  final TorchController _torch = TorchController();

  bool screenOn = false;
  double level = 1.0;
  bool torchOn = false;
  bool? torchAvailable;

  @override
  void initState() {
    super.initState();
    _torch.isAvailable.then((available) {
      if (mounted) setState(() => torchAvailable = available);
    });
  }

  @override
  void dispose() {
    // Nunca dejamos el flash encendido al salir.
    if (torchOn) _torch.setOn(false);
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    final target = !torchOn;
    final ok = await _torch.setOn(target);
    if (!mounted) return;
    setState(() => torchOn = ok ? target : false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El flash no está disponible en este dispositivo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenColor = Colors.white.withValues(alpha: level);

    return Scaffold(
      backgroundColor: OnSetColors.background,
      appBar: AppBar(
        backgroundColor: OnSetColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'LINTERNA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Volver',
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (screenOn)
            Positioned.fill(
              child: Container(
                color: screenColor,
                child: level > 0.55
                    ? const SizedBox.shrink()
                    : const SizedBox.expand(),
              ),
            ),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      screenOn ? 'REGULÁ EL BRILLO CON LA BARRA' : 'LUZ DE PANTALLA',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        color: screenOn ? Colors.black38 : Colors.white38,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: level,
                      onChanged: (v) => setState(() {
                        level = v;
                        if (v > 0) screenOn = true;
                      }),
                      activeColor: screenOn ? Colors.black54 : OnSetColors.tools,
                      inactiveColor: screenOn ? Colors.black12 : Colors.white10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final preset in [0.25, 0.5, 0.75, 1.0])
                          GestureDetector(
                            onTap: () => setState(() {
                              level = preset;
                              screenOn = true;
                            }),
                            child: Text(
                              '${(preset * 100).round()}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: screenOn ? Colors.black45 : Colors.white38,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    _bigButton(
                      label: screenOn ? 'APAGAR PANTALLA' : 'ENCENDER PANTALLA',
                      icon: screenOn ? Icons.brightness_low : Icons.light_mode,
                      active: screenOn,
                      onTap: () => setState(() => screenOn = !screenOn),
                    ),
                    const SizedBox(height: 14),
                    _torchButton(),
                    const SizedBox(height: 18),
                    Text(
                      torchAvailable == false
                          ? 'El flash no está disponible en este dispositivo. '
                              'En el teléfono sí funciona.'
                          : 'Consejo: para revisar el guion o dar luz a los ojos, '
                              'usá la pantalla al 50 %.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        height: 1.4,
                        color: screenOn ? Colors.black38 : Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _torchButton() {
    final available = torchAvailable ?? true;
    return Opacity(
      opacity: available ? 1 : 0.4,
      child: _bigButton(
        label: torchOn ? 'APAGAR FLASH' : 'ENCENDER FLASH',
        icon: torchOn ? Icons.flashlight_off : Icons.flashlight_on,
        active: torchOn,
        onTap: available ? _toggleTorch : null,
      ),
    );
  }

  Widget _bigButton({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? OnSetColors.tools : Colors.transparent,
          border: Border.all(
            color: active ? OnSetColors.tools : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? Colors.black : Colors.white70, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
                color: active ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
