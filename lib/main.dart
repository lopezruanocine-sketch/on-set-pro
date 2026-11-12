import 'package:flutter/material.dart';
import 'presentation/camera_setup_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OnSetPro());
}

class OnSetPro extends StatefulWidget {
  const OnSetPro({super.key});

  @override
  State<OnSetPro> createState() => _OnSetProState();
}

class _OnSetProState extends State<OnSetPro> {
  void updateLanguage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'On Set Pro',
      theme: ThemeData.dark().copyWith(
        // Restaurado al negro de Kaan Cine
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFFD700),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
      ),
      // Lanzamos la pantalla de la cámara
      home: CameraSetupScreen(onLangChange: updateLanguage),
    );
  }
}
