import 'package:flutter/material.dart';

enum PowerSource { tieIn, generator, battery }

class ElectricityScreen extends StatefulWidget {
  const ElectricityScreen({super.key});

  @override
  State<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends State<ElectricityScreen> {
  PowerSource selectedSource = PowerSource.tieIn;

  // 1. CAPACIDAD (SOPORTE)
  double voltage = 220.0;
  double maxAmps = 15.0;
  double altitudeMeters = 0.0; // Pérdida de potencia del generador por altitud

  double batteryVoltage = 14.4;
  double batteryWh = 150.0;
  double maxBatteryDrawW = 120.0;

  // 2. CARGA
  double totalWatts = 1000.0;

  // 3. CABLES (Métrico + Amperaje Máximo Real H07RN-F)
  double distanceMeters = 30.0;
  double selectedSqMm = 2.5; // Lo bajamos a 2.5 como valor por defecto estándar

  // [Sección mm², Amperaje Máx (Térmico), Ohms por Km]
  final Map<double, List<double>> cableSpecs = {
    1.0: [10.0, 19.5], // Alargue común / Zapatilla (Enchufe normal)
    1.5: [15.0, 13.3], // Consumo ligero / LEDs
    2.5: [20.0, 7.98], // Taller estándar (Enchufe 20A)
    4.0: [25.0, 4.95], // Taller reforzado
    6.0: [35.0, 3.30], // Extensiones de Gaffer
    10.0: [50.0, 1.91], // Acometida principal
  };

  // 4. LOGÍSTICA
  double shootingHours = 12.0;
  bool isGasoline = true;

  @override
  Widget build(BuildContext context) {
    // --- MATEMÁTICA EN TIEMPO REAL ---
    double activeVoltage = selectedSource == PowerSource.battery
        ? batteryVoltage
        : voltage;
    double currentAmps = totalWatts / activeVoltage;
    double loadRatio = 0.0;

    // Cálculo de pérdida por Altitud (Derating: ~10% por cada 1000m)
    double deratingFactor = selectedSource == PowerSource.generator
        ? (1.0 - (altitudeMeters / 1000.0) * 0.10).clamp(0.4, 1.0)
        : 1.0;

    double actualMaxAmps = maxAmps * deratingFactor;

    if (selectedSource == PowerSource.battery) {
      loadRatio = totalWatts / maxBatteryDrawW;
    } else {
      loadRatio = currentAmps / actualMaxAmps;
    }

    // SEMÁFORO DINÁMICO
    Color diagColor = const Color(0xFF4CAF50); // Verde
    if (loadRatio >= 1.0) {
      diagColor = const Color(0xFFFF5252); // Rojo (Sobrecarga)
    } else if (loadRatio >= 0.9) {
      diagColor = const Color(0xFFFF9800); // Naranja (Crítico)
    } else if (loadRatio >= 0.7) {
      diagColor = const Color(0xFFFFD700); // Amarillo (Elevado)
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          "ELECTRICIDAD Y ENERGÍA",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 14,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SELECTOR DE ORIGEN ---
            Container(
              height: 45,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  _buildSourceButton("RED (TIE-IN)", PowerSource.tieIn),
                  _buildSourceButton("GENERADOR", PowerSource.generator),
                  _buildSourceButton("BATERÍA", PowerSource.battery),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- SEMÁFORO GRÁFICO DINÁMICO ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: diagColor, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loadRatio >= 1.0 ? "SOBRECARGA" : "CARGA ACTUAL",
                        style: TextStyle(
                          color: diagColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        "${(loadRatio * 100).toInt()}%",
                        style: TextStyle(
                          color: diagColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: LinearProgressIndicator(
                      value: loadRatio.clamp(0.0, 1.0),
                      backgroundColor: Colors.white10,
                      color: diagColor,
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    selectedSource == PowerSource.battery
                        ? "${(batteryWh / (totalWatts == 0 ? 1 : totalWatts)).toStringAsFixed(1)} HR"
                        : "${currentAmps.toStringAsFixed(1)} A",
                    style: TextStyle(
                      color: diagColor,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    selectedSource == PowerSource.battery
                        ? "AUTONOMÍA ESTIMADA"
                        : "CONSUMO EN AMPERIOS",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Aviso de Altitud para Generadores
                  if (selectedSource == PowerSource.generator &&
                      altitudeMeters > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        "Física: El generador pierde ${((1 - deratingFactor) * 100).toInt()}% de su potencia por la altitud. Su límite real cayó a ${actualMaxAmps.toStringAsFixed(1)}A.",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 9,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- SECCIÓN 1: CAPACIDAD (SOPORTE) ---
            _buildSectionTitle("1. CAPACIDAD DEL SOPORTE"),

            if (selectedSource == PowerSource.battery) ...[
              const Text(
                "VOLTAJE DE LA BATERÍA",
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    _buildGenericToggle(
                      "14.4V (Estándar)",
                      batteryVoltage == 14.4,
                      () => setState(() => batteryVoltage = 14.4),
                    ),
                    _buildGenericToggle(
                      "26V (High Voltage)",
                      batteryVoltage == 26.0,
                      () => setState(() => batteryVoltage = 26.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      "CAPACIDAD (Wh)",
                      batteryWh,
                      (v) => setState(() => batteryWh = v),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildInput(
                      "MAX DRAW (W)",
                      maxBatteryDrawW,
                      (v) => setState(() => maxBatteryDrawW = v),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                "VOLTAJE REGIONAL",
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    _buildGenericToggle(
                      "110V",
                      voltage == 110.0,
                      () => setState(() => voltage = 110.0),
                    ),
                    _buildGenericToggle(
                      "220V",
                      voltage == 220.0,
                      () => setState(() => voltage = 220.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _buildInput(
                      selectedSource == PowerSource.generator
                          ? "MAX AMPERAJE (A)"
                          : "LÍMITE BREAKER (A)",
                      maxAmps,
                      (v) => setState(() => maxAmps = v),
                    ),
                  ),
                  if (selectedSource == PowerSource.generator) ...[
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildInput(
                        "ALTITUD (m.s.n.m.)",
                        altitudeMeters,
                        (v) => setState(() => altitudeMeters = v),
                      ),
                    ),
                  ],
                ],
              ),
            ],

            const SizedBox(height: 30),

            // --- SECCIÓN 2: CARGA (WATTS) ---
            _buildSectionTitle("2. CARGA A CONECTAR"),
            _buildInput(
              "TOTAL WATTS (W)",
              totalWatts,
              (v) => setState(() => totalWatts = v),
              highlight: true,
            ),

            const SizedBox(height: 40),

            // --- SECCIÓN 3: CABLES ---
            if (selectedSource != PowerSource.battery) ...[
              _buildSectionTitle("3. TENDIDO DE CABLES"),
              _buildCableSection(currentAmps),
              const SizedBox(height: 30),
            ],

            // --- SECCIÓN 4: LOGÍSTICA ---
            if (selectedSource == PowerSource.generator) ...[
              _buildSectionTitle("4. LOGÍSTICA DE COMBUSTIBLE"),
              _buildFuelModule(),
            ],
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES AUXILIARES ---

  Widget _buildSourceButton(String label, PowerSource source) {
    bool isSelected = selectedSource == source;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedSource = source),
        child: Container(
          color: isSelected ? Colors.white : Colors.transparent,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white54,
              fontWeight: FontWeight.w900,
              fontSize: 9,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenericToggle(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: active ? const Color(0xFF2C2C2E) : Colors.transparent,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
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
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    double val,
    Function(double) onChanged, {
    bool highlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: highlight ? const Color(0xFFFFD700) : Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border.all(
              color: highlight
                  ? const Color(0xFFFFD700).withOpacity(0.5)
                  : Colors.white24,
            ),
          ),
          child: TextFormField(
            initialValue: val == val.toInt()
                ? val.toInt().toString()
                : val.toString(),
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'monospace',
            ),
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (v) {
              double? n = double.tryParse(v);
              if (n != null) onChanged(n);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCableSection(double currentAmps) {
    double ohmsPerKm = cableSpecs[selectedSqMm]![1];
    double maxCableAmps = cableSpecs[selectedSqMm]![0];
    double vDrop = currentAmps * ((ohmsPerKm / 1000.0) * distanceMeters * 2.0);
    double dropPercent = (vDrop / voltage) * 100;

    bool isCableBurning = currentAmps > maxCableAmps;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInput(
                "DISTANCIA (m)",
                distanceMeters,
                (v) => setState(() => distanceMeters = v),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SECCIÓN DEL CABLE",
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      border: Border.all(
                        color: isCableBurning ? Colors.red : Colors.white24,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<double>(
                        value: selectedSqMm,
                        isExpanded: true,
                        dropdownColor: Colors.black,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        // Aquí mostramos el límite en Amperios
                        items: cableSpecs.keys
                            .map(
                              (mm) => DropdownMenuItem(
                                value: mm,
                                child: Text(
                                  "$mm mm² (Max ${cableSpecs[mm]![0].toInt()}A)",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedSqMm = v!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            isCableBurning
                ? "¡PELIGRO TÉRMICO! El amperaje supera el límite del cable."
                : "CAÍDA DE TENSIÓN: ${dropPercent.toStringAsFixed(1)}% (-${vDrop.toStringAsFixed(1)}V)",
            style: TextStyle(
              color: isCableBurning
                  ? Colors.red
                  : (dropPercent > 5 ? Colors.amber : Colors.white38),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFuelModule() {
    double liters =
        (totalWatts / 1000.0) * (isGasoline ? 0.5 : 0.3) * shootingHours * 1.15;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInput(
                "JORNADA (Horas)",
                shootingHours,
                (v) => setState(() => shootingHours = v),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                height: 50,
                margin: const EdgeInsets.only(top: 18),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    _buildGenericToggle(
                      "GASOLINA",
                      isGasoline,
                      () => setState(() => isGasoline = true),
                    ),
                    _buildGenericToggle(
                      "DIÉSEL",
                      !isGasoline,
                      () => setState(() => isGasoline = false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "COMPRA SUGERIDA\n(ESTIMADO)",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${liters.toStringAsFixed(1)} Lts",
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "*El consumo real varía según el estado mecánico del motor y fluctuaciones de carga. Estimación incluye un +15% de margen logístico.",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 8,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
