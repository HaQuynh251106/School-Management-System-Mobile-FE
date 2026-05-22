class Env {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000',
  );
  static const accessTokenTtlSeconds = 3600;
}
