import 'package:flutter/material.dart';

import 'tela_mapa.dart';
import '../tema.dart';

class TelaInicial extends StatelessWidget {
  final bool letrasMaiores;
  final ValueChanged<bool> aoMudarLetras;
  final bool temaEscuro;
  final ValueChanged<bool> aoMudarTema;

  const TelaInicial({
    super.key,
    required this.letrasMaiores,
    required this.aoMudarLetras,
    required this.temaEscuro,
    required this.aoMudarTema,
  });

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
                Text(
                  'Acompanhe os ônibus em trajeto e encontre pontos com acessibilidade.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.accessible, color: Cores.verde),
                    title: Text('Mobilidade para todos'),
                    subtitle: Text(
                      'Consulte pontos acessíveis perto de você.',
                    ),
                  ),
                ),
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.text_increase),
                    title: const Text('Letras maiores'),
                    subtitle: const Text('Aumenta o texto do aplicativo'),
                    value: letrasMaiores,
                    onChanged: aoMudarLetras,
                  ),
                ),
                Card(
                  child: SwitchListTile(
                    secondary: Icon(
                      temaEscuro ? Icons.dark_mode : Icons.light_mode,
                    ),
                    title: const Text('Tema escuro'),
                    subtitle:
                        const Text('Alterna entre aparência clara e escura'),
                    value: temaEscuro,
                    onChanged: aoMudarTema,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TelaMapa(
                          temaEscuro: temaEscuro,
                          aoMudarTema: aoMudarTema,
                        ),
                      ),
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
