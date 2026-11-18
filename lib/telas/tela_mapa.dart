import 'package:flutter/material.dart';

import '../tema.dart';
import '../servicos/servico_narracao.dart';
import 'tela_pontos.dart';
import 'tela_sobre.dart';

class TelaMapa extends StatelessWidget {
  final ValueChanged<bool> aoMudarTema;
  final bool narracaoAtiva;

  const TelaMapa({
    super.key,
    required this.aoMudarTema,
    required this.narracaoAtiva,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de ônibus'),
        actions: [
          AcaoAlternarTema(aoMudarTema: aoMudarTema),
          IconButton(
            tooltip: 'Sobre o projeto',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TelaSobre(
                  aoMudarTema: aoMudarTema,
                ),
              ),
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Zona Norte de São Paulo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Santana · Carandiru · Vila Maria · Tucuruvi',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          _MapaCidadeDemo(narracaoAtiva: narracaoAtiva),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Mapa ilustrativo baseado em bairros reais. Ônibus e posições são simulados; arraste ou amplie para explorar.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TelaPontos(
                  aoMudarTema: aoMudarTema,
                  narracaoAtiva: narracaoAtiva,
                ),
              ),
            ),
            icon: const Icon(Icons.location_on_outlined),
            label: const Text('Consultar pontos da API'),
          ),
        ],
      ),
    );
  }
}

class _MapaCidadeDemo extends StatefulWidget {
  final bool narracaoAtiva;

  const _MapaCidadeDemo({required this.narracaoAtiva});

  @override
  State<_MapaCidadeDemo> createState() => _MapaCidadeDemoState();
}

class _MapaCidadeDemoState extends State<_MapaCidadeDemo>
    with SingleTickerProviderStateMixin {
  final _narrador = ServicoNarracao();
  static const _rota = [
    Offset(70, 450),
    Offset(278, 450),
    Offset(278, 220),
    Offset(572, 220),
    Offset(572, 450),
    Offset(830, 450),
  ];

  late final TransformationController _controlador = TransformationController(
    Matrix4.identity()..translateByDouble(-180.0, -100.0, 0, 1),
  );
  late final AnimationController _animacao = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() {
    _animacao.dispose();
    _controlador.dispose();
    super.dispose();
  }

  Offset _posicaoOnibus(double progresso) {
    final escala = progresso * (_rota.length - 1);
    final trecho = escala.floor().clamp(0, _rota.length - 2).toInt();
    return Offset.lerp(_rota[trecho], _rota[trecho + 1], escala - trecho)!;
  }

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        SizedBox(
          height: 370,
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
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CidadeDemoPainter(escuro: escuro),
                      ),
                    ),
                    _rotulo(context, 52, 60, 'TUCURUVI'),
                    _rotulo(context, 342, 56, 'JARDIM SÃO PAULO'),
                    _rotulo(context, 654, 64, 'VILA MARIA'),
                    _rotulo(context, 54, 286, 'SANTANA'),
                    _rotulo(context, 347, 286, 'ALTO DE SANTANA'),
                    _rotulo(context, 652, 286, 'VILA GUILHERME'),
                    _rotulo(context, 347, 520, 'CARANDIRU'),
                    _marcador(
                      context,
                      190,
                      180,
                      'Metrô Tucuruvi',
                      'Estação fictícia no mapa de demonstração.',
                      Icons.train,
                      const Color(0xFF587BB8),
                    ),
                    _marcador(
                      context,
                      465,
                      174,
                      'Ponto Santana',
                      'Parada simulada com acessibilidade · Linha 203.',
                      Icons.accessible,
                      Cores.verde,
                    ),
                    _marcador(
                      context,
                      710,
                      402,
                      'Ponto Vila Maria',
                      'Parada simulada com acessibilidade · Linha 105.',
                      Icons.accessible,
                      Cores.verde,
                    ),
                    _marcador(
                      context,
                      245,
                      420,
                      'Parque da Juventude',
                      'Área verde próxima ao Carandiru.',
                      Icons.park,
                      const Color(0xFF53885C),
                    ),
                    AnimatedBuilder(
                      animation: _animacao,
                      builder: (context, child) {
                        final posicao = _posicaoOnibus(_animacao.value);
                        return Positioned(
                          left: posicao.dx - 23,
                          top: posicao.dy - 23,
                          child: child!,
                        );
                      },
                      child: _marcadorOnibus(context),
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
            _LegendaMapa(icone: Icons.directions_bus, texto: 'Ônibus simulado'),
            _LegendaMapa(icone: Icons.train, texto: 'Metrô'),
          ],
        ),
      ],
    );
  }

  Widget _rotulo(BuildContext context, double left, double top, String texto) {
    final cores = Theme.of(context).colorScheme;
    return Positioned(
      left: left,
      top: top,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cores.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cores.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: cores.onSurfaceVariant,
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
      child: _iconeMapa(context, titulo, detalhe, icone, cor),
    );
  }

  Widget _iconeMapa(
    BuildContext context,
    String titulo,
    String detalhe,
    IconData icone,
    Color cor,
  ) {
    final cores = Theme.of(context).colorScheme;
    return Tooltip(
      message: titulo,
      child: GestureDetector(
        onTap: () {
          if (widget.narracaoAtiva) _narrar('$titulo. $detalhe');
          _mostrarDetalhe(context, titulo, detalhe);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cor,
                shape: BoxShape.circle,
                border: Border.all(color: cores.surface, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icone, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: cores.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Color(0x22000000), blurRadius: 4),
                ],
              ),
              child: Text(
                titulo,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: cores.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _marcadorOnibus(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.narracaoAtiva) {
          _narrar(
            'Ônibus da linha 203 em trajeto simulado pela Zona Norte.',
          );
        }
        _mostrarDetalhe(
          context,
          'Ônibus da Linha 203',
          'Veículo animado em um trajeto simulado pela Zona Norte.',
        );
      },
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFDB7042),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 9,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.directions_bus, color: Colors.white),
      ),
    );
  }

  void _mostrarDetalhe(BuildContext context, String titulo, String detalhe) {
    showModalBottomSheet<void>(
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
              Text(
                'Posição e informações são simuladas para a demonstração.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _narrar(String texto) async {
    try {
      await _narrador.falar(texto);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A narração não está disponível neste dispositivo.'),
        ),
      );
    }
  }
}

class _CidadeDemoPainter extends CustomPainter {
  final bool escuro;

  const _CidadeDemoPainter({required this.escuro});

  @override
  void paint(Canvas canvas, Size size) {
    final fundo = escuro ? const Color(0xFF192523) : const Color(0xFFE9EFE8);
    final quadra = escuro ? const Color(0xFF293431) : const Color(0xFFE2DED3);
    final predio = escuro ? const Color(0xFF3B4843) : const Color(0xFFF8F5EF);
    final contorno = escuro ? const Color(0xFF56645E) : const Color(0xFFD1D8D0);
    final rua = escuro ? const Color(0xFF46504C) : const Color(0xFFFDFCF8);
    final textoRua = escuro ? const Color(0xFFB2BDB7) : const Color(0xFF7B8980);
    canvas.drawColor(fundo, BlendMode.srcOver);

    final tintaQuadra = Paint()..color = quadra;
    final tintaPredio = Paint()..color = predio;
    final tintaContorno = Paint()
      ..color = contorno
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const quadras = [
      Rect.fromLTWH(28, 28, 218, 156),
      Rect.fromLTWH(306, 30, 112, 72),
      Rect.fromLTWH(432, 30, 116, 72),
      Rect.fromLTWH(306, 116, 112, 72),
      Rect.fromLTWH(432, 116, 116, 72),
      Rect.fromLTWH(600, 30, 244, 154),
      Rect.fromLTWH(28, 254, 218, 168),
      Rect.fromLTWH(306, 254, 242, 168),
      Rect.fromLTWH(600, 254, 244, 168),
      Rect.fromLTWH(28, 484, 218, 126),
      Rect.fromLTWH(306, 484, 242, 126),
      Rect.fromLTWH(600, 484, 244, 126),
    ];
    for (final quadra in quadras) {
      final forma = RRect.fromRectAndRadius(quadra, const Radius.circular(16));
      canvas.drawRRect(forma, tintaQuadra);
    }

    // Parque da Juventude, ao lado da antiga área do Carandiru.
    final parque = RRect.fromRectAndRadius(
      const Rect.fromLTWH(42, 274, 78, 132),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      parque,
      Paint()
        ..color = escuro ? const Color(0xFF31543E) : const Color(0xFFBBD6B3),
    );
    for (final arvore in [
      const Offset(61, 300),
      const Offset(96, 319),
      const Offset(69, 362),
      const Offset(101, 384),
    ]) {
      canvas.drawCircle(
        arvore,
        8,
        Paint()
          ..color = escuro ? const Color(0xFF6F9C6C) : const Color(0xFF83AD79),
      );
    }

    final ruas = Paint()
      ..color = rua
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 38;
    for (final y in [220.0, 450.0]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), ruas);
    }
    for (final x in [278.0, 572.0]) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), ruas);
    }
    final faixa = Paint()
      ..color = escuro ? const Color(0xFF707A74) : const Color(0xFFD6D5CE)
      ..strokeWidth = 2;
    for (var x = 12.0; x < size.width; x += 42) {
      canvas.drawLine(Offset(x, 220), Offset(x + 20, 220), faixa);
      canvas.drawLine(Offset(x, 450), Offset(x + 20, 450), faixa);
    }
    for (var y = 12.0; y < size.height; y += 42) {
      canvas.drawLine(Offset(278, y), Offset(278, y + 20), faixa);
      canvas.drawLine(Offset(572, y), Offset(572, y + 20), faixa);
    }

    const edificios = [
      Rect.fromLTWH(320, 42, 40, 43),
      Rect.fromLTWH(370, 42, 36, 43),
      Rect.fromLTWH(442, 42, 42, 42),
      Rect.fromLTWH(492, 42, 44, 42),
      Rect.fromLTWH(320, 114, 40, 44),
      Rect.fromLTWH(370, 114, 36, 44),
      Rect.fromLTWH(442, 112, 42, 48),
      Rect.fromLTWH(492, 112, 44, 48),
      Rect.fromLTWH(620, 46, 68, 48),
      Rect.fromLTWH(704, 46, 122, 48),
      Rect.fromLTWH(620, 112, 92, 48),
      Rect.fromLTWH(730, 112, 96, 48),
      Rect.fromLTWH(134, 274, 92, 54),
      Rect.fromLTWH(134, 344, 92, 54),
      Rect.fromLTWH(320, 274, 86, 54),
      Rect.fromLTWH(420, 274, 108, 54),
      Rect.fromLTWH(320, 344, 88, 54),
      Rect.fromLTWH(422, 344, 106, 54),
      Rect.fromLTWH(620, 274, 90, 52),
      Rect.fromLTWH(724, 274, 102, 52),
      Rect.fromLTWH(620, 344, 90, 54),
      Rect.fromLTWH(724, 344, 102, 54),
      Rect.fromLTWH(44, 504, 82, 40),
      Rect.fromLTWH(142, 504, 84, 40),
      Rect.fromLTWH(320, 504, 92, 42),
      Rect.fromLTWH(426, 504, 102, 42),
      Rect.fromLTWH(620, 504, 92, 42),
      Rect.fromLTWH(728, 504, 98, 42),
    ];
    for (final edificio in edificios) {
      final forma = RRect.fromRectAndRadius(edificio, const Radius.circular(6));
      canvas.drawRRect(forma, tintaPredio);
      canvas.drawRRect(forma, tintaContorno);
    }

    _texto(canvas, 'Av. Cruzeiro do Sul', const Offset(282, 312), textoRua);
    _texto(canvas, 'Av. Zaki Narchi', const Offset(576, 300), textoRua);

    final caminho = Path()
      ..moveTo(_MapaCidadeDemoState._rota.first.dx,
          _MapaCidadeDemoState._rota.first.dy);
    for (final ponto in _MapaCidadeDemoState._rota.skip(1)) {
      caminho.lineTo(ponto.dx, ponto.dy);
    }
    canvas.drawPath(
      caminho,
      Paint()
        ..color = const Color(0xFF138B78)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 8,
    );
    for (final parada in [
      _MapaCidadeDemoState._rota[1],
      _MapaCidadeDemoState._rota[3],
      _MapaCidadeDemoState._rota[5],
    ]) {
      canvas.drawCircle(parada, 6, Paint()..color = const Color(0xFFFFFEFA));
      canvas.drawCircle(
        parada,
        4,
        Paint()
          ..color = const Color(0xFF138B78)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _texto(Canvas canvas, String texto, Offset posicao, Color cor) {
    final painter = TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(
          color: cor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(posicao.dx, posicao.dy);
    canvas.rotate(-1.5708);
    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CidadeDemoPainter oldDelegate) =>
      oldDelegate.escuro != escuro;
}

class _LegendaMapa extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _LegendaMapa({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 17, color: cores.primary),
        const SizedBox(width: 5),
        Text(
          texto,
          style: TextStyle(fontSize: 12, color: cores.onSurfaceVariant),
        ),
      ],
    );
  }
}
