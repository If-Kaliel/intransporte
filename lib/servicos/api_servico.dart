import 'dart:convert';
import 'dart:io';

class ResultadoPontos {
  const ResultadoPontos({required this.pontos, required this.pagina});

  final List<Map<String, dynamic>> pontos;
  final Map<String, dynamic>? pagina;
}

class ApiServico {
  ApiServico({required this.urlBase, HttpClient? cliente})
    : _cliente = cliente ?? HttpClient();

  final Uri urlBase;
  final HttpClient _cliente;
  String? _token;

  Future<void> login({required String login, required String senha}) async {
    final resposta = await _requisitar(
      'POST',
      '/auth/login',
      corpo: {'login': login, 'senha': senha},
    );

    if (resposta is! Map<String, dynamic> || resposta['token'] is! String) {
      throw const FormatException('A resposta do login não contém um token.');
    }

    _token = resposta['token'] as String;
  }

  Future<ResultadoPontos> listarPontos() async {
    final resposta = await _requisitar(
      'GET',
      '/api/pontos',
      requerToken: true,
    );

    if (resposta is! Map<String, dynamic>) {
      throw const FormatException('A resposta de pontos não é um objeto HAL.');
    }

    final embedded = resposta['_embedded'];
    if (embedded is! Map<String, dynamic> || embedded['pontos'] is! List) {
      throw const FormatException('A resposta HAL não contém _embedded.pontos.');
    }

    final pontos = (embedded['pontos'] as List).map((ponto) {
      if (ponto is! Map<String, dynamic>) {
        throw const FormatException('Um ponto da resposta não é um objeto.');
      }
      return ponto;
    }).toList(growable: false);

    final pagina = resposta['page'];
    if (pagina != null && pagina is! Map<String, dynamic>) {
      throw const FormatException('O campo page da resposta não é um objeto.');
    }

    return ResultadoPontos(
      pontos: pontos,
      pagina: pagina as Map<String, dynamic>?,
    );
  }

  Future<Object?> listarLinhasDoPonto(String id) {
    return _requisitar(
      'GET',
      '/api/pontos/${Uri.encodeComponent(id)}/linhas',
      requerToken: true,
    );
  }

  Future<Object?> _requisitar(
    String metodo,
    String caminho, {
    Object? corpo,
    bool requerToken = false,
  }) async {
    if (requerToken && (_token == null || _token!.isEmpty)) {
      throw StateError('Faça login antes de consultar os dados protegidos.');
    }

    final uri = urlBase.resolve(caminho);
    final requisicao = await _cliente.openUrl(metodo, uri);
    requisicao.headers.set(
      HttpHeaders.acceptHeader,
      'application/hal+json, application/json',
    );

    if (corpo != null) {
      requisicao.headers.contentType = ContentType.json;
      requisicao.write(jsonEncode(corpo));
    }

    if (requerToken) {
      requisicao.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $_token',
      );
    }

    final resposta = await requisicao.close();
    final texto = await utf8.decoder.bind(resposta).join();

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw HttpException(
        'Erro HTTP ${resposta.statusCode}${texto.isEmpty ? '' : ': $texto'}',
        uri: uri,
      );
    }

    if (texto.isEmpty) {
      return null;
    }
    return jsonDecode(texto);
  }

  void fechar() {
    _cliente.close(force: true);
  }
}
