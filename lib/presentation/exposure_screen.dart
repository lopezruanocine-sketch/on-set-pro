import 'package:flutter/material.dart';
import 'dart:math';
import '../core/localization.dart';
import '../core/pro_input.dart';
import '../core/cine_data.dart';

class ExpoFotoTabs extends StatelessWidget {
  /// Pestaña que se abre primero (0 = zonas, 1 = fall-off, 2 = compensar,
  /// 3 = fotometría).
  final int initialTab;

  const ExpoFotoTabs({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: initialTab.clamp(0, 3),
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            t('expo'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: const Color(0xFFFFD700),
            labelColor: const Color(0xFFFFD700),
            unselectedLabelColor: Colors.white38,
            tabs: [
              const Tab(text: "MAPA DE ZONAS"),
              const Tab(text: "FALL-OFF"),
              Tab(text: t('comp')),
              const Tab(text: "FOTOMETRÍA (LUX/F)"),
            ],
          ),
        ),
        // QUITAMOS EL CONST DE AQUÍ PARA SOLUCIONAR LOS ERRORES
        body: const TabBarView(
          children: [
            ZoneSystemScreen(),
            InverseSquareTool(),
            ExposureCompensationScreen(),
            LuxFStopUnifiedTool(),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// 1. MAPA DE ZONAS (ESTILO REFERENCIA)
// -----------------------------------------------------------------
class ZoneSystemScreen extends StatefulWidget {
  const ZoneSystemScreen({super.key});
  @override
  State<ZoneSystemScreen> createState() => _ZoneSystemScreenState();
}

class _ZoneSystemScreenState extends State<ZoneSystemScreen> {
  double cameraF = 2.8;
  double meteredF = 16.0;
  int targetZone = 8;

  final List<Color> zoneColors = [
    Colors.black,
    const Color(0xFF1A1A1A),
    const Color(0xFF333333),
    const Color(0xFF4D4D4D),
    const Color(0xFF666666),
    const Color(0xFF808080),
    const Color(0xFF999999),
    const Color(0xFFB3B3B3),
    const Color(0xFFCCCCCC),
    const Color(0xFFE6E6E6),
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    double stopsDiff = 2 * (log(meteredF / cameraF) / ln2);
    double currentZoneRaw = 5 + stopsDiff;
    int currentZone = currentZoneRaw.round().clamp(0, 10);
    double correctionNeeded = targetZone - currentZoneRaw;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "f/ EN CÁMARA",
                  cameraF,
                  CineData.apertures,
                  (v) => setState(() => cameraF = v),
                  isFstop: true,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildManualInput(
                  "LECTURA FOTÓMETRO",
                  meteredF,
                  (v) => setState(() => meteredF = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "TOCA LA ZONA DESTINO",
            style: TextStyle(
              fontSize: 10,
              color: Colors.white54,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 80,
            child: Row(
              children: List.generate(11, (index) {
                bool isCurrent = index == currentZone;
                bool isTarget = index == targetZone;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => targetZone = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: zoneColors[index],
                        border: Border.all(
                          color: isTarget
                              ? const Color(0xFFFFD700)
                              : (isCurrent
                                    ? Colors.redAccent
                                    : Colors.transparent),
                          width: isTarget || isCurrent ? 3 : 0,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          index == 5 ? "V" : "$index",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: index < 5 ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 40),
          _buildResultCard(correctionNeeded, "INSTRUCCIÓN PARA ILUMINACIÓN"),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// 2. FALL-OFF (INVERSA DEL CUADRADO)
// -----------------------------------------------------------------
class InverseSquareTool extends StatefulWidget {
  const InverseSquareTool({super.key});
  @override
  State<InverseSquareTool> createState() => _ISTState();
}

class _ISTState extends State<InverseSquareTool> {
  double d1 = 2, d2 = 4;
  @override
  Widget build(BuildContext context) {
    double s = 2 * (log(max(d1 / max(d2, 0.1), 0.01)) / ln2);
    double intensity = pow(min(d1 / max(d2, 0.1), 1.0), 2).toDouble();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: LayoutBuilder(
              builder: (ctx, box) {
                double w = box.maxWidth;
                double maxDist = max(d2, 5.0) * 1.15;
                double subjectX = 40.0;
                double lightX = subjectX + (d2 / maxDist) * (w - 60);
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned(
                      top: 80,
                      left: 10,
                      right: 10,
                      child: Container(height: 1, color: Colors.white10),
                    ),
                    if (lightX > subjectX)
                      Positioned(
                        left: subjectX + 15,
                        top: 40,
                        width: lightX - subjectX - 5,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.yellowAccent.withValues(alpha: 0.0),
                                Colors.yellowAccent.withValues(alpha: 0.6),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: subjectX - 15,
                      top: 45,
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.white.withValues(
                          alpha: intensity.clamp(0.2, 1.0),
                        ),
                      ),
                    ),
                    Positioned(
                      left: lightX,
                      top: 50,
                      child: Icon(
                        Icons.lightbulb,
                        color: Colors.yellowAccent,
                        size: 24,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          ProInput(
            label: t('d1'),
            value: d1,
            min: 0.1,
            max: 20,
            unit: t('u_met'),
            color: Colors.redAccent,
            onChanged: (v) => setState(() => d1 = v),
            isDecimal: true,
          ),
          ProInput(
            label: t('d2'),
            value: d2,
            min: 0.1,
            max: 20,
            unit: t('u_met'),
            color: Colors.redAccent,
            onChanged: (v) => setState(() => d2 = v),
            isDecimal: true,
          ),
          const SizedBox(height: 40),
          _buildResultCard(s, "PÉRDIDA / GANANCIA"),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// 3. COMPENSAR (REDISEÑO LIMPIO Y COHERENTE)
// -----------------------------------------------------------------
class ExposureCompensationScreen extends StatefulWidget {
  const ExposureCompensationScreen({super.key});
  @override
  State<ExposureCompensationScreen> createState() =>
      _ExposureCompensationScreenState();
}

class _ExposureCompensationScreenState
    extends State<ExposureCompensationScreen> {
  double cameraF = 4.0; // f/ fijo por narrativa
  double meteredF = 5.6;
  double fps = 24, iso = 800;
  double shutter = 180;
  String selectedND = "Ninguno";
  String selectedGel = "Ninguno";

  @override
  Widget build(BuildContext context) {
    // Matemáticas de compensación
    double baseDiff = 2 * (log(meteredF / cameraF) / ln2);
    double fpsStops = log(max(fps, 0.1) / 24) / ln2;
    double shutterStops = log(shutter / 180) / ln2;
    double isoStops = log(max(iso, 1) / 800) / ln2;
    double filterStops = -CineData.cameraFilters[selectedND]!;
    double gelStops = -CineData.lightGels[selectedGel]!;

    double totalCorrection =
        -(baseDiff +
            fpsStops +
            shutterStops +
            isoStops +
            filterStops +
            gelStops);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "f/ DESEADO",
                  cameraF,
                  CineData.apertures,
                  (v) => setState(() => cameraF = v),
                  isFstop: true,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildManualInput(
                  "LECTURA FOTÓMETRO",
                  meteredF,
                  (v) => setState(() => meteredF = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "ISO",
                  iso,
                  CineData.isos,
                  (v) => setState(() => iso = v),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildDropdown(
                  "FPS",
                  fps,
                  CineData.fps,
                  (v) => setState(() => fps = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDropdown(
            "OBTURACIÓN (º)",
            shutter,
            CineData.shutterAngles,
            (v) => setState(() => shutter = v),
          ),
          const SizedBox(height: 20),
          _buildStringDropdown(
            "FILTRO ND",
            selectedND,
            CineData.cameraFilters.keys.toList(),
            (v) => setState(() => selectedND = v),
          ),
          const SizedBox(height: 20),
          _buildStringDropdown(
            "GEL / REJILLA",
            selectedGel,
            CineData.lightGels.keys.toList(),
            (v) => setState(() => selectedGel = v),
          ),

          const SizedBox(height: 40),
          _buildResultCard(totalCorrection, "CORRECCIÓN DE LUZ"),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// 4. FOTOMETRÍA UNIFICADA
// -----------------------------------------------------------------
class LuxFStopUnifiedTool extends StatefulWidget {
  const LuxFStopUnifiedTool({super.key});
  @override
  State<LuxFStopUnifiedTool> createState() => _LFSUState();
}

class _LFSUState extends State<LuxFStopUnifiedTool> {
  bool isLuxToFStop = true;
  double val = 1000.0, iso = 800;

  @override
  Widget build(BuildContext context) {
    double res = isLuxToFStop
        ? sqrt((max(val, 1) * max(iso, 1)) / (250 * 48))
        : (pow(val, 2) * 250 * 48) / max(iso, 1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          _buildToggleButton(),
          const SizedBox(height: 30),
          ProInput(
            label: isLuxToFStop ? "LUX" : "f/",
            value: val,
            min: 1,
            max: 20000,
            color: Colors.blueAccent,
            onChanged: (v) => setState(() => val = v),
            isDecimal: !isLuxToFStop,
          ),
          ProInput(
            label: "ISO",
            value: iso,
            min: 100,
            max: 12800,
            color: Colors.blueAccent,
            onChanged: (v) => setState(() => iso = v),
          ),
          const SizedBox(height: 40),
          _buildResultDisplay(res),
        ],
      ),
    );
  }

  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: () => setState(() {
        isLuxToFStop = !isLuxToFStop;
        val = isLuxToFStop ? 1000 : 4;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLuxToFStop ? Icons.light_mode : Icons.camera,
              color: Colors.blueAccent,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              isLuxToFStop ? "A f-STOP" : "A LUX",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.swap_horiz, color: Colors.blueAccent, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildResultDisplay(double res) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        children: [
          Text(
            isLuxToFStop ? "DIAFRAGMA" : "INTENSIDAD",
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white38,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            isLuxToFStop
                ? "f / ${res.toStringAsFixed(1)}"
                : "${res.toInt()} LX",
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w300,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// HELPERS COMUNES (ESTILO MAPA DE ZONAS)
// -----------------------------------------------------------------

Widget _buildResultCard(double val, String label) {
  Color accent = val == 0
      ? Colors.green
      : (val > 0 ? const Color(0xFFFFD700) : const Color(0xFFE57373));
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: accent, width: 1.5),
    ),
    child: Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white38,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          val == 0
              ? "OK"
              : "${val > 0 ? '+' : ''}${val.toStringAsFixed(1)} STOPS",
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            color: accent,
          ),
        ),
      ],
    ),
  );
}

Widget _buildDropdown(
  String label,
  double val,
  List<double> options,
  Function(double) onChanged, {
  bool isFstop = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          color: Colors.white54,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<double>(
            value: val,
            isExpanded: true,
            dropdownColor: const Color(0xFF2C2C2E),
            items: options
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      isFstop ? "f/$e" : e.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
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

Widget _buildStringDropdown(
  String label,
  String val,
  List<String> options,
  Function(String) onChanged,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          color: Colors.white54,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: val,
            isExpanded: true,
            dropdownColor: const Color(0xFF2C2C2E),
            items: options
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
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

Widget _buildManualInput(String label, double val, Function(double) onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          color: Colors.white54,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: TextEditingController(text: val.toString()),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixText: "f/ ",
            prefixStyle: TextStyle(color: Colors.white54),
          ),
          onSubmitted: (v) {
            double? n = double.tryParse(v);
            if (n != null) onChanged(n);
          },
        ),
      ),
    ],
  );
}
