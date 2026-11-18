import 'dart:convert';
import 'dart:io';

import '../config/api_configuracao.dart';
import '../modelos/linha_onibus.dart';
import '../modelos/ponto_onibus.dart';

class ResultadoPontos {
  const ResultadoPontos({required this.pontos, required this.pagina});

  final List<PontoOnibus> pontos;
  final Map<String, dynamic>? pagina;
}

class ApiServico {
  ApiServico({Uri? urlBase, HttpClient? cliente})
      : urlBase = urlBase ?? Uri.parse(ApiConfiguracao.urlBase),
        _cliente = cliente ?? HttpClient();

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

  Future<ResultadoPontos> listarPontos({
    int pagina = 0,
    int tamanho = 10,
    String? endereco,
  }) async {
    final parametros = <String, String>{
      'page': '$pagina',
      'size': '$tamanho',
      if (endereco != null && endereco.trim().isNotEmpty)
        'endereco': endereco.trim(),
    };
    final resposta = await _requisitar(
      'GET',
      '/api/pontos',
      requerToken: true,
      parametros: parametros,
    );

    if (resposta is! Map<String, dynamic>) {
      throw const FormatException('A resposta de pontos não é um objeto HAL.');
    }

    final embedded = resposta['_embedded'];
    if (embedded is! Map<String, dynamic> || embedded['pontos'] is! List) {
      throw const FormatException(
          'A resposta HAL não contém _embedded.pontos.');
    }

    final pontos = (embedded['pontos'] as List).map((ponto) {
      if (ponto is! Map<String, dynamic>) {
        throw const FormatException('Um ponto da resposta não é um objeto.');
      }
      return PontoOnibus.fromJson(ponto);
    }).toList(growable: false);

    final metadadosPagina = resposta['page'];
    if (metadadosPagina != null && metadadosPagina is! Map<String, dynamic>) {
      throw const FormatException('O campo page da resposta não é um objeto.');
    }

    return ResultadoPontos(
      pontos: pontos,
      pagina: metadadosPagina as Map<String, dynamic>?,
    );
  }

  Future<List<LinhaOnibus>> listarLinhasDoPonto(int id) async {
    final resposta = await _requisitar(
      'GET',
      '/api/pontos/${Uri.encodeComponent(id.toString())}/linhas',
      requerToken: true,
    );

    if (resposta is! List) {
      throw const FormatException('A resposta de linhas não é uma lista.');
    }

    return resposta.map((linha) {
      if (linha is! Map<String, dynamic>) {
        throw const FormatException('Uma linha da resposta não é um objeto.');
      }
      return LinhaOnibus.fromJson(linha);
    }).toList(growable: false);
  }

  Future<Object?> _requisitar(
    String metodo,
    String caminho, {
    Object? corpo,
    bool requerToken = false,
    Map<String, String>? parametros,
  }) async {
    if (requerToken && (_token == null || _token!.isEmpty)) {
      throw StateError('Faça login antes de consultar os dados protegidos.');
    }

    var uri = urlBase.resolve(caminho);
    if (parametros != null && parametros.isNotEmpty) {
      uri = uri.replace(queryParameters: parametros);
    }
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
