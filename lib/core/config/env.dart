import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String? get(String key) {
    final v = dotenv.env[key];
    if (v == null) return null;
    final trimmed = v.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

