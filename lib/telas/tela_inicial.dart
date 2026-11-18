import 'package:flutter/material.dart';

import 'tela_mapa.dart';
import '../tema.dart';

class TelaInicial extends StatelessWidget {
  final bool letrasMaiores;
  final ValueChanged<bool> aoMudarLetras;
  final bool temaEscuro;
  final ValueChanged<bool> aoMudarTema;
  final bool altoContraste;
  final ValueChanged<bool> aoMudarAltoContraste;
  final bool narracaoAtiva;
  final ValueChanged<bool> aoMudarNarracao;

  const TelaInicial({
    super.key,
    required this.letrasMaiores,
    required this.aoMudarLetras,
    required this.temaEscuro,
    required this.aoMudarTema,
    required this.altoContraste,
    required this.aoMudarAltoContraste,
    required this.narracaoAtiva,
    required this.aoMudarNarracao,
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
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.accessible,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Mobilidade para todos'),
                    subtitle: const Text(
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
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.contrast),
                    title: const Text('Alto contraste'),
                    subtitle: const Text('Reforça o contraste de cores'),
                    value: altoContraste,
                    onChanged: aoMudarAltoContraste,
                  ),
                ),
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.record_voice_over_outlined),
                    title: const Text('Narrar pontos'),
                    subtitle: const Text(
                      'Ativa a leitura em voz alta dos pontos selecionados',
                    ),
                    value: narracaoAtiva,
                    onChanged: aoMudarNarracao,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TelaMapa(
                          aoMudarTema: aoMudarTema,
                          narracaoAtiva: narracaoAtiva,
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
