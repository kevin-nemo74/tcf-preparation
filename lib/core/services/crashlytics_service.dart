import 'package:flutter/foundation.dart';

class CrashlyticsService {
  static void setup() {
    if (kIsWeb) return;
    _setupImpl();
  }
}

void _setupImpl() {
  // Stub for web - will be replaced by conditional import
}
