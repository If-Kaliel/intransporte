import 'package:flutter/material.dart';

import '../tema.dart';

class TelaMapa extends StatelessWidget {
  const TelaMapa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de ônibus')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Ônibus em trajeto',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const _MapaIlustrativo(),
          const SizedBox(height: 24),
          const Text(
            'Pontos acessíveis',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const _PontoAcessivel(
            nome: 'Av. Central, 120',
            detalhe: 'Linha 203 · ônibus a 4 min',
          ),
          const _PontoAcessivel(
            nome: 'Praça da Estação',
            detalhe: 'Linha 105 · ônibus a 9 min',
          ),
          const SizedBox(height: 8),
          const Text(
            'Demonstração com dados de exemplo.',
            style: TextStyle(color: Cores.textoSuave, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _MapaIlustrativo extends StatelessWidget {
  const _MapaIlustrativo();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFE1ECE9),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 22,
            right: 22,
            top: 105,
            child: Container(height: 8, color: Cores.verde),
          ),
          const Positioned(left: 36, top: 78, child: _MarcadorMapa(icone: Icons.location_on)),
          const Positioned(right: 40, top: 116, child: _MarcadorMapa(icone: Icons.directions_bus)),
          const Positioned(left: 22, bottom: 16, child: Text('Prévia ilustrativa do trajeto')),
        ],
      ),
    );
  }
}

class _MarcadorMapa extends StatelessWidget {
  final IconData icone;

  const _MarcadorMapa({required this.icone});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      foregroundColor: Cores.verde,
      child: Icon(icone),
    );
  }
}

class _PontoAcessivel extends StatelessWidget {
  final String nome;
  final String detalhe;

  const _PontoAcessivel({required this.nome, required this.detalhe});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.accessible, color: Cores.verde),
        title: Text(nome),
        subtitle: Text(detalhe),
      ),
    );
  }
}
