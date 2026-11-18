import 'package:flutter/material.dart';

import '../modelos/linha_onibus.dart';

class TelaLinhaDetalhe extends StatelessWidget {
  final LinhaOnibus linha;

  const TelaLinhaDetalhe({super.key, required this.linha});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da linha')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.directions_bus, size: 40),
                const SizedBox(height: 16),
                Text(linha.nome,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(linha.descricao),
                const SizedBox(height: 16),
                Text('Identificador: ${linha.id}'),
                const SizedBox(height: 8),
                Text(
                  'Intervalo: ${linha.intervaloMinutos?.toString() ?? 'não informado'} min',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
