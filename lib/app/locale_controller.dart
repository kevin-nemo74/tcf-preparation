import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static const _keyLocaleMode = "locale_mode";

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> loadLocaleMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyLocaleMode);
    _locale = _decodeLocale(value);
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocaleMode, _encodeLocale(locale));
  }

  String _encodeLocale(Locale? locale) {
    if (locale == null) return "system";
    switch (locale.languageCode) {
      case "fr":
        return "fr";
      case "en":
      default:
        return "en";
    }
  }

  Locale? _decodeLocale(String? value) {
    switch (value) {
      case "en":
        return const Locale("en");
      case "fr":
        return const Locale("fr");
      case "system":
      default:
        return null;
    }
  }
}
