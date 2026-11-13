import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'camera_selection.dart';
import 'catalogs/camera_filters.dart';
import 'catalogs/light_gels.dart';

/// Un plano guardado: todo lo que se eligió y se calculó para rodarlo.
class ShotPlan {
  final String id;
  final DateTime savedAt;
  final String cameraLabel;
  final String kind;
  final double iso;
  final double fps;
  final double shutterAngle;
  final List<String> filterNames;
  final List<String> gelLabels;
  final double meterReading;
  final double correctionStops;
  final String? note;

  const ShotPlan({
    required this.id,
    required this.savedAt,
    required this.cameraLabel,
    required this.kind,
    required this.iso,
    required this.fps,
    required this.shutterAngle,
    required this.filterNames,
    required this.gelLabels,
    required this.meterReading,
    required this.correctionStops,
    this.note,
  });

  /// "1/48 s" calculado desde el ángulo y el fps.
  String get shutterLabel {
    final seconds = shutterAngle / (360 * fps);
    final den = 1 / seconds;
    return '1/${den.round()} s';
  }

  String get lossLabel {
    final parts = <String>[
      for (final f in filterNames) f.split(' — ').first,
      for (final g in gelLabels) g,
    ];
    return parts.isEmpty ? 'sin filtros' : parts.join(' + ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'savedAt': savedAt.toIso8601String(),
        'cameraLabel': cameraLabel,
        'kind': kind,
        'iso': iso,
        'fps': fps,
        'shutterAngle': shutterAngle,
        'filterNames': filterNames,
        'gelLabels': gelLabels,
        'meterReading': meterReading,
        'correctionStops': correctionStops,
        if (note != null) 'note': note,
      };

  static ShotPlan fromJson(Map<String, dynamic> json) => ShotPlan(
        id: json['id'] as String,
        savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
        cameraLabel: json['cameraLabel'] as String? ?? '',
        kind: json['kind'] as String? ?? 'digital',
        iso: (json['iso'] as num?)?.toDouble() ?? 800,
        fps: (json['fps'] as num?)?.toDouble() ?? 24,
        shutterAngle: (json['shutterAngle'] as num?)?.toDouble() ?? 180,
        filterNames: (json['filterNames'] as List?)?.cast<String>() ?? const [],
        gelLabels: (json['gelLabels'] as List?)?.cast<String>() ?? const [],
        meterReading: (json['meterReading'] as num?)?.toDouble() ?? 0,
        correctionStops: (json['correctionStops'] as num?)?.toDouble() ?? 0,
        note: json['note'] as String?,
      );
}

/// Una nota rápida de cámara o de iluminación.
class SetNote {
  final String id;
  final DateTime savedAt;
  final String department; // "CÁMARA" o "ILUMINACIÓN"
  final String text;

  const SetNote({
    required this.id,
    required this.savedAt,
    required this.department,
    required this.text,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'savedAt': savedAt.toIso8601String(),
        'department': department,
        'text': text,
      };

  static SetNote fromJson(Map<String, dynamic> json) => SetNote(
        id: json['id'] as String,
        savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
        department: json['department'] as String? ?? 'CÁMARA',
        text: json['text'] as String? ?? '',
      );
}

/// Guarda y recupera planos y notas en el propio dispositivo.
class ShotsRepository {
  ShotsRepository._();

  static final ShotsRepository instance = ShotsRepository._();

  static const _kPlans = 'shots.plans';
  static const _kNotes = 'shots.notes';
  static const _maxPlans = 100;
  static const _maxNotes = 100;

  List<ShotPlan> _plans = const [];
  List<SetNote> _notes = const [];

  List<ShotPlan> get plans => _plans;
  List<SetNote> get notes => _notes;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _plans = _decode(prefs.getString(_kPlans))
        .map(ShotPlan.fromJson)
        .toList();
    _notes = _decode(prefs.getString(_kNotes))
        .map(SetNote.fromJson)
        .toList();
  }

  Future<ShotPlan> savePlan({
    required CameraSelection camera,
    required double iso,
    required double fps,
    required double shutterAngle,
    required List<CameraFilter> filters,
    required List<LightGel> gels,
    required double meterReading,
    required double correctionStops,
    String? note,
  }) async {
    final plan = ShotPlan(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      savedAt: DateTime.now(),
      cameraLabel: camera.label,
      kind: camera.kind,
      iso: iso,
      fps: fps,
      shutterAngle: shutterAngle,
      filterNames: filters.map((f) => f.name).toList(),
      gelLabels: gels.map((g) => g.label).toList(),
      meterReading: meterReading,
      correctionStops: correctionStops,
      note: note,
    );
    _plans = [plan, ..._plans].take(_maxPlans).toList();
    await _persist();
    return plan;
  }

  Future<void> deletePlan(String id) async {
    _plans = _plans.where((p) => p.id != id).toList();
    await _persist();
  }

  Future<SetNote> addNote({required String department, required String text}) async {
    final note = SetNote(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      savedAt: DateTime.now(),
      department: department,
      text: text,
    );
    _notes = [note, ..._notes].take(_maxNotes).toList();
    await _persist();
    return note;
  }

  Future<void> deleteNote(String id) async {
    _notes = _notes.where((n) => n.id != id).toList();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPlans, jsonEncode(_plans.map((p) => p.toJson()).toList()));
    await prefs.setString(_kNotes, jsonEncode(_notes.map((n) => n.toJson()).toList()));
  }

  List<Map<String, dynamic>> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw);
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {
      // Un almacenamiento corrupto no debe romper la app.
    }
    return const [];
  }
}
