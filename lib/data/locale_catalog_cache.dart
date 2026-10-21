/// Shared single-flight cache for public, localized reference catalogs.
/// Successful entries expire; failed entries never prevent a subsequent retry.
class LocaleCatalogCache<T> {
  LocaleCatalogCache({
    this.maxAge = const Duration(minutes: 5),
    this.requestTimeout = const Duration(seconds: 30),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final Duration maxAge;
  final Duration requestTimeout;
  final DateTime Function() _now;
  final Map<String, _CatalogEntry<T>> _entries = {};

  static String normalizeLocale(String locale) {
    final language = locale.trim().toLowerCase().split(RegExp('[-_]')).first;
    return language.isEmpty ? 'en' : language;
  }

  Future<T> load(
    String locale,
    Future<T> Function() fetch, {
    bool forceRefresh = false,
  }) {
    final key = normalizeLocale(locale);
    if (forceRefresh) _entries.remove(key);
    final existing = _entries[key];
    if (existing != null &&
        (existing.expiresAt == null || _now().isBefore(existing.expiresAt!))) {
      return existing.future;
    }
    final entry = _CatalogEntry<T>();
    _entries[key] = entry;
    entry.future = Future<T>.sync(fetch)
        .timeout(requestTimeout)
        .then(
          (value) {
            entry.expiresAt = _now().add(maxAge);
            return value;
          },
          onError: (Object error, StackTrace stack) {
            // A superseded request must not evict a newer refresh for this locale.
            if (identical(_entries[key], entry)) _entries.remove(key);
            Error.throwWithStackTrace(error, stack);
          },
        );
    return entry.future;
  }

  /// Remove one language (including its region aliases), or every language.
  /// In-flight callers still receive their result, but cannot repopulate a
  /// superseded cache entry after invalidation.
  void invalidate({String? locale}) {
    if (locale == null) {
      _entries.clear();
    } else {
      _entries.remove(normalizeLocale(locale));
    }
  }
}

class _CatalogEntry<T> {
  late final Future<T> future;
  DateTime? expiresAt;
}
