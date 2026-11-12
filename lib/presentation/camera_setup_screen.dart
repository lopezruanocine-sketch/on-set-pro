import 'package:flutter/material.dart';
import '../core/localization.dart'; // ¡Volvemos a conectar los idiomas!
import 'dashboard_screen.dart'; 

final Map<String, double> digitalSensors = {
  "Medio Formato (GFX)": 0.050, "Full Frame / VV": 0.030, "Super 35mm": 0.025,
  "APS-C (Sony/Fuji)": 0.020, "APS-C (Canon)": 0.019, "MFT (GH6/BMPCC)": 0.015,
  "1-inch Sensor": 0.011, "1/1.7-inch": 0.007, "1/2.3-inch": 0.006, "1/3-inch": 0.005,
};

final Map<String, double> filmFormats = {
  "65mm 5-Perf": 0.050, "35mm 4-Perf": 0.025, "35mm 3-Perf": 0.025, "35mm 2-Perf": 0.025,
  "16mm Super": 0.013, "16mm Standard": 0.013, "9.5mm": 0.010, "Super 8mm": 0.006, "Standard 8mm": 0.005,
};

class CameraSetupScreen extends StatefulWidget {
  final VoidCallback onLangChange;
  const CameraSetupScreen({super.key, required this.onLangChange});
  
  @override 
  State<CameraSetupScreen> createState() => _CameraSetupScreenState();
}

class _CameraSetupScreenState extends State<CameraSetupScreen> {
  String? mode; 
  String? selectedFormat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _flagBtn("🇪🇸 ", "es"),
                    const SizedBox(width: 20),
                    _flagBtn("🇺🇸 ", "en"),
                    const SizedBox(width: 20),
                    _flagBtn("🇧🇷 ", "pt"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.camera, size: 50, color: Colors.white10),
              const SizedBox(height: 10),
              const Text(
                "ON SET PRO",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 6,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              
              Row(
                children: [
                  _modeCard(t('film'), Icons.movie_creation_outlined, 'film', Colors.amber),
                  const SizedBox(width: 15),
                  _modeCard(t('dig'), Icons.sensor_window_outlined, 'digital', Colors.blueAccent),
                ],
              ),
              
              if (mode != null) ...[
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFormat,
                      isExpanded: true,
                      hint: Text(t('sel_fmt'), style: const TextStyle(color: Colors.white38)),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white24),
                      dropdownColor: const Color(0xFF2C2C2E),
                      items: (mode == 'film' ? filmFormats.keys : digitalSensors.keys)
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e, style: const TextStyle(fontSize: 13, color: Colors.white)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedFormat = v),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: selectedFormat == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => DashboardScreen(
                                sensorName: selectedFormat!,
                                isFilm: mode == 'film',
                                coc: mode == 'film'
                                    ? filmFormats[selectedFormat]!
                                    : digitalSensors[selectedFormat]!,
                              ),
                            ),
                          );
                        },
                  child: Text(t('enter'), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _flagBtn(String flag, String code) {
    return GestureDetector(
      onTap: () {
        lang = code; // Cambiamos el idioma global
        widget.onLangChange(); // Le avisamos al main.dart que recargue TODA la app
      },
      child: Opacity(
        opacity: lang == code ? 1.0 : 0.3,
        child: Text(flag, style: const TextStyle(fontSize: 22)),
      ),
    );
  }

  Widget _modeCard(String txt, IconData i, String v, Color c) {
    bool sel = mode == v;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          mode = v;
          selectedFormat = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 100,
          decoration: BoxDecoration(
            color: sel ? const Color(0xFF2C2C2E) : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: sel ? c.withValues(alpha: 0.5) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(i, color: sel ? c : Colors.white24, size: 30),
              const SizedBox(height: 8),
              Text(
                txt,
                style: TextStyle(
                  color: sel ? Colors.white : Colors.white24,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}