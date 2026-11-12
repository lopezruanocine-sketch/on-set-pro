import 'package:flutter/material.dart';

/// Sistema de diseño de On Set Pro.
///
/// Regla del proyecto:
///  - El dorado es la marca: acción principal, selección y resultado.
///  - Los colores de departamento sólo identifican a qué área pertenece cada
///    herramienta (cámara, imagen, electricidad, data, utilidades).
class OnSetColors {
  OnSetColors._();

  // --- Base ---
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const surfaceHigh = Color(0xFF2C2C2E);

  // --- Marca ---
  static const brand = Color(0xFFFFD700);

  // --- Texto ---
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0x8AFFFFFF); // white54
  static const textMuted = Color(0x61FFFFFF); // white38
  static const divider = Color(0x1AFFFFFF); // white10

  // --- Semánticos ---
  static const ok = Color(0xFF4CAF50);
  static const warn = Color(0xFFFFD700);
  static const danger = Color(0xFFE57373);

  // --- Departamentos (biblia, GDD v3.0) ---
  static const camera = Color(0xFF4E9AF1); // cámara / óptica
  static const image = Color(0xFFE57373); // imagen / exposición
  static const power = Color(0xFFFFB300); // electricidad
  static const data = Color(0xFF66BB6A); // data / producción
  static const tools = Color(0xFFFF8A50); // utilidades
}

class OnSetTheme {
  OnSetTheme._();

  static ThemeData dark() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: OnSetColors.background,
      primaryColor: OnSetColors.brand,
      cardColor: OnSetColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: OnSetColors.background,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
