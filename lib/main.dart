import 'package:flutter/material.dart';

import 'telas/tela_inicial.dart';
import 'tema.dart';

void main() {
  runApp(const INTransporteApp());
}

class INTransporteApp extends StatelessWidget {
  const INTransporteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INTransporte',
      debugShowCheckedModeBanner: false,
      theme: criarTema(),
      home: const TelaInicial(),
    );
  }
}
