import 'package:supabase_flutter/supabase_flutter.dart';

class TerminologyEntry {
  const TerminologyEntry({
    required this.id,
    required this.termKey,
    required this.locale,
    required this.term,
    required this.description,
    required this.sortOrder,
  });

  final String id;
  final String termKey;
  final String locale;
  final String term;
  final String description;
  final int sortOrder;

  factory TerminologyEntry.fromMap(Map<String, dynamic> data) {
    return TerminologyEntry(
      id: data['id']?.toString() ?? '',
      termKey: data['term_key']?.toString() ?? '',
      locale: data['locale']?.toString() ?? '',
      term: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      sortOrder: (data['sort_order'] as int?) ?? 0,
    );
  }

  static Future<List<TerminologyEntry>> fetchByLocale(
    SupabaseClient client,
    String locale,
  ) async {
    final response = await client
        .from('terminology')
        .select('id, term_key, locale, title, description, sort_order')
        .eq('locale', locale)
        .order('sort_order', ascending: true);

    final items = (response as List?)?.cast<Map<String, dynamic>>() ?? [];
    return items.map(TerminologyEntry.fromMap).toList();
  }
}
