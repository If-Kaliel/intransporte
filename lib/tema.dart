import 'package:flutter/material.dart';

class Cores {
  static const fundo = Color(0xFFF4F7F8);
  static const superficie = Colors.white;
  static const verde = Color(0xFF087E72);
  static const texto = Color(0xFF182629);
  static const textoSuave = Color(0xFF5E7073);
}

ThemeData criarTema() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Cores.fundo,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Cores.verde,
      primary: Cores.verde,
      surface: Cores.superficie,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Cores.fundo,
      foregroundColor: Cores.texto,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Cores.superficie,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Cores.verde,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
