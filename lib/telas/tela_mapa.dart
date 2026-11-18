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
          const _MapaCidadeDemo(),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Arraste para mover, use dois dedos para ampliar e toque nos marcadores. Cidade fictícia.',
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

class _MapaCidadeDemo extends StatefulWidget {
  const _MapaCidadeDemo();

  @override
  State<_MapaCidadeDemo> createState() => _MapaCidadeDemoState();
}

class _MapaCidadeDemoState extends State<_MapaCidadeDemo> {
  late final TransformationController _controlador = TransformationController(
    Matrix4.identity()..translate(-180.0, -100.0),
  );

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 340,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: InteractiveViewer(
              transformationController: _controlador,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(180),
              minScale: 0.65,
              maxScale: 2.8,
              child: SizedBox(
                width: 900,
                height: 640,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: CustomPaint(painter: _CidadeDemoPainter()),
                    ),
                    _rotulo(45, 48, 'Parque das Flores'),
                    _rotulo(345, 48, 'Centro'),
                    _rotulo(645, 48, 'Hospital Municipal'),
                    _rotulo(40, 290, 'Vila Nova'),
                    _rotulo(345, 290, 'Mercado Central'),
                    _rotulo(645, 290, 'Terminal Central'),
                    _rotulo(345, 510, 'Jardim das Árvores'),
                    _marcador(
                      context,
                      215,
                      168,
                      'Ponto da Praça',
                      'Ponto acessível simulado · Linha 203',
                      Icons.accessible,
                      Cores.verde,
                    ),
                    _marcador(
                      context,
                      405,
                      395,
                      'Ponto Central',
                      'Ponto acessível simulado · Linhas 105 e 203',
                      Icons.accessible,
                      Cores.verde,
                    ),
                    _marcador(
                      context,
                      690,
                      180,
                      'Ônibus da Linha 203',
                      'Veículo em trajeto na cidade simulada.',
                      Icons.directions_bus,
                      const Color(0xFFDB7042),
                    ),
                    _marcador(
                      context,
                      755,
                      485,
                      'Ponto do Terminal',
                      'Ponto acessível simulado · Linha 105',
                      Icons.accessible,
                      Cores.verde,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _LegendaMapa(icone: Icons.accessible, texto: 'Ponto acessível'),
            _LegendaMapa(
                icone: Icons.directions_bus, texto: 'Ônibus em trajeto'),
          ],
        ),
      ],
    );
  }

  Widget _rotulo(double left, double top, String texto) {
    return Positioned(
      left: left,
      top: top,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Cores.textoSuave,
            ),
          ),
        ),
      ),
    );
  }

  Widget _marcador(
    BuildContext context,
    double left,
    double top,
    String titulo,
    String detalhe,
    IconData icone,
    Color cor,
  ) {
    return Positioned(
      left: left,
      top: top,
      child: Tooltip(
        message: titulo,
        child: GestureDetector(
          onTap: () => showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            builder: (context) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(detalhe),
                    const SizedBox(height: 8),
                    const Text(
                      'Localização e informações fictícias para demonstração.',
                      style: TextStyle(color: Cores.textoSuave),
                    ),
                  ],
                ),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icone, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Color(0x22000000), blurRadius: 4),
                  ],
                ),
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Cores.texto,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CidadeDemoPainter extends CustomPainter {
  const _CidadeDemoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFEAF0E8), BlendMode.srcOver);

    const blocos = [
      Rect.fromLTWH(28, 28, 215, 158),
      Rect.fromLTWH(305, 30, 112, 72),
      Rect.fromLTWH(430, 30, 116, 72),
      Rect.fromLTWH(305, 116, 112, 72),
      Rect.fromLTWH(430, 116, 116, 72),
      Rect.fromLTWH(596, 30, 245, 158),
      Rect.fromLTWH(28, 254, 215, 169),
      Rect.fromLTWH(305, 254, 241, 169),
      Rect.fromLTWH(596, 254, 245, 169),
      Rect.fromLTWH(28, 484, 215, 128),
      Rect.fromLTWH(305, 484, 241, 128),
      Rect.fromLTWH(596, 484, 245, 128),
    ];
    const coresBlocos = [
      Color(0xFFCBE7C3),
      Color(0xFFF3D9C3),
      Color(0xFFE7DBCE),
      Color(0xFFE4D8C9),
      Color(0xFFF2E1C5),
      Color(0xFFE1E6E8),
      Color(0xFFE2D8CB),
      Color(0xFFF0E5D5),
      Color(0xFFD8E8E2),
      Color(0xFFE8DCCF),
      Color(0xFFCBE7C3),
      Color(0xFFE3DACC),
    ];

    for (var i = 0; i < blocos.length; i++) {
      final forma = RRect.fromRectAndRadius(
        blocos[i],
        const Radius.circular(18),
      );
      canvas.drawRRect(forma, Paint()..color = coresBlocos[i]);
    }

    const edificios = [
      Rect.fromLTWH(318, 42, 44, 42),
      Rect.fromLTWH(372, 42, 34, 42),
      Rect.fromLTWH(438, 42, 92, 34),
      Rect.fromLTWH(318, 112, 44, 42),
      Rect.fromLTWH(372, 112, 46, 42),
      Rect.fromLTWH(438, 105, 92, 48),
      Rect.fromLTWH(615, 50, 72, 46),
      Rect.fromLTWH(705, 50, 115, 46),
      Rect.fromLTWH(615, 112, 92, 48),
      Rect.fromLTWH(725, 112, 94, 48),
      Rect.fromLTWH(42, 275, 72, 52),
      Rect.fromLTWH(130, 275, 85, 52),
      Rect.fromLTWH(40, 344, 92, 52),
      Rect.fromLTWH(145, 344, 70, 52),
      Rect.fromLTWH(615, 275, 82, 48),
      Rect.fromLTWH(710, 275, 110, 48),
      Rect.fromLTWH(615, 345, 100, 52),
      Rect.fromLTWH(728, 345, 92, 52),
      Rect.fromLTWH(42, 505, 82, 40),
      Rect.fromLTWH(140, 505, 74, 40),
      Rect.fromLTWH(615, 505, 105, 42),
      Rect.fromLTWH(735, 505, 84, 42),
    ];
    final corEdificio = Paint()..color = const Color(0xFFF8F5EF);
    final linhaEdificio = Paint()
      ..color = const Color(0xFFD4DCD6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final edificio in edificios) {
      final forma = RRect.fromRectAndRadius(
        edificio,
        const Radius.circular(7),
      );
      canvas.drawRRect(forma, corEdificio);
      canvas.drawRRect(forma, linhaEdificio);
    }

    final ruas = Paint()
      ..color = const Color(0xFFFFFEFA)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 34;
    for (final y in [220.0, 450.0]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), ruas);
    }
    for (final x in [280.0, 570.0]) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), ruas);
    }

    final trajeto = Path()
      ..moveTo(0, 585)
      ..cubicTo(220, 555, 370, 340, 565, 315)
      ..cubicTo(690, 300, 760, 130, 900, 95);
    canvas.drawPath(
      trajeto,
      Paint()
        ..color = const Color(0xFF168B79)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 7,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LegendaMapa extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _LegendaMapa({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 17, color: Cores.verde),
        const SizedBox(width: 5),
        Text(texto, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
