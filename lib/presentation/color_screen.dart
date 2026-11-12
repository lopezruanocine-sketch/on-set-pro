import 'package:flutter/material.dart';

class ColorScreen extends StatefulWidget {
  const ColorScreen({super.key});

  @override
  State<ColorScreen> createState() => _ColorScreenState();
}

class _ColorScreenState extends State<ColorScreen> {
  // --- ESTADO: TEMPERATURA (KELVIN) ---
  double targetK = 5600.0; // Cámara
  double sourceK = 3200.0; // Foco / Luz

  // --- ESTADO: TINTE (VERDE / MAGENTA) ---
  String observedTint =
      'NORMAL'; // NORMAL, GREEN_HIGH, GREEN_LOW, MAGENTA_LOW, MAGENTA_HIGH

  // Base de datos: Geles de Temperatura (Lee/Rosco)
  final List<Map<String, dynamic>> tempGels = [
    {
      'name': 'Full CTO',
      'mired': 159,
      'color': const Color(0xFFFF9800),
      'desc': 'Convierte 6500K a 3200K',
    },
    {
      'name': '1/2 CTO',
      'mired': 81,
      'color': const Color(0xFFFFB74D),
      'desc': 'Convierte 5600K a 3800K',
    },
    {
      'name': '1/4 CTO',
      'mired': 42,
      'color': const Color(0xFFFFE0B2),
      'desc': 'Calienta ligeramente',
    },
    {
      'name': '1/8 CTO',
      'mired': 20,
      'color': const Color(0xFFFFF3E0),
      'desc': 'Toque cálido sutil',
    },
    {
      'name': '1/8 CTB',
      'mired': -12,
      'color': const Color(0xFFE3F2FD),
      'desc': 'Toque frío sutil',
    },
    {
      'name': '1/4 CTB',
      'mired': -35,
      'color': const Color(0xFF90CAF9),
      'desc': 'Enfría ligeramente',
    },
    {
      'name': '1/2 CTB',
      'mired': -68,
      'color': const Color(0xFF42A5F5),
      'desc': 'Convierte 3200K a 4300K',
    },
    {
      'name': 'Full CTB',
      'mired': -137,
      'color': const Color(0xFF2196F3),
      'desc': 'Convierte 3200K a 5600K',
    },
  ];

  // Base de datos: Geles de Tinte (Minus/Plus Green)
  final Map<String, Map<String, dynamic>> tintGels = {
    'GREEN_HIGH': {
      'name': 'Full Minus Green (Magenta)',
      'color': const Color(0xFFE040FB),
    },
    'GREEN_LOW': {'name': '1/4 Minus Green', 'color': const Color(0xFFEA80FC)},
    'NORMAL': {'name': 'NINGUNO', 'color': Colors.white54},
    'MAGENTA_LOW': {'name': '1/4 Plus Green', 'color': const Color(0xFF69F0AE)},
    'MAGENTA_HIGH': {
      'name': 'Full Plus Green (Verde)',
      'color': const Color(0xFF00E676),
    },
  };

  @override
  Widget build(BuildContext context) {
    // 1. MATEMÁTICAS MIRED
    double targetMired = 1000000 / targetK;
    double sourceMired = 1000000 / sourceK;
    double miredShift = targetMired - sourceMired;

    // 2. BÚSQUEDA DEL GEL IDEAL
    Map<String, dynamic> recommendedTempGel = {
      'name': 'NINGUNO (Balanceado)',
      'mired': 0,
      'color': Colors.white,
    };
    double smallestDiff = double.infinity;

    if (miredShift.abs() > 10) {
      // El ojo no nota menos de 10 Mireds
      for (var gel in tempGels) {
        double diff = (gel['mired'] - miredShift).abs();
        if (diff < smallestDiff) {
          smallestDiff = diff;
          recommendedTempGel = gel;
        }
      }
    }

    // 3. COLORES DE INTERFAZ
    Color shiftBorderColor = miredShift > 10
        ? const Color(0xFF2196F3)
        : miredShift < -10
        ? const Color(0xFFFF9800)
        : const Color(0xFF4CAF50);
    Map<String, dynamic> recommendedTintGel = tintGels[observedTint]!;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          "COLOR Y GELES",
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
            // --- PANEL DE RESULTADOS (DIAGNÓSTICO DEL GAFFER) ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: shiftBorderColor, width: 2),
                borderRadius: BorderRadius.zero,
              ),
              child: Column(
                children: [
                  const Text(
                    "DESFASE TÉRMICO (MIREDS)",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    miredShift > 0
                        ? "+${miredShift.toInt()}"
                        : miredShift.toInt().toString(),
                    style: TextStyle(
                      color: shiftBorderColor,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(height: 1, color: Colors.white24),
                  const SizedBox(height: 20),

                  // RESULTADO: TEMPERATURA
                  const Text(
                    "GEL DE TEMPERATURA RECOMENDADO",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    recommendedTempGel['name'].toUpperCase(),
                    style: TextStyle(
                      color: recommendedTempGel['color'],
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 15),

                  // RESULTADO: TINTE
                  if (observedTint != 'NORMAL') ...[
                    const Text(
                      "GEL DE CORRECCIÓN DE TINTE",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      recommendedTintGel['name'].toUpperCase(),
                      style: TextStyle(
                        color: recommendedTintGel['color'],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- CONTROLES DE TEMPERATURA KELVIN ---
            _buildSectionTitle("1. BALANCE DE TEMPERATURA (KELVIN)"),
            _buildSliderCard(
              "CÁMARA (OBJETIVO)",
              targetK,
              (v) => setState(() => targetK = v),
              Colors.white,
            ),
            const SizedBox(height: 15),
            _buildSliderCard(
              "FOCO EN SET (ORIGEN)",
              sourceK,
              (v) => setState(() => sourceK = v),
              const Color(0xFFFFD700),
            ),

            const SizedBox(height: 40),

            // --- CONTROLES DE TINTE VERDE/MAGENTA ---
            _buildSectionTitle("2. CORRECCIÓN DE TINTE (FLUORESCENTES/LED)"),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "¿CÓMO SE VE LA LUZ EN EL MONITOR?",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: observedTint,
                      isExpanded: true,
                      dropdownColor: Colors.black,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'GREEN_HIGH',
                          child: Text(
                            "Muy Verde (Tubo viejo/HMI)",
                            style: TextStyle(color: Color(0xFF00E676)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'GREEN_LOW',
                          child: Text(
                            "Ligeramente Verde",
                            style: TextStyle(color: Color(0xFF69F0AE)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'NORMAL',
                          child: Text(
                            "Normal (Limpia)",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'MAGENTA_LOW',
                          child: Text(
                            "Ligeramente Magenta",
                            style: TextStyle(color: Color(0xFFEA80FC)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'MAGENTA_HIGH',
                          child: Text(
                            "Muy Magenta (LED barato)",
                            style: TextStyle(color: Color(0xFFE040FB)),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => observedTint = v!),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

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

  Widget _buildSliderCard(
    String label,
    double val,
    Function(double) onChanged,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 5, left: 15, right: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Text(
                "${val.toInt()} K",
                style: TextStyle(
                  fontSize: 18,
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accentColor,
              inactiveTrackColor: Colors.white10,
              thumbColor: accentColor,
              overlayColor: accentColor.withValues(alpha: 0.2),
              trackHeight: 2.0,
            ),
            child: Slider(
              value: val,
              min: 2000,
              max: 10000,
              divisions: 160, // Saltos de 50K para más precisión
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
