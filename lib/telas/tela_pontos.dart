import 'dart:io';

import 'package:flutter/material.dart';

import '../modelos/ponto_onibus.dart';
import '../servicos/api_servico.dart';
import 'tela_ponto_detalhe.dart';

class TelaPontos extends StatefulWidget {
  const TelaPontos({super.key});

  @override
  State<TelaPontos> createState() => _TelaPontosState();
}

class _TelaPontosState extends State<TelaPontos> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiServico();
  final _loginController = TextEditingController();
  final _senhaController = TextEditingController();
  final _enderecoController = TextEditingController();
  List<PontoOnibus> _pontos = [];
  Map<String, dynamic>? _pagina;
  String? _erro;
  bool _carregando = false;
  bool _conectado = false;
  int _paginaAtual = 0;

  @override
  void dispose() {
    _api.fechar();
    _loginController.dispose();
    _senhaController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  Future<void> _carregarPontos({int pagina = 0}) async {
    if (!_conectado && !_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      if (!_conectado) {
        await _api.login(
          login: _loginController.text.trim(),
          senha: _senhaController.text,
        );
      }
      final resultado = await _api.listarPontos(
        pagina: pagina,
        endereco: _enderecoController.text,
      );
      if (!mounted) return;
      setState(() {
        _conectado = true;
        _pontos = resultado.pontos;
        _pagina = resultado.pagina;
        _paginaAtual = pagina;
        _senhaController.clear();
        _loginController.clear();
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() => _erro = _mensagemErro(erro));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  String _mensagemErro(Object erro) {
    if (erro is SocketException) {
      return 'Não foi possível acessar a API. Confira se ela está rodando.';
    }
    if (erro is HttpException) return 'A API retornou um erro: ${erro.message}';
    return 'Não foi possível carregar os pontos: $erro';
  }

  void _abrirPonto(PontoOnibus ponto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaPontoDetalhe(ponto: ponto, api: _api),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPaginas = (_pagina?['totalPages'] as num?)?.toInt() ?? 1;
    return Scaffold(
      appBar: AppBar(title: const Text('Pontos de ônibus')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(_conectado ? 'Busque pontos cadastrados' : 'Acesso à API',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (!_conectado) ...[
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  TextFormField(
                    controller: _loginController,
                    decoration: const InputDecoration(labelText: 'Login'),
                    textCapitalization: TextCapitalization.none,
                    validator: (valor) => valor == null || valor.trim().isEmpty
                        ? 'Informe o login.'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _senhaController,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                    onFieldSubmitted: (_) => _carregarPontos(),
                    validator: (valor) => valor == null || valor.isEmpty
                        ? 'Informe a senha.'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _carregando ? null : _carregarPontos,
              icon: const Icon(Icons.cloud_download_outlined),
              label: const Text('Conectar e carregar'),
            ),
          ] else ...[
            TextField(
              controller: _enderecoController,
              decoration: InputDecoration(
                labelText: 'Filtrar por endereço',
                suffixIcon: IconButton(
                  tooltip: 'Buscar pontos',
                  onPressed: _carregando ? null : () => _carregarPontos(),
                  icon: const Icon(Icons.search),
                ),
              ),
              onSubmitted: (_) => _carregarPontos(),
            ),
          ],
          if (_erro != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_erro!),
              ),
            ),
          ],
          if (_carregando) const LinearProgressIndicator(),
          if (_conectado && !_carregando && _pontos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Nenhum ponto encontrado.'),
            ),
          ..._pontos.map((ponto) => Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text('${ponto.endereco}, ${ponto.numero}'),
                  subtitle:
                      Text('Ponto ${ponto.id} · toque para ver as linhas'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _abrirPonto(ponto),
                ),
              )),
          if (_conectado)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Página anterior',
                  onPressed: _carregando || _paginaAtual == 0
                      ? null
                      : () => _carregarPontos(pagina: _paginaAtual - 1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(totalPaginas == 0
                    ? 'Sem páginas'
                    : 'Página ${_paginaAtual + 1} de $totalPaginas'),
                IconButton(
                  tooltip: 'Próxima página',
                  onPressed: _carregando || _paginaAtual + 1 >= totalPaginas
                      ? null
                      : () => _carregarPontos(pagina: _paginaAtual + 1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          const SizedBox(height: 8),
          const Text(
            'A API ainda não envia informações de acessibilidade dos pontos.',
            style: TextStyle(color: Color(0xFF5E7073), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
