import 'package:flutter/material.dart';

import '../data/camera_selection.dart';
import '../theme/app_theme.dart';
import 'camera_setup_screen.dart';
import 'cine_calculator_screen.dart';
import 'color_screen.dart';
import 'dof_calculator_screen.dart';
import 'electricity_screen.dart';
import 'exposure_screen.dart';
import 'flicker_screen.dart';
import 'light_screen.dart';
import 'optics_screen.dart';
import 'shots_log_screen.dart';
import 'solar_screen.dart';
import 'storage_screen.dart';
import 'viewfinder_screen.dart';

/// Una herramienta del menú.
class _Tool {
  final String title;
  final String detail;
  final IconData icon;
  final WidgetBuilder open;

  const _Tool({
    required this.title,
    required this.detail,
    required this.icon,
    required this.open,
  });
}

/// Un departamento: agrupa las herramientas de la misma familia.
class _Department {
  final String name;
  final String purpose;
  final Color color;
  final List<_Tool> tools;

  const _Department({
    required this.name,
    required this.purpose,
    required this.color,
    required this.tools,
  });
}

/// Menú principal, ordenado por departamentos como en un set.
class DashboardScreen extends StatelessWidget {
  final CameraSelection selection;

  const DashboardScreen({super.key, required this.selection});

  String get sensorName => selection.label;
  bool get isFilm => selection.isFilm;
  double get coc => selection.cocMm;

  List<_Department> get _departments => [
        _Department(
          name: 'ELÉCTRICO',
          purpose: 'instalación: corriente, cables y reparto',
          color: OnSetColors.power,
          tools: [
            _Tool(
              title: 'CIRCUITO',
              detail: '¿aguanta el soporte? corriente, cable y generador',
              icon: Icons.bolt_outlined,
              open: (context) => const ElectricityScreen(),
            ),
            _Tool(
              title: 'FASES',
              detail: 'reparto de varias cargas entre las tres fases',
              icon: Icons.electrical_services,
              open: (context) => const ElectricityScreen(initialTab: 1),
            ),
          ],
        ),
        _Department(
          name: 'CÁMARA Y ÓPTICA',
          purpose: 'armar: encuadre, lente y foco',
          color: OnSetColors.camera,
          tools: [
            _Tool(
              title: 'VISOR DE CÁMARA',
              detail: 'encuadre real sobre la imagen del teléfono',
              icon: Icons.camera_alt_outlined,
              open: (context) => const ViewfinderScreen(),
            ),
            _Tool(
              title: 'ÓPTICA / FOV',
              detail: 'campo de visión y equivalencia de lentes',
              icon: Icons.crop_free,
              open: (context) => const OpticsScreen(),
            ),
            _Tool(
              title: 'PROFUNDIDAD DE CAMPO',
              detail: 'hiperfocal y zona nítida',
              icon: Icons.center_focus_strong_outlined,
              open: (context) => const DofCalculatorScreen(),
            ),
          ],
        ),
        _Department(
          name: 'IMAGEN Y EXPOSICIÓN',
          purpose: 'exponer y corregir: la luz que llega al sensor',
          color: OnSetColors.image,
          tools: [
            _Tool(
              title: 'SISTEMA DE ZONAS / EXPO',
              detail: 'zonas, fall-off, compensar y fotometría',
              icon: Icons.exposure_outlined,
              open: (context) => const ExpoFotoTabs(),
            ),
            _Tool(
              title: 'COLOR Y GELES',
              detail: 'temperatura, mireds y gelatinas',
              icon: Icons.palette_outlined,
              open: (context) => const ColorScreen(),
            ),
            _Tool(
              title: 'FLICKER Y PARPADEO',
              detail: 'obturadores seguros para la red eléctrica',
              icon: Icons.light_mode_outlined,
              open: (context) => const FlickerScreen(),
            ),
          ],
        ),
        _Department(
          name: 'PRODUCCIÓN',
          purpose: 'planificar y registrar: cuándo, cuánto y qué',
          color: OnSetColors.data,
          tools: [
            _Tool(
              title: 'LUZ SOLAR',
              detail: 'hora azul, dorada y posición del sol',
              icon: Icons.wb_twilight,
              open: (context) => const SolarScreen(),
            ),
            _Tool(
              title: isFilm ? 'CHASIS Y METRAJE' : 'DATA Y ALMACENAMIENTO',
              detail: isFilm ? 'pies, tiempo y chasis' : 'códecs, espacio y copia DIT',
              icon: isFilm ? Icons.movie_creation_outlined : Icons.sd_storage_outlined,
              open: (context) => const StorageScreen(),
            ),
            _Tool(
              title: 'PLANOS Y NOTAS',
              detail: 'configuraciones guardadas y anotaciones',
              icon: Icons.fact_check_outlined,
              open: (context) => const ShotsLogScreen(),
            ),
          ],
        ),
        _Department(
          name: 'UTILIDADES',
          purpose: 'lo transversal: cuentas y linterna',
          color: OnSetColors.tools,
          tools: [
            _Tool(
              title: 'CALCULADORA DE CINE',
              detail: 'fracciones, inversas y pasos',
              icon: Icons.calculate_outlined,
              open: (context) => const CineCalculatorScreen(),
            ),
            _Tool(
              title: 'LINTERNA',
              detail: 'pantalla blanca y flash del teléfono',
              icon: Icons.flashlight_on_outlined,
              open: (context) => const LightScreen(),
            ),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final departments = _departments;
    return Scaffold(
      backgroundColor: OnSetColors.background,
      appBar: AppBar(
        backgroundColor: OnSetColors.background,
        elevation: 0,
        title: const Text(
          'ON SET PRO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 4.0,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'CAMBIAR CÁMARA',
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white70),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CameraSetupScreen(initial: selection),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        children: [
          _cameraCard(),
          const SizedBox(height: 26),
          for (final department in departments) ...[
            _departmentHeader(department),
            const SizedBox(height: 10),
            for (final tool in department.tools) _toolCard(tool, department.color),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _cameraCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CÁMARA ACTIVA',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: Colors.white,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            sensorName.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${isFilm ? "PELÍCULA" : "DIGITAL"} · '
            '${selection.widthMm.toStringAsFixed(2)} × ${selection.heightMm.toStringAsFixed(2)} mm · '
            'CoC ${coc.toStringAsFixed(4)} mm',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _departmentHeader(_Department department) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: 3, height: 26, color: department.color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                department.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                  color: department.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                department.purpose,
                style: const TextStyle(fontSize: 9, color: Colors.white38),
              ),
            ],
          ),
        ),
        Text(
          '${department.tools.length}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: department.color.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _toolCard(_Tool tool, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Builder(
        builder: (context) => InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: tool.open),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: OnSetColors.surface,
              border: Border(
                left: BorderSide(color: accent, width: 3),
                top: BorderSide(color: Colors.white10),
                right: BorderSide(color: Colors.white10),
                bottom: BorderSide(color: Colors.white10),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            child: Row(
              children: [
                Icon(tool.icon, color: accent, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tool.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tool.detail,
                        style: const TextStyle(fontSize: 9, color: Colors.white38),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 13),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
