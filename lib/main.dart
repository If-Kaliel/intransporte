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

  void _mudarLetras(bool valor) {
    setState(() {
      _letrasMaiores = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INTransporte',
      debugShowCheckedModeBanner: false,
      theme: criarTema(),
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
      ),
    );
  }
}
