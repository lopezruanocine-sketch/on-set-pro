import 'package:shared_preferences/shared_preferences.dart';

import '../domain/power/power_engine.dart';

/// Memoria de la red eléctrica del rodaje.
///
/// La tensión se elige antes que nada porque define los amperajes de todo lo
/// demás: 10 A son 2.200 W a 220 V y 1.100 W a 110 V.
class ElectricitySettings {
  final double voltage;
  final Phases phases;

  const ElectricitySettings({
    this.voltage = 220,
    this.phases = Phases.single,
  });

  static const defaults = ElectricitySettings();

  static const _kVoltage = 'electricity.voltage';
  static const _kPhases = 'electricity.phases';

  static Future<ElectricitySettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final voltage = prefs.getDouble(_kVoltage) ?? defaults.voltage;
    final threePhase = prefs.getBool(_kPhases) ?? false;
    return ElectricitySettings(
      voltage: voltage,
      phases: threePhase ? Phases.three : Phases.single,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kVoltage, voltage);
    await prefs.setBool(_kPhases, phases == Phases.three);
  }
}
