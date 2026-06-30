class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      apiBaseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8080',
      ),
    );
  }

  final String apiBaseUrl;

  Uri get apiBaseUri => Uri.parse(apiBaseUrl);
}
