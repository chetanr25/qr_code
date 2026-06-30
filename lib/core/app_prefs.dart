import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'qr_kind.dart';

/// App-wide preferences (theme mode, gradient, create-tile order), persisted.
class AppPrefs {
  AppPrefs._();
  static final AppPrefs instance = AppPrefs._();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);
  final ValueNotifier<String> gradientName = ValueNotifier('Indigo Pop');
  final ValueNotifier<List<QrKind>> kindOrder = ValueNotifier(kCreateKinds);

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
    kindOrder.value = _loadKindOrder();
  }

  List<QrKind> _loadKindOrder() {
    final saved = _prefs.getStringList('kind_order');
    if (saved == null) return kCreateKinds;
    final byName = {for (final k in QrKind.values) k.name: k};
    final list = saved
        .map((n) => byName[n])
        .whereType<QrKind>()
        .where(kCreateKinds.contains)
        .toList();
    // append any kinds added in later app versions so nothing disappears
    for (final k in kCreateKinds) {
      if (!list.contains(k)) list.add(k);
    }
    return list;
  }

  Future<void> setKindOrder(List<QrKind> order) async {
    kindOrder.value = List.of(order);
    await _prefs.setStringList(
        'kind_order', order.map((k) => k.name).toList());
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
