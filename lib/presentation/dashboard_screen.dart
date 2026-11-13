import 'package:flutter/material.dart';
import 'dof_calculator_screen.dart';
import 'exposure_screen.dart';
import 'electricity_screen.dart';
import 'storage_screen.dart'; // Import agregado correctamente
import 'flicker_screen.dart';
import 'color_screen.dart';
import 'optics_screen.dart';
import '../theme/app_theme.dart';
import 'camera_setup_screen.dart';
import 'distro_screen.dart';
import 'light_screen.dart';
import 'nd_quick_screen.dart';
import 'shots_log_screen.dart';
import 'solar_screen.dart';
import 'viewfinder_screen.dart';
import '../data/camera_selection.dart';

class DashboardScreen extends StatelessWidget {
  final CameraSelection selection;

  const DashboardScreen({super.key, required this.selection});

  String get sensorName => selection.label;
  bool get isFilm => selection.isFilm;
  double get coc => selection.cocMm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnSetColors.background, // Fondo principal oscuro
      appBar: AppBar(
        backgroundColor: OnSetColors.background, // AppBar oscuro
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
      // Cambiado a SingleChildScrollView para evitar errores de desbordamiento
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta de información geométrica y simple (Estilo Dark Mode)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black, // Fondo de la tarjeta en negro puro
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ), // Borde blanco
                borderRadius: BorderRadius.zero, // Bordes afilados
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CÁMARA ACTIVA',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: Colors.white, // Texto en blanco
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'FORMATO: ${sensorName.toUpperCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Texto en blanco
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TIPO: ${isFilm ? "PELÍCULA" : "DIGITAL"}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white54, // Blanco sutil para jerarquía
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CoC: ${coc.toStringAsFixed(4)} mm',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white54, // Blanco sutil para jerarquía
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'HERRAMIENTAS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white, // Título en blanco
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 20),

            // 1. PROFUNDIDAD DE CAMPO
            _buildDashboardCard(
              title: 'PROFUNDIDAD DE CAMPO',
              icon: Icons.center_focus_strong_outlined,
              accent: OnSetColors.camera,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DofCalculatorScreen(),
                  ),
                );
              },
            ),

            // 2. SISTEMA DE ZONAS / EXPO
            _buildDashboardCard(
              title: 'SISTEMA DE ZONAS / EXPO',
              icon: Icons.exposure_outlined,
              accent: OnSetColors.image,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExpoFotoTabs()),
                );
              },
            ),

            // 3. ELECTRICIDAD Y ENERGÍA
            _buildDashboardCard(
              title: 'ELECTRICIDAD Y ENERGÍA',
              icon: Icons.bolt_outlined,
              accent: OnSetColors.power,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ElectricityScreen(),
                  ),
                );
              },
            ),

            // 4. DATA Y ALMACENAMIENTO (Cambia dinámicamente según isFilm)
            _buildDashboardCard(
              title: isFilm ? 'CHASIS Y METRAJE' : 'DATA Y ALMACENAMIENTO',
              icon: isFilm
                  ? Icons.movie_creation_outlined
                  : Icons.sd_storage_outlined,
              accent: OnSetColors.data,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StorageScreen(),
                  ),
                );
              },
            ),

            // 6. FLICKER / PARPADEO
            _buildDashboardCard(
              title: 'FLICKER Y PARPADEO',
              icon: Icons.light_mode_outlined,
              accent: OnSetColors.image,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FlickerScreen(),
                  ),
                );
              },
            ),
            // 7. COLOR Y TEMPERATURA
            _buildDashboardCard(
              title: 'COLOR Y GELES (MIREDS)',
              icon: Icons.palette_outlined,
              accent: OnSetColors.power,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ColorScreen()),
                );
              },
            ),
            _buildDashboardCard(
              title: 'VISOR DE CÁMARA',
              icon: Icons.camera_alt_outlined,
              accent: OnSetColors.camera,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewfinderScreen()),
                );
              },
            ),
            _buildDashboardCard(
              title: 'ND RÁPIDO',
              icon: Icons.filter_tilt_shift,
              accent: OnSetColors.camera,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NdQuickScreen()),
                );
              },
            ),
            _buildDashboardCard(
              title: 'LUZ SOLAR',
              icon: Icons.wb_twilight,
              accent: OnSetColors.tools,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SolarScreen()),
                );
              },
            ),
            _buildDashboardCard(
              title: 'DISTRO ELÉCTRICA',
              icon: Icons.electrical_services,
              accent: OnSetColors.power,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DistroScreen()),
                );
              },
            ),
            _buildDashboardCard(
              title: 'PLANOS Y NOTAS',
              icon: Icons.fact_check_outlined,
              accent: OnSetColors.tools,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShotsLogScreen()),
                );
              },
            ),
            _buildDashboardCard(
              title: 'LINTERNA',
              icon: Icons.flashlight_on_outlined,
              accent: OnSetColors.tools,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LightScreen()),
                );
              },
            ),
            // 8. ÓPTICA Y FOV
            _buildDashboardCard(
              title: 'ÓPTICA / FOV (LENS MATCHER)',
              icon: Icons.camera_outlined,
              accent: OnSetColors.camera,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OpticsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET ACTUALIZADO PARA MODO OSCURO ---
  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: OnSetColors.surface, // Gris oscuro característico
            borderRadius: BorderRadius.zero,
            border: Border(
              left: BorderSide(color: accent, width: 4),
              top: BorderSide(color: Colors.white12, width: 1),
              right: BorderSide(color: Colors.white12, width: 1),
              bottom: BorderSide(color: Colors.white12, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 28),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54, // Flecha en blanco sutil
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
