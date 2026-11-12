import 'package:flutter/material.dart';
import '../core/media_constants.dart'; // Asegúrate de que esta ruta apunte a tu archivo de datos

class StorageScreen extends StatefulWidget {
  final bool isFilm;
  final String sensorName;

  const StorageScreen({
    super.key,
    required this.isFilm,
    required this.sensorName,
  });

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  // --- ESTADO DIGITAL ---
  String selectedRes = '4K (UHD)';
  String selectedCodec = 'ProRes 4444';
  double fpsDigital = 24.0;
  double hoursToRecord = 1.0;
  double minutesToRecord = 0.0;
  double transferSpeedMBps =
      500.0; // Velocidad de disco por defecto (SSD estándar)

  // --- ESTADO FÍLMICO ---
  double magSizeFeet = 1000.0;
  double consumedFeet = 0.0;
  double fpsFilm = 24.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text(
          widget.isFilm ? "CHASIS / METRAJE" : "DATA / ALMACENAMIENTO",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: widget.isFilm
            ? _buildFilmCalculator()
            : _buildDigitalCalculator(),
      ),
    );
  }

  // ==========================================
  // CEREBRO A: CALCULADORA DE PELÍCULA (MAGS)
  // ==========================================
  Widget _buildFilmCalculator() {
    double baseFpm =
        MediaConstants.filmFeetPerMinute[widget.sensorName] ?? 90.0;
    double actualFpm = baseFpm * (fpsFilm / 24.0);

    // Matemática de consumo en set
    double remainingFeet = (magSizeFeet - consumedFeet).clamp(
      0.0,
      double.infinity,
    );
    double remainingMinutes = actualFpm > 0 ? remainingFeet / actualFpm : 0;

    int mins = remainingMinutes.floor();
    int secs = ((remainingMinutes - mins) * 60).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildResultCard(
          title: "TIEMPO RESTANTE EN CHASIS",
          mainValue:
              "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}",
          subValue: "MINUTOS : SEGUNDOS",
          warningText:
              "Pies disponibles: ${remainingFeet.toInt()} ft  |  Consumo: ${actualFpm.toStringAsFixed(1)} ft/min",
        ),
        const SizedBox(height: 40),

        _buildSectionTitle("ESTADO DEL CHASIS (Contador)"),
        Row(
          children: [
            Expanded(
              child: _buildInput(
                "TAMAÑO TOTAL (ft)",
                magSizeFeet,
                (v) => setState(() => magSizeFeet = v),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildInput(
                "CONSUMIDO (ft)",
                consumedFeet,
                (v) => setState(() => consumedFeet = v),
                highlight: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildSectionTitle("CONFIGURACIÓN DE CÁMARA"),
        _buildInput(
          "FOTOGRAMAS (FPS)",
          fpsFilm,
          (v) => setState(() => fpsFilm = v),
        ),
      ],
    );
  }

  // ==========================================
  // CEREBRO B: CALCULADORA DIGITAL Y DIT
  // ==========================================
  Widget _buildDigitalCalculator() {
    // 1. Matemáticas de Almacenamiento
    double baseBitrateMbps =
        MediaConstants.proResBitrates[selectedRes]?[selectedCodec] ?? 264.0;
    double actualBitrateMbps = baseBitrateMbps * (fpsDigital / 24.0);

    double totalSeconds = (hoursToRecord * 3600) + (minutesToRecord * 60);
    double totalMegabits = actualBitrateMbps * totalSeconds;
    double totalMegabytes = totalMegabits / 8.0;
    double totalGigabytes = totalMegabytes / 1024.0;
    double safeGigabytes = totalGigabytes * 1.10; // 10% margen formato

    String displayValue;
    String displayUnit;
    if (safeGigabytes > 1000) {
      displayValue = (safeGigabytes / 1024.0).toStringAsFixed(2);
      displayUnit = "TERABYTES (TB)";
    } else {
      displayValue = safeGigabytes.toStringAsFixed(1);
      displayUnit = "GIGABYTES (GB)";
    }

    // 2. Matemáticas de Offload (DIT)
    double transferSeconds = transferSpeedMBps > 0
        ? totalMegabytes / transferSpeedMBps
        : 0;
    int tHours = (transferSeconds / 3600).floor();
    int tMinutes = ((transferSeconds % 3600) / 60).floor();
    String transferTimeText = tHours > 0
        ? "${tHours}h ${tMinutes}m"
        : "$tMinutes minutos";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // RESULTADO DE ALMACENAMIENTO
        _buildResultCard(
          title: "ESPACIO REQUERIDO",
          mainValue: displayValue,
          subValue: displayUnit,
          warningText: "* Incluye 10% de margen de seguridad por formato.",
        ),
        const SizedBox(height: 15),

        // MÓDULO DIT: TIEMPO DE DESCARGA
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF333333), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TIEMPO ESTIMADO DE OFFLOAD",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    transferTimeText,
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const Icon(Icons.timer_outlined, color: Colors.white24, size: 30),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // CONTROLES DE GRABACIÓN
        _buildSectionTitle("FORMATO DE GRABACIÓN"),
        _buildDropdown(
          "RESOLUCIÓN",
          selectedRes,
          MediaConstants.proResBitrates.keys.toList(),
          (v) {
            setState(() {
              selectedRes = v;
              selectedCodec = MediaConstants.proResBitrates[v]!.keys.first;
            });
          },
        ),
        const SizedBox(height: 15),
        _buildDropdown(
          "CÓDEC (APPLE PRORES)",
          selectedCodec,
          MediaConstants.proResBitrates[selectedRes]!.keys.toList(),
          (v) => setState(() => selectedCodec = v),
        ),
        const SizedBox(height: 15),
        _buildInput(
          "FOTOGRAMAS (FPS)",
          fpsDigital,
          (v) => setState(() => fpsDigital = v),
        ),

        const SizedBox(height: 30),
        _buildSectionTitle("TIEMPO A GRABAR"),
        Row(
          children: [
            Expanded(
              child: _buildInput(
                "HORAS",
                hoursToRecord,
                (v) => setState(() => hoursToRecord = v),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildInput(
                "MINUTOS",
                minutesToRecord,
                (v) => setState(() => minutesToRecord = v),
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),
        _buildSectionTitle("VELOCIDAD DE DISCO (DIT)"),
        _buildDropdown(
          "MEDIO DE TRANSFERENCIA",
          transferSpeedMBps.toString(),
          [
            "130.0", // HDD Convencional
            "500.0", // SSD SATA (USB 3.0)
            "1000.0", // SSD NVMe (USB-C 3.2)
            "2500.0", // SSD Thunderbolt 3/4
          ],
          (v) => setState(() => transferSpeedMBps = double.parse(v)),
          customLabels: {
            "130.0": "HDD Estándar (~130 MB/s)",
            "500.0": "SSD SATA (~500 MB/s)",
            "1000.0": "SSD NVMe (~1000 MB/s)",
            "2500.0": "Thunderbolt (~2500 MB/s)",
          },
        ),
      ],
    );
  }

  // --- WIDGETS GEOMÉTRICOS ---

  Widget _buildResultCard({
    required String title,
    required String mainValue,
    required String subValue,
    required String warningText,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            mainValue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w300,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subValue,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            warningText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
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

  Widget _buildDropdown(
    String label,
    String val,
    List<String> options,
    Function(String) onChanged, {
    Map<String, String>? customLabels,
  }) {
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
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: val,
              isExpanded: true,
              dropdownColor: Colors.black,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: options
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        customLabels != null ? customLabels[e]! : e,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => onChanged(v!),
            ),
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
