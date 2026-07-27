class Environment {
  const Environment._();

  static const buildName = 'Mobile V2';
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:4000',
  );
}
