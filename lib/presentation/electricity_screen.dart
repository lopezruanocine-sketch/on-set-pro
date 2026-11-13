import 'package:flutter/material.dart';

import '../data/catalogs/cables.dart';
import '../domain/power/power_engine.dart';
import '../theme/app_theme.dart';
import 'panels/distro_panel.dart';

enum PowerSource { tieIn, generator, battery }

/// Electricidad de set: capacidad del soporte, carga, cable y combustible.
///
/// Los cálculos viven en `PowerEngine` y el catálogo de cables en
/// `CableCatalog`; esta pantalla sólo los muestra.
class ElectricityScreen extends StatefulWidget {
  /// Pestaña inicial: 0 = circuito, 1 = fases.
  final int initialTab;

  const ElectricityScreen({super.key, this.initialTab = 0});

  @override
  State<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends State<ElectricityScreen> {
  PowerSource source = PowerSource.tieIn;

  // --- soporte ---
  double voltage = 220;
  Phases phases = Phases.single;
  double breakerAmps = 32;
  double generatorKva = 20;
  double altitudeM = 0;
  double ambientC = 30;

  // --- batería ---
  double batteryVoltage = 14.4;
  double batteryWh = 150;
  double maxBatteryDrawW = 120;

  // --- carga ---
  double totalWatts = 1000;

  // --- cable ---
  CableKind cableKind = CableKind.h07rnf;
  double cableSection = 2.5;
  double distanceM = 30;

  // --- logística ---
  double shootingHours = 12;
  bool isGasoline = true;

  /// Corriente que el soporte aguanta por fase, según la pestaña CIRCUITO.
  double? get _capacityPerPhase {
    if (source == PowerSource.battery) return null;
    if (source == PowerSource.generator) {
      final gen = PowerEngine.generator(
        nameplateKva: generatorKva,
        altitudeM: altitudeM,
        ambientC: ambientC,
      );
      return PowerEngine.generatorAmps(
        kva: gen.usableKva,
        voltage: voltage,
        phases: phases,
      );
    }
    return breakerAmps;
  }

  /// Texto que explica de dónde sale ese límite.
  String get _sourceLabel {
    switch (source) {
      case PowerSource.battery:
        return 'Batería ${batteryVoltage.toStringAsFixed(1)} V';
      case PowerSource.generator:
        final gen = PowerEngine.generator(
          nameplateKva: generatorKva,
          altitudeM: altitudeM,
          ambientC: ambientC,
        );
        return 'Generador ${generatorKva.toStringAsFixed(0)} kVA → '
            '${gen.usableKva.toStringAsFixed(1)} kVA reales · '
            '${phases == Phases.three ? "trifásico" : "monofásico"}';
      case PowerSource.tieIn:
        return 'Red (tie-in) · breaker ${breakerAmps.toStringAsFixed(0)} A · '
            '${phases == Phases.three ? "trifásico" : "monofásico"}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab.clamp(0, 1),
      child: Scaffold(
        backgroundColor: OnSetColors.background,
        appBar: AppBar(
          backgroundColor: OnSetColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'ELÉCTRICO',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              fontSize: 14,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: OnSetColors.power,
            labelColor: OnSetColors.power,
            unselectedLabelColor: Colors.white38,
            tabs: [
              Tab(text: 'CIRCUITO'),
              Tab(text: 'FASES'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _circuitTab(),
            DistroPanel(
              voltage: voltage,
              limitAmps: _capacityPerPhase,
              sourceLabel: _sourceLabel,
            ),
          ],
        ),
      ),
    );
  }

  /// Pestaña de un solo circuito: soporte, carga, cable y combustible.
  Widget _circuitTab() {
    final isBattery = source == PowerSource.battery;
    final activeVoltage = isBattery ? batteryVoltage : voltage;
    final amps = isBattery
        ? totalWatts / activeVoltage
        : PowerEngine.amps(watts: totalWatts, voltage: activeVoltage, phases: phases);

    double capacityAmps;
    GeneratorCapacity? generator;
    if (isBattery) {
      capacityAmps = maxBatteryDrawW / activeVoltage;
    } else if (source == PowerSource.generator) {
      generator = PowerEngine.generator(
        nameplateKva: generatorKva,
        altitudeM: altitudeM,
        ambientC: ambientC,
      );
      capacityAmps = PowerEngine.generatorAmps(
        kva: generator.usableKva,
        voltage: voltage,
        phases: phases,
      );
    } else {
      capacityAmps = breakerAmps;
    }

    final loadRatio = capacityAmps <= 0 ? 0.0 : amps / capacityAmps;
    final color = _semaforo(loadRatio);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sourceSelector(),
          const SizedBox(height: 25),
          _semaforoCard(loadRatio, color, amps, capacityAmps, isBattery, generator),
          const SizedBox(height: 30),
          _sectionTitle('1. CAPACIDAD DEL SOPORTE'),
          if (isBattery) ..._batteryCapacity() else ..._mainsCapacity(),
          const SizedBox(height: 30),
          _sectionTitle('2. CARGA A CONECTAR'),
          _numberInput(
            'TOTAL WATTS (W)',
            totalWatts,
            (v) => setState(() => totalWatts = v),
            highlight: true,
          ),
          const SizedBox(height: 15),
          Text(
            isBattery
                ? 'A ${activeVoltage.toStringAsFixed(1)} V consume ${amps.toStringAsFixed(1)} A'
                : '${amps.toStringAsFixed(1)} A a ${activeVoltage.toStringAsFixed(0)} V '
                    '${phases == Phases.three ? "trifásico" : "monofásico"}',
            style: const TextStyle(fontSize: 11, color: Colors.white54),
          ),
          if (!isBattery) ...[
            const SizedBox(height: 35),
            _sectionTitle('3. TENDIDO DE CABLES'),
            _cableSection(amps),
          ],
          if (source == PowerSource.generator) ...[
            const SizedBox(height: 35),
            _sectionTitle('4. LOGÍSTICA DE COMBUSTIBLE'),
            _fuelModule(),
          ],
        ],
      ),
    );
  }

  Color _semaforo(double ratio) {
    if (ratio >= 1.0) return OnSetColors.danger;
    if (ratio >= 0.9) return const Color(0xFFFF9800);
    if (ratio >= 0.7) return OnSetColors.brand;
    return OnSetColors.ok;
  }

  // ------------------------------------------------------------- secciones ---

  Widget _sourceSelector() {
    return Container(
      height: 45,
      decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
      child: Row(
        children: [
          _sourceButton('RED (TIE-IN)', PowerSource.tieIn),
          _sourceButton('GENERADOR', PowerSource.generator),
          _sourceButton('BATERÍA', PowerSource.battery),
        ],
      ),
    );
  }

  Widget _semaforoCard(
    double ratio,
    Color color,
    double amps,
    double capacityAmps,
    bool isBattery,
    GeneratorCapacity? generator,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ratio >= 1.0 ? 'SOBRECARGA' : 'CARGA ACTUAL',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 2.0,
                ),
              ),
              Text(
                '${(ratio * 100).clamp(0, 999).toStringAsFixed(0)}%',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            backgroundColor: Colors.white10,
            color: color,
            minHeight: 12,
          ),
          const SizedBox(height: 18),
          Text(
            isBattery
                ? _autonomyHours().toStringAsFixed(1)
                : amps.toStringAsFixed(1),
            style: TextStyle(
              color: color,
              fontSize: 48,
              fontWeight: FontWeight.w300,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            isBattery ? 'HORAS DE AUTONOMÍA' : 'CONSUMO EN AMPERIOS',
            style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold),
          ),
          if (!isBattery)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Capacidad real del soporte: ${capacityAmps.toStringAsFixed(1)} A',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ),
          if (source == PowerSource.generator && generator != null && altitudeM > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'El generador entrega ${(generator.deratingFactor * 100).toStringAsFixed(0)}% de su placa '
                'por altura y temperatura: ${generator.usableKva.toStringAsFixed(1)} kVA '
                '(${generator.usableKw.toStringAsFixed(1)} kW).',
                textAlign: TextAlign.center,
                style: const TextStyle(color: OnSetColors.power, fontSize: 9, height: 1.4),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _mainsCapacity() {
    return [
      const Text('VOLTAJE REGIONAL', style: TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      _toggleRow([
        ('110 V', voltage == 110, () => setState(() => voltage = 110)),
        ('220 V', voltage == 220, () => setState(() => voltage = 220)),
        ('240 V', voltage == 240, () => setState(() => voltage = 240)),
      ]),
      const SizedBox(height: 12),
      const Text('FASES', style: TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      _toggleRow([
        ('MONOFÁSICO', phases == Phases.single, () => setState(() => phases = Phases.single)),
        ('TRIFÁSICO', phases == Phases.three, () => setState(() => phases = Phases.three)),
      ]),
      const SizedBox(height: 15),
      Row(
        children: [
          Expanded(
            child: source == PowerSource.generator
                ? _numberInput(
                    'GENERADOR (kVA)',
                    generatorKva,
                    (v) => setState(() => generatorKva = v),
                  )
                : _numberInput(
                    'LÍMITE BREAKER (A)',
                    breakerAmps,
                    (v) => setState(() => breakerAmps = v),
                  ),
          ),
          if (source == PowerSource.generator) ...[
            const SizedBox(width: 12),
            Expanded(
              child: _numberInput(
                'ALTITUD (m)',
                altitudeM,
                (v) => setState(() => altitudeM = v),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 12),
      _numberInput(
        'TEMPERATURA AMBIENTE (°C)',
        ambientC,
        (v) => setState(() => ambientC = v),
      ),
      const SizedBox(height: 8),
      const Text(
        'Afecta al cable (ampacidad) y al generador (rendimiento).',
        style: TextStyle(fontSize: 9, color: Colors.white38),
      ),
    ];
  }

  List<Widget> _batteryCapacity() {
    return [
      const Text('VOLTAJE DE LA BATERÍA', style: TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      _toggleRow([
        ('14.4 V', batteryVoltage == 14.4, () => setState(() => batteryVoltage = 14.4)),
        ('26 V', batteryVoltage == 26, () => setState(() => batteryVoltage = 26)),
      ]),
      const SizedBox(height: 15),
      Row(
        children: [
          Expanded(
            child: _numberInput('CAPACIDAD (Wh)', batteryWh, (v) => setState(() => batteryWh = v)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _numberInput('LÍMITE DE DESCARGA (W)', maxBatteryDrawW, (v) => setState(() => maxBatteryDrawW = v)),
          ),
        ],
      ),
    ];
  }

  Widget _cableSection(double amps) {
    final specs = CableCatalog.of(cableKind);
    final cable = specs.firstWhere(
      (c) => (c.sectionMm2 - cableSection).abs() < 0.01,
      orElse: () => specs.first,
    );
    final tempFactor = PowerEngine.cableTempFactor(ambientC);
    final derated = cable.ampacityA * tempFactor;
    final burning = amps > derated;

    final drop = PowerEngine.voltageDrop(
      amps: amps,
      lengthM: distanceM,
      resistanceOhmPerKm: cable.resistanceOhmPerKm,
      voltage: voltage,
      phases: phases,
      conductorTempFactor: 1.2,
    );

    final needed = CableCatalog.forCurrent(cableKind, amps, tempFactor: tempFactor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('TIPO DE CABLE', style: TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _toggleRow([
          ('H07RN-F (métrico)', cableKind == CableKind.h07rnf, () {
            setState(() {
              cableKind = CableKind.h07rnf;
              cableSection = 2.5;
            });
          }),
          ('SOOW (AWG)', cableKind == CableKind.soow, () {
            setState(() {
              cableKind = CableKind.soow;
              cableSection = 2.08;
            });
          }),
        ]),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _numberInput('DISTANCIA (m)', distanceM, (v) => setState(() => distanceM = v)),
            ),
            const SizedBox(width: 12),
            Expanded(child: _sectionPicker(cable, burning)),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            border: Border.all(color: burning ? OnSetColors.danger : Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cableRow(
                'AMPACIDAD DEL CABLE',
                '${cable.ampacityA.toStringAsFixed(0)} A',
                'a 30 °C',
              ),
              _cableRow(
                'CON ESTA TEMPERATURA',
                '${derated.toStringAsFixed(1)} A',
                '${ambientC.toStringAsFixed(0)} °C',
              ),
              _cableRow(
                'CAÍDA DE TENSIÓN',
                '${drop.volts.toStringAsFixed(1)} V',
                '${drop.percent.toStringAsFixed(1)} %',
                color: drop.percent > 5
                    ? OnSetColors.danger
                    : (drop.percent > 3 ? OnSetColors.brand : OnSetColors.ok),
              ),
              const SizedBox(height: 8),
              Text(
                burning
                    ? 'PELIGRO TÉRMICO: la carga supera lo que aguanta este cable. '
                        '${needed == null ? "Pasá a Type W / cam-lock." : "Mínimo ${needed.label}."}'
                    : (drop.percent > 5
                        ? 'La caída de tensión es alta: la lámpara va a trabajar por debajo de su tensión.'
                        : 'El cable está dentro de su límite.'),
                style: TextStyle(
                  color: burning ? OnSetColors.danger : Colors.white54,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionPicker(CableSpec cable, bool burning) {
    final specs = CableCatalog.of(cableKind);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SECCIÓN', style: TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            border: Border.all(color: burning ? OnSetColors.danger : Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<double>(
              value: specs.any((c) => (c.sectionMm2 - cableSection).abs() < 0.01)
                  ? specs.firstWhere((c) => (c.sectionMm2 - cableSection).abs() < 0.01).sectionMm2
                  : specs.first.sectionMm2,
              isExpanded: true,
              dropdownColor: OnSetColors.surfaceHigh,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: specs
                  .map((c) => DropdownMenuItem(
                        value: c.sectionMm2,
                        child: Text(
                          c.label,
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => cableSection = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cableRow(String label, String value, String detail, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 9, color: Colors.white38, letterSpacing: 0.5)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              color: color ?? Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 62,
            child: Text(
              detail,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 9, color: Colors.white30),
            ),
          ),
        ],
      ),
    );
  }

  double _autonomyHours() {
    const depthOfDischarge = 0.8;
    const inverterEfficiency = 0.85;
    if (totalWatts <= 0) return 0;
    return batteryWh * depthOfDischarge * inverterEfficiency / totalWatts;
  }

  Widget _fuelModule() {
    // Consumo típico de un generador de set: 0.5 L/kWh a gasolina y 0.3 a diésel,
    // afectado por la carga real y con un 15 % de margen logístico.
    final perKwh = isGasoline ? 0.5 : 0.3;
    final liters = (totalWatts / 1000) * perKwh * shootingHours * 1.15;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _numberInput('JORNADA (horas)', shootingHours, (v) => setState(() => shootingHours = v)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _toggleRow([
                ('GASOLINA', isGasoline, () => setState(() => isGasoline = true)),
                ('DIÉSEL', !isGasoline, () => setState(() => isGasoline = false)),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.white24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'COMPRA SUGERIDA\n(ESTIMADO)',
                    style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${liters.toStringAsFixed(1)} L',
                    style: const TextStyle(
                      color: OnSetColors.brand,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Base: 0.5 L/kWh a gasolina y 0.3 L/kWh a diésel, más 15 % de margen. '
                'El consumo real depende del estado del motor y de la carga.',
                style: TextStyle(color: Colors.white38, fontSize: 8, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------- controles ---

  Widget _sourceButton(String label, PowerSource value) {
    final selected = source == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => source = value),
        child: Container(
          color: selected ? Colors.white : Colors.transparent,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white54,
              fontWeight: FontWeight.w900,
              fontSize: 9,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
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

  Widget _toggleRow(List<(String, bool, VoidCallback)> options) {
    return Container(
      height: 45,
      decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
      child: Row(
        children: options.map((o) {
          return Expanded(
            child: GestureDetector(
              onTap: o.$3,
              child: Container(
                color: o.$2 ? OnSetColors.surfaceHigh : Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  o.$1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: o.$2 ? Colors.white : Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _numberInput(
    String label,
    double value,
    Function(double) onChanged, {
    bool highlight = false,
  }) {
    return _NumberField(
      label: label,
      value: value,
      onChanged: onChanged,
      highlight: highlight,
    );
  }
}

class _NumberField extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;
  final bool highlight;

  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.highlight = false,
  });

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value == widget.value.roundToDouble()
        ? widget.value.toInt().toString()
        : widget.value.toString(),
  );

  @override
  void didUpdateWidget(covariant _NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = double.tryParse(_controller.text);
    if (current != widget.value) {
      _controller.text = widget.value == widget.value.roundToDouble()
          ? widget.value.toInt().toString()
          : widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 9,
            color: widget.highlight ? OnSetColors.brand : Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: OnSetColors.surface,
            border: Border.all(
              color: widget.highlight
                  ? OnSetColors.brand.withValues(alpha: 0.5)
                  : Colors.white24,
            ),
          ),
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'monospace'),
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (v) {
              final n = double.tryParse(v);
              if (n != null) widget.onChanged(n);
            },
          ),
        ),
      ],
    );
  }
}
