import 'package:flutter/material.dart';

import 'telas/tela_inicial.dart';
import 'tema.dart';

void main() {
  runApp(const INTransporteApp());
}

class INTransporteApp extends StatefulWidget {
  const INTransporteApp({super.key});

  @override
  State<INTransporteApp> createState() => _INTransporteAppState();
}

class _INTransporteAppState extends State<INTransporteApp> {
  bool _letrasMaiores = false;
  bool _temaEscuro = false;
  bool _altoContraste = false;
  bool _narracaoAtiva = false;

  void _mudarLetras(bool valor) {
    setState(() {
      _letrasMaiores = valor;
    });
  }

  void _mudarTema(bool valor) {
    setState(() {
      _temaEscuro = valor;
    });
  }

  void _mudarAltoContraste(bool valor) {
    setState(() {
      _altoContraste = valor;
    });
  }

  void _mudarNarracao(bool valor) {
    setState(() {
      _narracaoAtiva = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INTransporte',
      debugShowCheckedModeBanner: false,
      theme: criarTema(altoContraste: _altoContraste),
      darkTheme: criarTema(escuro: true, altoContraste: _altoContraste),
      themeMode: _temaEscuro ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        if (!_letrasMaiores) {
          return child!;
        }

        final escala = MediaQuery.textScalerOf(context);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: escala.clamp(minScaleFactor: 1.3),
          ),
          child: child!,
        );
      },
      home: TelaInicial(
        letrasMaiores: _letrasMaiores,
        aoMudarLetras: _mudarLetras,
        temaEscuro: _temaEscuro,
        aoMudarTema: _mudarTema,
        altoContraste: _altoContraste,
        aoMudarAltoContraste: _mudarAltoContraste,
        narracaoAtiva: _narracaoAtiva,
        aoMudarNarracao: _mudarNarracao,
      ),
    );
  }
}
