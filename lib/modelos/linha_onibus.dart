class LinhaOnibus {
  const LinhaOnibus({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.intervaloMinutos,
  });

  final int id;
  final String nome;
  final String descricao;
  final int? intervaloMinutos;

  factory LinhaOnibus.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final nome = json['nome'];
    final descricao = json['descricao'];
    final intervalo = json['intervaloMinutos'];

    if (id is! num || nome is! String || descricao is! String) {
      throw const FormatException('Os dados recebidos da linha são inválidos.');
    }

    return LinhaOnibus(
      id: id.toInt(),
      nome: nome,
      descricao: descricao,
      intervaloMinutos: intervalo is num ? intervalo.toInt() : null,
    );
  }
}
