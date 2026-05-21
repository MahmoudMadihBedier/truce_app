class MetalPriceApiConfig {
  static const String baseUrl = 'https://api.metalpriceapi.com/v1';

  // Prefer providing this via `--dart-define=METALPRICE_API_KEY=...`.
  static const String apiKey = String.fromEnvironment(
    'METALPRICE_API_KEY',
    defaultValue: '',
  );
}
