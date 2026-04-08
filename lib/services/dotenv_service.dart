import 'package:flutter/foundation.dart';

class DotenvService {
  DotenvService._();

  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');

  static String get openRouterApiKey => _apiKey;

  static bool get isConfigured => _apiKey.isNotEmpty;

  static void logConfig() {
    debugPrint(
      'DotenvService: API key configured: ${isConfigured ? "Yes" : "No"}',
    );
  }
}
