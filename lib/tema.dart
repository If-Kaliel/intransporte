import 'package:flutter/material.dart';

class Cores {
  static const fundo = Color(0xFFF4F7F8);
  static const superficie = Colors.white;
  static const verde = Color(0xFF087E72);
  static const texto = Color(0xFF182629);
  static const textoSuave = Color(0xFF5E7073);
}

ThemeData criarTema({bool escuro = false}) {
  final esquema = ColorScheme.fromSeed(
    seedColor: Cores.verde,
    brightness: escuro ? Brightness.dark : Brightness.light,
  ).copyWith(
    primary: escuro ? const Color(0xFF55C7B1) : Cores.verde,
    surface: escuro ? const Color(0xFF1B2827) : Cores.superficie,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: escuro ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: escuro ? const Color(0xFF101918) : Cores.fundo,
    colorScheme: esquema,
    appBarTheme: AppBarTheme(
      backgroundColor: escuro ? const Color(0xFF101918) : Cores.fundo,
      foregroundColor: esquema.onSurface,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: esquema.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
