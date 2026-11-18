class ApiConfiguracao {
  static const urlBase = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );
}
