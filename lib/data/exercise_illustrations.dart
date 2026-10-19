/// Bundled reference artwork, matched by stable catalog slug, not translated
/// names. Custom/compound movements deliberately have no inferred match.
abstract final class ExerciseIllustrations {
  static const Map<String, List<String>> bySlug = {
    'pull-up': ['assets/exercises/pull-up.webp'],
    'chin-up': ['assets/exercises/chin-up.webp'],
    'push-up': ['assets/exercises/push-up.webp'],
    'bodyweight-squat': ['assets/exercises/bodyweight-squat.webp'],
    'glute-bridge': ['assets/exercises/glute-bridge.webp'],
    'hanging-leg-raise': ['assets/exercises/hanging-leg-raise.webp'],
    'muscle-up': ['assets/exercises/muscle-up.webp'],
    'straight-bar-dip': ['assets/exercises/straight-bar-dip.webp'],
    'dips': ['assets/exercises/dips.webp'],
    'australian-row': ['assets/exercises/australian-row.webp'],
    'pike-push-up': ['assets/exercises/pike-push-up.webp'],
    'hollow-body-hold': ['assets/exercises/hollow-body-hold.webp'],
    'plank': ['assets/exercises/plank.webp'],
    'l-sit': ['assets/exercises/l-sit.webp'],
    'handstand-hold': ['assets/exercises/handstand-hold.webp'],
  };

  static List<String> forSlug(String slug) =>
      bySlug[slug.trim().toLowerCase()] ?? const [];
}
