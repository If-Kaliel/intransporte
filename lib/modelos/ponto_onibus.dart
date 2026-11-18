class PontoOnibus {
  const PontoOnibus({
    required this.id,
    required this.endereco,
    required this.numero,
  });

  final int id;
  final String endereco;
  final int numero;

  factory PontoOnibus.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final endereco = json['endereco'];
    final numero = json['numero'];

    if (id is! num || endereco is! String || numero is! num) {
      throw const FormatException('Os dados recebidos do ponto são inválidos.');
    }

    return PontoOnibus(
      id: id.toInt(),
      endereco: endereco,
      numero: numero.toInt(),
    );
  }
}
