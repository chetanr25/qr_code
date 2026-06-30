import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'qr_kind.dart';

class QrEntry {
  QrEntry({
    required this.value,
    required this.kind,
    required this.createdAt,
    required this.source,
    this.favorite = false,
  });

  final String value;
  final QrKind kind;
  final DateTime createdAt;
  final String source; // 'scan' | 'create'
  bool favorite;

  Map<String, dynamic> toJson() => {
        'v': value,
        'k': kind.name,
        't': createdAt.millisecondsSinceEpoch,
        's': source,
        'f': favorite,
      };

  static QrEntry fromJson(Map<String, dynamic> j) => QrEntry(
        value: j['v'] as String,
        kind: QrKind.values.firstWhere(
          (e) => e.name == j['k'],
          orElse: () => QrKind.text,
        ),
        createdAt: DateTime.fromMillisecondsSinceEpoch(j['t'] as int),
        source: j['s'] as String? ?? 'scan',
        favorite: j['f'] as bool? ?? false,
      );
}

/// In-memory + persisted store of scanned and generated QR codes.
class HistoryStore {
  HistoryStore._();
  static final HistoryStore instance = HistoryStore._();

  static const _key = 'qr_history_v1';
  final ValueNotifier<List<QrEntry>> entries = ValueNotifier([]);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    entries.value = raw
        .map((s) => QrEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(String value, QrKind kind, String source) async {
    // de-dupe: drop existing identical value, push fresh to top
    final list = [...entries.value]..removeWhere((e) => e.value == value);
    list.insert(
      0,
      QrEntry(
          value: value, kind: kind, createdAt: DateTime.now(), source: source),
    );
    if (list.length > 200) list.removeRange(200, list.length);
    entries.value = list;
    await _persist();
  }

  Future<void> remove(QrEntry entry) async {
    entries.value = [...entries.value]..remove(entry);
    await _persist();
  }

  Future<void> toggleFavorite(QrEntry entry) async {
    entry.favorite = !entry.favorite;
    entries.value = [...entries.value];
    await _persist();
  }

  Future<void> clear() async {
    entries.value = [];
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      entries.value.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
