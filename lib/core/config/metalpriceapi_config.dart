import 'env.dart';

class MetalPriceApiConfig {
  static const String baseUrl = 'https://api.metalpriceapi.com/v1';

  // Order of precedence:
  // 1) `.env` via `flutter_dotenv` (Env.get)
  // 2) `--dart-define=METALPRICE_API_KEY=...`
  static String get apiKey => Env.get('METALPRICE_API_KEY') ?? const String.fromEnvironment('METALPRICE_API_KEY');
}
