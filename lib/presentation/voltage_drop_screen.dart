import 'package:flutter/material.dart';

class VoltageDropScreen extends StatefulWidget {
  const VoltageDropScreen({super.key});

  @override
  State<VoltageDropScreen> createState() => _VoltageDropScreenState();
}

class _VoltageDropScreenState extends State<VoltageDropScreen> {
  // Valores por defecto
  double voltage = 120.0;
  double watts = 1000.0;
  double distanceMeters =
      30.0; // 30 metros es aprox 100 pies (stinger estándar)
  int selectedAWG = 12; // Calibre de cable estándar en cine

  // Base de datos de cables (American Wire Gauge)
  // [Max Amperios, Resistencia en Ohmios por Kilómetro]
  final Map<int, List<double>> awgSpecs = {
    10: [30.0, 3.28], // Cable muy grueso (Distancias largas)
    12: [20.0, 5.21], // Estándar de cine (Stinger robusto)
    14: [15.0, 8.28], // Extensión comercial buena
    16: [10.0, 13.17], // Extensión casera delgada
  };

  @override
  Widget build(BuildContext context) {
    // 1. Matemáticas de Carga
    double currentAmps = watts / voltage;
    double maxAmpsAllowed = awgSpecs[selectedAWG]![0];

    // 2. Matemáticas de Resistencia y Caída (Fórmula de Cobre)
    double ohmsPerKm = awgSpecs[selectedAWG]![1];
    // Se multiplica por 2 porque la corriente va y vuelve (fase y neutro)
    double totalResistance = (ohmsPerKm / 1000.0) * distanceMeters * 2.0;
    double voltageDrop = currentAmps * totalResistance;

    // 3. Resultados finales
    double voltageAtEnd = voltage - voltageDrop;
    double dropPercentage = (voltageDrop / voltage) * 100;

    // Lógica Visual de Peligro
    Color safetyColor = const Color(0xFF4CAF50); // Verde seguro
    String statusText = "TENDIDO SEGURO";
    String warningMessage =
        "El voltaje y la temperatura del cable están dentro de los límites operativos.";

    if (currentAmps > maxAmpsAllowed) {
      safetyColor = const Color(0xFFFF5252); // Rojo Kaan (Peligro crítico)
      statusText = "¡PELIGRO DE INCENDIO!";
      warningMessage =
          "La carga de ${currentAmps.toStringAsFixed(1)}A supera el límite de ${maxAmpsAllowed.toInt()}A del cable AWG $selectedAWG. El cable se derretirá.";
    } else if (dropPercentage > 5.0) {
      safetyColor = const Color(0xFFFFD700); // Amarillo Kaan (Advertencia)
      statusText = "CAÍDA DE TENSIÓN EXCESIVA";
      warningMessage =
          "Estás perdiendo más del 5% del voltaje. Los equipos sensibles (HMI, monitores) podrían apagarse o parpadear.";
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          "CABLES / CAÍDA",
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
            // PANEL DE DIAGNÓSTICO
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: safetyColor, width: 2),
                borderRadius: BorderRadius.zero,
              ),
              child: Column(
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      color: safetyColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat(
                        "LLEGAN A LA LUZ",
                        "${voltageAtEnd.toStringAsFixed(1)} V",
                        color: Colors.white,
                      ),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildMiniStat(
                        "SE PIERDEN",
                        "${voltageDrop.toStringAsFixed(1)} V",
                        color: safetyColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Pérdida del ${dropPercentage.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    warningMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // CONFIGURACIÓN DE RED
            _buildSectionTitle("CONFIGURACIÓN DE RED"),
            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    "VOLTAJE ORIGEN",
                    voltage,
                    (v) => setState(() => voltage = v),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildInput(
                    "CONSUMO (Watts)",
                    watts,
                    (v) => setState(() => watts = v),
                    highlight: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // TENDIDO DE CABLE
            _buildSectionTitle("TENDIDO DE CABLE"),
            _buildInput(
              "DISTANCIA (Metros)",
              distanceMeters,
              (v) => setState(() => distanceMeters = v),
            ),
            const SizedBox(height: 20),

            Text(
              "GROSOR DEL CABLE (AWG)",
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedAWG,
                  isExpanded: true,
                  dropdownColor: Colors.black,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  items: awgSpecs.keys.map((awg) {
                    return DropdownMenuItem(
                      value: awg,
                      child: Text(
                        "Calibre $awg AWG (Max ${awgSpecs[awg]![0].toInt()}A)",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => selectedAWG = v!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS GEOMÉTRICOS ---

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

  Widget _buildMiniStat(String label, String value, {required Color color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w300,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildInput(
    String label,
    double val,
    Function(double) onChanged, {
    bool highlight = false,
  }) {
    TextEditingController ctrl = TextEditingController(
      text: val.toInt().toString(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: highlight ? const Color(0xFFFFD700) : Colors.white54,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border.all(
              color: highlight
                  ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                  : Colors.white24,
              width: 1,
            ),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
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
