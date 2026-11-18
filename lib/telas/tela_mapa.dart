import 'dart:io';

import 'package:flutter/material.dart';

import '../modelos/linha_onibus.dart';
import '../modelos/ponto_onibus.dart';
import '../servicos/api_servico.dart';
import '../tema.dart';

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final _api = ApiServico();
  final _loginController = TextEditingController();
  final _senhaController = TextEditingController();
  final _enderecoController = TextEditingController();

  List<PontoOnibus> _pontos = [];
  Map<String, dynamic>? _pagina;
  String? _erro;
  bool _carregando = false;
  bool _conectado = false;
  int? _pontoCarregando;
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
    if (!_conectado &&
        (_loginController.text.trim().isEmpty ||
            _senhaController.text.isEmpty)) {
      setState(() => _erro = 'Informe login e senha para consultar a API.');
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
    if (erro is HttpException) {
      return 'A API retornou um erro: ${erro.message}';
    }
    return 'Não foi possível carregar os pontos: $erro';
  }

  Future<void> _abrirLinhas(PontoOnibus ponto) async {
    setState(() => _pontoCarregando = ponto.id);
    try {
      final linhas = await _api.listarLinhasDoPonto(ponto.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Linhas em ${ponto.endereco}, ${ponto.numero}'),
          content: linhas.isEmpty
              ? const Text('Nenhuma linha está vinculada a este ponto.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: linhas.length,
                      separatorBuilder: (_, index) => const Divider(),
                      itemBuilder: (context, index) =>
                          _itemLinha(linhas[index]),
                    ),
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mensagemErro(erro))),
      );
    } finally {
      if (mounted) setState(() => _pontoCarregando = null);
    }
  }

  Widget _itemLinha(LinhaOnibus linha) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.directions_bus, color: Cores.verde),
      title: Text(linha.nome),
      subtitle: Text(
        '${linha.descricao}\n'
        'Intervalo: ${linha.intervaloMinutos?.toString() ?? 'não informado'} min',
      ),
      isThreeLine: true,
    );
  }

  Widget _cartaoPonto(PontoOnibus ponto) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Cores.verde),
        title: Text('${ponto.endereco}, ${ponto.numero}'),
        subtitle: Text('Ponto ${ponto.id} · toque para consultar as linhas'),
        trailing: _pontoCarregando == ponto.id
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right),
        onTap: _pontoCarregando == null ? () => _abrirLinhas(ponto) : null,
      ),
    );
  }

  Widget _controlesPaginacao() {
    final totalPaginas = (_pagina?['totalPages'] as num?)?.toInt() ?? 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Página anterior',
          onPressed: _carregando || _paginaAtual == 0
              ? null
              : () => _carregarPontos(pagina: _paginaAtual - 1),
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          totalPaginas == 0
              ? 'Sem páginas'
              : 'Página ${_paginaAtual + 1} de $totalPaginas',
        ),
        IconButton(
          tooltip: 'Próxima página',
          onPressed: _carregando || _paginaAtual + 1 >= totalPaginas
              ? null
              : () => _carregarPontos(pagina: _paginaAtual + 1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

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
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Prévia ilustrativa; a API ainda não fornece coordenadas.',
              style: TextStyle(color: Cores.textoSuave, fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Pontos da API',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (!_conectado) _cartaoLogin(),
          if (_conectado) _campoFiltro(),
          if (_erro != null) _avisoErro(),
          if (_carregando) const LinearProgressIndicator(),
          if (_conectado && !_carregando && _pontos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Nenhum ponto encontrado.'),
            ),
          ..._pontos.map(_cartaoPonto),
          if (_conectado) _controlesPaginacao(),
          const SizedBox(height: 8),
          const Text(
            'Os dados de acessibilidade ainda não são enviados pela API.',
            style: TextStyle(color: Cores.textoSuave, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _cartaoLogin() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Entre para carregar os pontos da API.'),
            const SizedBox(height: 12),
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(labelText: 'Login'),
              textCapitalization: TextCapitalization.none,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
              onSubmitted: (_) => _carregarPontos(),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _carregando ? null : _carregarPontos,
              icon: const Icon(Icons.cloud_download_outlined),
              label: const Text('Conectar e carregar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoFiltro() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
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
    );
  }

  Widget _avisoErro() {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          _erro!,
          style:
              TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
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
          const Positioned(
              left: 36,
              top: 78,
              child: _MarcadorMapa(icone: Icons.location_on)),
          const Positioned(
              right: 40,
              top: 116,
              child: _MarcadorMapa(icone: Icons.directions_bus)),
          const Positioned(
              left: 22,
              bottom: 16,
              child: Text('Prévia ilustrativa do trajeto')),
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
