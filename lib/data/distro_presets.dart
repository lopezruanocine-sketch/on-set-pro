import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Una carga guardada dentro de un reparto.
class PresetLoad {
  final String name;
  final double watts;

  const PresetLoad({required this.name, required this.watts});

  Map<String, dynamic> toJson() => {'name': name, 'watts': watts};

  static PresetLoad fromJson(Map<String, dynamic> json) => PresetLoad(
        name: json['name'] as String? ?? 'Carga',
        watts: (json['watts'] as num?)?.toDouble() ?? 0,
      );
}

/// Un reparto de cargas guardado con nombre: "entrevista 2 puntos",
/// "set de 4 M18", etc. Es memoria de tu trabajo, no un catálogo de fábrica.
class DistroPreset {
  final String id;
  final String name;
  final DateTime savedAt;
  final List<PresetLoad> loads;

  const DistroPreset({
    required this.id,
    required this.name,
    required this.savedAt,
    required this.loads,
  });

  double get totalWatts => loads.fold(0, (sum, load) => sum + load.watts);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'savedAt': savedAt.toIso8601String(),
        'loads': loads.map((l) => l.toJson()).toList(),
      };

  static DistroPreset fromJson(Map<String, dynamic> json) => DistroPreset(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Reparto',
        savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
        loads: (json['loads'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map(PresetLoad.fromJson)
                .toList() ??
            const [],
      );
}

/// Guarda y recupera repartos habituales en el dispositivo.
class DistroPresets {
  DistroPresets._();

  static final DistroPresets instance = DistroPresets._();

  static const _key = 'distro.presets';
  static const _max = 40;

  List<DistroPreset> _presets = const [];

  List<DistroPreset> get presets => _presets;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      _presets = const [];
      return;
    }
    try {
      final list = jsonDecode(raw);
      _presets = list is List
          ? list
              .whereType<Map<String, dynamic>>()
              .map(DistroPreset.fromJson)
              .toList()
          : const [];
    } catch (_) {
      _presets = const [];
    }
  }

  Future<DistroPreset> save({required String name, required List<PresetLoad> loads}) async {
    final preset = DistroPreset(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim().isEmpty ? 'Reparto' : name.trim(),
      savedAt: DateTime.now(),
      loads: loads,
    );
    _presets = [preset, ..._presets].take(_max).toList();
    await _persist();
    return preset;
  }

  Future<void> delete(String id) async {
    _presets = _presets.where((p) => p.id != id).toList();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_presets.map((p) => p.toJson()).toList()));
  }
}
