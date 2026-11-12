import 'package:flutter/material.dart';

import 'core/localization.dart';
import 'data/app_settings.dart';
import 'presentation/camera_setup_screen.dart';
import 'presentation/dashboard_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final boot = await AppSettings.load();
  lang = boot.language;
  runApp(OnSetPro(initialCamera: boot.camera));
}

class OnSetPro extends StatelessWidget {
  final SavedCamera? initialCamera;

  const OnSetPro({super.key, this.initialCamera});

  @override
  Widget build(BuildContext context) {
    final camera = initialCamera;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'On Set Pro',
      theme: OnSetTheme.dark(),
      home: camera == null
          ? const CameraSetupScreen()
          : DashboardScreen(
              sensorName: camera.format,
              isFilm: camera.isFilm,
              coc: camera.coc,
            ),
    );
  }
}
