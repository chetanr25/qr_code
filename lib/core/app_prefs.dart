import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide preferences (theme mode + selected gradient), persisted.
class AppPrefs {
  AppPrefs._();
  static final AppPrefs instance = AppPrefs._();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);
  final ValueNotifier<String> gradientName = ValueNotifier('Indigo Pop');

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final mode = _prefs.getString('theme_mode');
    themeMode.value = switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    gradientName.value = _prefs.getString('gradient') ?? 'Indigo Pop';
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _prefs.setString('theme_mode', mode.name);
  }

  Future<void> setGradient(String name) async {
    gradientName.value = name;
    await _prefs.setString('gradient', name);
  }
}
