import 'package:flutter/material.dart';

class FlickerScreen extends StatefulWidget {
  const FlickerScreen({super.key});

  @override
  State<FlickerScreen> createState() => _FlickerScreenState();
}

class _FlickerScreenState extends State<FlickerScreen> {
  // Estado Principal
  int gridFreq = 50; // 50Hz o 60Hz
  double fps = 24.0;
  bool isAngleMode = true; // true = Ángulo (°), false = Shutter (1/x)

  // Motor Matemático de Ventanas Seguras
  List<Map<String, dynamic>> _calculateSafeWindows() {
    List<Map<String, dynamic>> results = [];
    double basePulses = gridFreq * 2.0; // 50Hz = 100 pulsos, 60Hz = 120 pulsos

    // Calculamos los múltiplos (n = 1, 2, 3...)
    for (int n = 1; n <= 8; n++) {
      double exposureTime = n / basePulses;
      double angle = exposureTime * fps * 360.0;
      double shutterSpeedDenom = basePulses / n;

      // En cine, los obturadores mecánicos o globales llegan máximo a 360°
      if (angle <= 360.0) {
        results.add({
          'n': n,
          'angle': angle,
          'shutter': shutterSpeedDenom,
          'distanceTo180': (angle - 180.0).abs(), // Para saber cuál es el ideal
        });
      }
    }

    // Identificar el valor más cercano al estándar de 180°
    if (results.isNotEmpty) {
      results.sort(
        (a, b) => (a['distanceTo180'] as double).compareTo(
          b['distanceTo180'] as double,
        ),
      );
      results.first['isIdeal'] = true; // Marcamos el mejor resultado
      // Volvemos a ordenar por ángulo de menor a mayor para la lista visual
      results.sort(
        (a, b) => (a['angle'] as double).compareTo(b['angle'] as double),
      );
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> safeWindows = _calculateSafeWindows();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          "FLICKER / PARPADEO",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // INTERRUPTOR DE RED ELÉCTRICA (50Hz vs 60Hz)
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildGridButton("50 Hz", 50)),
                  Container(width: 1, color: Colors.white24),
                  Expanded(child: _buildGridButton("60 Hz", 60)),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "* 50Hz: Europa, Argentina, etc. | 60Hz: USA, México, Colombia, etc.",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // CONTROLES DE CÁMARA
            _buildSectionTitle("CONFIGURACIÓN DE CÁMARA"),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildInput(
                    "FOTOGRAMAS (FPS)",
                    fps,
                    (v) => setState(() => fps = v),
                  ),
                ),
                const SizedBox(width: 15),
                // INTERRUPTOR ÁNGULO / SHUTTER
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "MODO DE LECTURA",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 55, // Altura para igualar al TextField
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _buildModeToggle("ÁNGULO", true)),
                            Expanded(child: _buildModeToggle("1 / X", false)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // RESULTADOS: VENTANAS SEGURAS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("VENTANAS SEGURAS (FLICKER-FREE)"),
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF4CAF50),
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // LISTA DINÁMICA DE RESULTADOS
            if (safeWindows.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "FPS demasiado alto para esta red eléctrica.",
                  style: TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...safeWindows.map((window) {
                bool isIdeal = window['isIdeal'] ?? false;

                // Formateo de los valores
                String angleText =
                    "${(window['angle'] as double).toStringAsFixed(1)}°";

                // Limpieza visual para el shutter (si es .0, quitar decimales)
                double shDenom = window['shutter'] as double;
                String shutterText = shDenom % 1 == 0
                    ? "1 / ${shDenom.toInt()}"
                    : "1 / ${shDenom.toStringAsFixed(1)}";

                String mainDisplay = isAngleMode ? angleText : shutterText;
                String subDisplay = isAngleMode
                    ? "SHUTTER EQ: $shutterText"
                    : "ÁNGULO EQ: $angleText";

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isIdeal ? const Color(0xFF1E1E1E) : Colors.black,
                    border: Border.all(
                      color: isIdeal ? const Color(0xFFFFD700) : Colors.white24,
                      width: isIdeal ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isIdeal)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                isAngleMode
                                    ? "RECOMENDADO (MÁS CERCANO A 180°)"
                                    : "RECOMENDADO (MOTION BLUR ESTÁNDAR 1/${(fps * 2).toInt()})",
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          Text(
                            mainDisplay,
                            style: TextStyle(
                              color: isIdeal
                                  ? const Color(0xFFFFD700)
                                  : Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            subDisplay,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      // Indicador de "Ventana"
                      Column(
                        children: [
                          Text(
                            "VENTANA",
                            style: TextStyle(
                              color: isIdeal
                                  ? const Color(0xFFFFD700)
                                  : Colors.white38,
                              fontSize: 8,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            "#${window['n']}",
                            style: TextStyle(
                              color: isIdeal
                                  ? const Color(0xFFFFD700)
                                  : Colors.white54,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildGridButton(String title, int freq) {
    bool isActive = gridFreq == freq;
    return GestureDetector(
      onTap: () => setState(() => gridFreq = freq),
      child: Container(
        color: isActive ? Colors.white : Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white54,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle(String title, bool isAngle) {
    bool isActive = isAngleMode == isAngle;
    return GestureDetector(
      onTap: () => setState(() => isAngleMode = isAngle),
      child: Container(
        color: isActive ? const Color(0xFF2C2C2E) : Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white38,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildInput(String label, double val, Function(double) onChanged) {
    TextEditingController ctrl = TextEditingController(
      text: val.toInt().toString(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontFamily: 'monospace',
            ),
            decoration: const InputDecoration(border: InputBorder.none),
            onSubmitted: (v) {
              double? n = double.tryParse(v);
              if (n != null) onChanged(n);
            },
          ),
        ),
      ],
    );
  }
}
