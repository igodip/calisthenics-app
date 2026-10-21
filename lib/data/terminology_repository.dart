import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/terminology_entry.dart';
import 'locale_catalog_cache.dart';

class TerminologyRepository {
  TerminologyRepository._();

  static final _cache = LocaleCatalogCache<List<TerminologyEntry>>();

  static Future<List<TerminologyEntry>> load(
    String locale, {
    bool forceRefresh = false,
  }) {
    final normalized = LocaleCatalogCache.normalizeLocale(locale);
    return _cache.load(normalized, () async {
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
    }, forceRefresh: forceRefresh);
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

  static void invalidate({String? locale}) => _cache.invalidate(locale: locale);
}
