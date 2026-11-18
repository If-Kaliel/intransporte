class FormularioLoginRepository {
  FormularioLoginRepository._();

  static final instancia = FormularioLoginRepository._();

  String login = '';
  String senha = '';

  void salvarLogin(String valor) {
    login = valor;
  }

  void salvarSenha(String valor) {
    senha = valor;
  }

  void limpar() {
    login = '';
    senha = '';
  }
}
