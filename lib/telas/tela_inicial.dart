import 'package:flutter/material.dart';

import 'tela_mapa.dart';
import '../tema.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.directions_bus, size: 76, color: Cores.verde),
                const SizedBox(height: 24),
                const Text(
                  'INTransporte',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Acompanhe os ônibus em trajeto e encontre pontos com acessibilidade.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Cores.textoSuave, fontSize: 16),
                ),
                const SizedBox(height: 32),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.accessible, color: Cores.verde),
                    title: const Text('Mobilidade para todos'),
                    subtitle: const Text(
                      'Consulte pontos acessíveis perto de você.',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TelaMapa()),
                    );
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Abrir mapa'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
