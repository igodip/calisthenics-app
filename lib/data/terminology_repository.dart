import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/terminology_entry.dart';

class TerminologyRepository {
  TerminologyRepository._();

  static final Map<String, Future<List<TerminologyEntry>>> _cachedByLocale = {};

  static Future<List<TerminologyEntry>> load(String locale) {
    final normalized = _normalizeLocale(locale);
    return _cachedByLocale.putIfAbsent(normalized, () async {
      final client = Supabase.instance.client;
      final items = await TerminologyEntry.fetchByLocale(client, normalized);
      if (normalized == 'en') {
        return items;
      }
      final fallback = await TerminologyEntry.fetchByLocale(client, 'en');
      if (items.isEmpty) {
        return fallback;
      }
      final merged = <String, TerminologyEntry>{};
      for (final entry in fallback) {
        final key = entry.termKey.trim().toLowerCase();
        if (key.isEmpty) continue;
        merged[key] = entry;
      }
      for (final entry in items) {
        final key = entry.termKey.trim().toLowerCase();
        if (key.isEmpty) continue;
        merged[key] = entry;
      }
      final mergedList = merged.values.toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return mergedList;
    });
  }

  static Map<String, TerminologyEntry> toLookup(
    List<TerminologyEntry> entries,
  ) {
    final lookup = <String, TerminologyEntry>{};
    for (final entry in entries) {
      final key = entry.termKey.trim().toLowerCase();
      if (key.isEmpty) continue;
      lookup[key] = entry;
    }
    return lookup;
  }

  static String _normalizeLocale(String locale) {
    if (locale.isEmpty) return 'en';
    return locale.split('_').first.toLowerCase();
  }
}
