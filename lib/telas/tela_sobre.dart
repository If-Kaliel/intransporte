import 'package:flutter/material.dart';

import '../tema.dart';

class TelaSobre extends StatelessWidget {
  final ValueChanged<bool> aoMudarTema;

  const TelaSobre({super.key, required this.aoMudarTema});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o INTransporte'),
        actions: [AcaoAlternarTema(aoMudarTema: aoMudarTema)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Icon(Icons.directions_bus, size: 64),
          SizedBox(height: 16),
          Text(
            'INTransporte',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Projeto acadêmico de transporte público acessível. O aplicativo apresenta uma demonstração de mapa e consulta pontos e linhas fornecidos pela API do grupo.',
          ),
          SizedBox(height: 16),
          Text(
            'O mapa desta versão usa dados fictícios e a API ainda não fornece coordenadas nem informações de acessibilidade.',
          ),
        ],
      ),
    );
  }
}
