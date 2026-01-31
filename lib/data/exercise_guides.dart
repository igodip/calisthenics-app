import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/exercise_guide.dart';

class ExerciseGuides {
  ExerciseGuides._();

  static final Map<String, Future<List<ExerciseGuide>>> _cachedByLocale = {};

  static Future<List<ExerciseGuide>> load(String locale) {
    final normalized = _normalizeLocale(locale);
    return _cachedByLocale.putIfAbsent(normalized, () async {
      final client = Supabase.instance.client;
      final response = await client
          .from('exercises')
          .select('id, slug, name, difficulty, sort_order, default_unlocked')
          .order('sort_order', ascending: true);
      final rows = (response as List<dynamic>).cast<Map<String, dynamic>>();

      final locales = normalized == 'en' ? ['en'] : [normalized, 'en'];
      final translationResponse = await client
          .from('exercise_translations')
          .select('exercise_id, locale, name, focus, tip, description')
          .inFilter('locale', locales);
      final translations =
          (translationResponse as List<dynamic>).cast<Map<String, dynamic>>();

      final localized = <String, ExerciseGuideTranslation>{};
      final fallback = <String, ExerciseGuideTranslation>{};
      for (final row in translations) {
        final translation = ExerciseGuideTranslation.fromMap(row);
        final exerciseId = translation.exerciseId;
        if (translation.locale == normalized) {
          localized[exerciseId] = translation;
        } else if (translation.locale == 'en') {
          fallback[exerciseId] = translation;
        }
      }

      return rows
          .map(
            (row) => ExerciseGuide.fromDatabase(
              row,
              translation: localized[row['id']?.toString() ?? ''],
              fallbackTranslation: fallback[row['id']?.toString() ?? ''],
            ),
          )
          .toList();
    });
  }

  static Map<String, ExerciseGuide> toLookup(List<ExerciseGuide> guides) {
    final lookup = <String, ExerciseGuide>{};
    for (final guide in guides) {
      final key = guide.id.trim().toLowerCase();
      if (key.isEmpty) continue;
      lookup[key] = guide;
    }
    return lookup;
  }

  static String _normalizeLocale(String locale) {
    if (locale.isEmpty) return 'en';
    return locale.split('_').first.toLowerCase();
  }
}
