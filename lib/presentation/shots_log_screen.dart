import 'package:flutter/material.dart';

import '../data/catalogs/camera_filters.dart';
import '../data/catalogs/light_gels.dart';
import '../data/shots_repository.dart';
import '../state/shot_state.dart';
import '../theme/app_theme.dart';

/// Planos guardados y notas de cámara / iluminación.
class ShotsLogScreen extends StatefulWidget {
  const ShotsLogScreen({super.key});

  @override
  State<ShotsLogScreen> createState() => _ShotsLogScreenState();
}

class _ShotsLogScreenState extends State<ShotsLogScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  final TextEditingController _noteController = TextEditingController();
  String department = 'CÁMARA';

  @override
  void initState() {
    super.initState();
    ShotsRepository.instance.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ShotsRepository.instance;
    return Scaffold(
      backgroundColor: OnSetColors.background,
      appBar: AppBar(
        backgroundColor: OnSetColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'PLANOS Y NOTAS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: OnSetColors.tools,
          labelColor: OnSetColors.tools,
          unselectedLabelColor: Colors.white38,
          tabs: [
            Tab(text: 'PLANOS (${repo.plans.length})'),
            Tab(text: 'NOTAS (${repo.notes.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _plansTab(repo),
          _notesTab(repo),
        ],
      ),
    );
  }

  Widget _plansTab(ShotsRepository repo) {
    if (repo.plans.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Text(
            'Todavía no guardaste planos.\n\nEn Exposición → Compensar, tocá GUARDAR PLANO\npara tener la configuración a mano.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, height: 1.6, fontSize: 12),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: repo.plans.length,
      itemBuilder: (context, i) {
        final plan = repo.plans[i];
        return Dismissible(
          key: ValueKey(plan.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            color: OnSetColors.danger,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) async {
            await repo.deletePlan(plan.id);
            if (context.mounted) setState(() {});
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: OnSetColors.surface,
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.cameraLabel,
                        style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      _time(plan.savedAt),
                      style: const TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'ISO ${plan.iso.toStringAsFixed(0)} · ${plan.fps.toStringAsFixed(0)} fps · '
                  '${plan.shutterAngle.toStringAsFixed(1)}° (${plan.shutterLabel})',
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.lossLabel,
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),
                const SizedBox(height: 8),
                Text(
                  plan.correctionStops.abs() < 0.05
                      ? 'EXPOSICIÓN CORRECTA'
                      : '${plan.correctionStops > 0 ? '+' : ''}${plan.correctionStops.toStringAsFixed(1)} stops',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: plan.correctionStops.abs() < 0.05
                        ? OnSetColors.ok
                        : (plan.correctionStops > 0 ? OnSetColors.brand : OnSetColors.danger),
                  ),
                ),
                if (plan.note != null && plan.note!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    plan.note!,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _applyPlan(plan),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      border: Border.all(color: OnSetColors.brand),
                    ),
                    child: const Text(
                      'APLICAR AL PLANO ACTUAL',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                        color: OnSetColors.brand,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Vuelve a cargar en el plano actual todo lo que tenía ese plano guardado.
  void _applyPlan(ShotPlan plan) {
    final shot = ShotState.instance;
    shot.setIso(plan.iso);
    shot.setFps(plan.fps);
    shot.setShutterAngle(plan.shutterAngle);
    shot.clearFilters();
    shot.clearGels();
    for (final name in plan.filterNames) {
      shot.addFilter(CameraFilters.byName(name));
    }
    for (final label in plan.gelLabels) {
      final gel = LightGels.all.where((g) => g.label == label).firstOrNull;
      if (gel != null) shot.addGel(gel);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Plano aplicado: ${plan.cameraLabel}')),
    );
    setState(() {});
  }

  Widget _notesTab(ShotsRepository repo) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  for (final dep in ['CÁMARA', 'ILUMINACIÓN'])
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => department = dep),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          margin: const EdgeInsets.only(right: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: department == dep ? OnSetColors.surfaceHigh : Colors.transparent,
                            border: Border.all(
                              color: department == dep ? OnSetColors.tools : Colors.white24,
                            ),
                          ),
                          child: Text(
                            dep,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: department == dep ? Colors.white : Colors.white38,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                minLines: 2,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: department == 'CÁMARA'
                      ? 'Ej: el 50 mm no cubre Open Gate a 5 m'
                      : 'Ej: la fuente 2 hace sombra en el fondo',
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                  filled: true,
                  fillColor: OnSetColors.surface,
                  border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: OnSetColors.tools,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 46),
                ),
                onPressed: () async {
                  final text = _noteController.text.trim();
                  if (text.isEmpty) return;
                  await repo.addNote(department: department, text: text);
                  _noteController.clear();
                  if (mounted) setState(() {});
                },
                child: const Text('GUARDAR NOTA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ),
        ),
        Expanded(
          child: repo.notes.isEmpty
              ? const Center(
                  child: Text(
                    'Sin notas todavía.',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  itemCount: repo.notes.length,
                  itemBuilder: (context, i) {
                    final note = repo.notes[i];
                    return Dismissible(
                      key: ValueKey(note.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        color: OnSetColors.danger,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        await repo.deleteNote(note.id);
                        if (context.mounted) setState(() {});
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: OnSetColors.surface,
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${note.department} · ${_time(note.savedAt)}',
                              style: const TextStyle(fontSize: 9, color: OnSetColors.tools, letterSpacing: 1),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              note.text,
                              style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _time(DateTime when) {
    final d = when.day.toString().padLeft(2, '0');
    final m = when.month.toString().padLeft(2, '0');
    final hh = when.hour.toString().padLeft(2, '0');
    final mm = when.minute.toString().padLeft(2, '0');
    return '$d/$m $hh:$mm';
  }
}
