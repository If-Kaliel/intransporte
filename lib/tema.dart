import 'package:flutter/material.dart';

class Cores {
  static const fundo = Color(0xFFF4F7F8);
  static const superficie = Colors.white;
  static const verde = Color(0xFF087E72);
  static const texto = Color(0xFF182629);
  static const textoSuave = Color(0xFF5E7073);
}

class AcaoAlternarTema extends StatelessWidget {
  final ValueChanged<bool> aoMudarTema;

  const AcaoAlternarTema({super.key, required this.aoMudarTema});

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: escuro ? 'Ativar tema claro' : 'Ativar tema escuro',
      onPressed: () => aoMudarTema(!escuro),
      icon: Icon(escuro ? Icons.light_mode : Icons.dark_mode),
    );
  }
}

ThemeData criarTema({bool escuro = false, bool altoContraste = false}) {
  var esquema = ColorScheme.fromSeed(
    seedColor: Cores.verde,
    brightness: escuro ? Brightness.dark : Brightness.light,
  ).copyWith(
    primary: escuro ? const Color(0xFF55C7B1) : Cores.verde,
    surface: escuro ? const Color(0xFF1B2827) : Cores.superficie,
  );

  if (altoContraste) {
    esquema = esquema.copyWith(
      primary: escuro ? const Color(0xFFFFFF00) : Colors.black,
      onPrimary: escuro ? Colors.black : Colors.white,
      secondary: escuro ? const Color(0xFFFFFF00) : Colors.black,
      onSecondary: escuro ? Colors.black : Colors.white,
      surface: escuro ? Colors.black : Colors.white,
      onSurface: escuro ? Colors.white : Colors.black,
      outline: escuro ? Colors.white : Colors.black,
      outlineVariant:
          escuro ? const Color(0xFFBDBDBD) : const Color(0xFF424242),
    );
  }

  return ThemeData(
    useMaterial3: true,
    brightness: escuro ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: altoContraste
        ? (escuro ? Colors.black : Colors.white)
        : (escuro ? const Color(0xFF101918) : Cores.fundo),
    colorScheme: esquema,
    appBarTheme: AppBarTheme(
      backgroundColor: altoContraste
          ? (escuro ? Colors.black : Colors.white)
          : (escuro ? const Color(0xFF101918) : Cores.fundo),
      foregroundColor: esquema.onSurface,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: esquema.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: altoContraste
            ? BorderSide(color: esquema.outline, width: 2)
            : BorderSide.none,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: esquema.outline,
          width: altoContraste ? 2 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: esquema.primary, width: 2),
      ),
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
