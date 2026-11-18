import 'package:flutter/material.dart';

import '../modelos/linha_onibus.dart';
import '../modelos/ponto_onibus.dart';
import '../servicos/api_servico.dart';
import 'tela_linha_detalhe.dart';

class TelaPontoDetalhe extends StatefulWidget {
  final PontoOnibus ponto;
  final ApiServico api;

  const TelaPontoDetalhe({super.key, required this.ponto, required this.api});

  @override
  State<TelaPontoDetalhe> createState() => _TelaPontoDetalheState();
}

class _TelaPontoDetalheState extends State<TelaPontoDetalhe> {
  late final Future<List<LinhaOnibus>> _linhas =
      widget.api.listarLinhasDoPonto(widget.ponto.id);

  @override
  Widget build(BuildContext context) {
    final ponto = widget.ponto;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do ponto')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text('${ponto.endereco}, ${ponto.numero}'),
              subtitle: Text('Identificador ${ponto.id}'),
            ),
          ),
          const SizedBox(height: 16),
          Text('Linhas vinculadas',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          FutureBuilder<List<LinhaOnibus>>(
            future: _linhas,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Card(
                  child: ListTile(
                    leading: Icon(Icons.error_outline),
                    title: Text('Não foi possível carregar as linhas.'),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final linhas = snapshot.data!;
              if (linhas.isEmpty) {
                return const Card(
                  child: ListTile(title: Text('Nenhuma linha vinculada.')),
                );
              }
              return Column(
                children: linhas
                    .map((linha) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.directions_bus),
                            title: Text(linha.nome),
                            subtitle: Text(linha.descricao),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TelaLinhaDetalhe(linha: linha),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Os dados de acessibilidade ainda não são enviados pela API.',
            style: TextStyle(color: Color(0xFF5E7073), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
