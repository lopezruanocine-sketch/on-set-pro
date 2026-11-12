import 'package:flutter/material.dart';

import 'core/localization.dart';
import 'data/app_settings.dart';
import 'data/camera_selection.dart';
import 'presentation/camera_setup_screen.dart';
import 'presentation/dashboard_screen.dart';
import 'state/shot_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final boot = await AppSettings.load();
  lang = boot.language;
  final camera = boot.camera;
  if (camera != null) ShotState.instance.setCamera(camera);
  runApp(OnSetPro(initialCamera: boot.camera));
}

class OnSetPro extends StatelessWidget {
  final CameraSelection? initialCamera;

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
          : DashboardScreen(selection: camera),
    );
  }
}
