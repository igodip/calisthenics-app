import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../model/exercise_guide.dart';

class ExerciseGuides {
  ExerciseGuides._();

  static final Map<String, Future<List<ExerciseGuide>>> _cachedByLocale = {};

  static Future<List<ExerciseGuide>> load(AppLocalizations l10n) {
    return _cachedByLocale.putIfAbsent(l10n.localeName, () async {
      final response = await Supabase.instance.client
          .from('exercises')
          .select('name, slug, difficulty, default_unlocked')
          .order('sort_order', ascending: true);
      final rows = (response as List<dynamic>).cast<Map<String, dynamic>>();
      return rows
          .map((row) => ExerciseGuide.fromDatabase(row, l10n.localeName))
          .toList();
    });
  }
}
