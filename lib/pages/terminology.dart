import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/terminology_translations.dart';
import '../l10n/app_localizations.dart';
import '../model/terminology_entry.dart';

class TerminologyPage extends StatefulWidget {
  const TerminologyPage({super.key});

  @override
  State<TerminologyPage> createState() => _TerminologyPageState();
}

class _TerminologyPageState extends State<TerminologyPage> {
  Future<List<TerminologyEntry>>? _terminologyFuture;
  String? _localeCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (_localeCode != locale) {
      _localeCode = locale;
      _terminologyFuture = _loadTerminology(locale);
    }
  }

  Future<List<TerminologyEntry>> _loadTerminology(String locale) async {
    final client = Supabase.instance.client;
    List<TerminologyEntry> items = const [];
    try {
      items = await TerminologyEntry.fetchByLocale(client, locale);
    } catch (_) {
      items = const [];
    }
    if (items.isEmpty && locale != 'en') {
      try {
        items = await TerminologyEntry.fetchByLocale(client, 'en');
      } catch (_) {
        items = const [];
      }
    }
    if (items.isEmpty) {
      final fallback = TerminologyTranslations.listForLocale(locale)
          .map((entry) => TerminologyEntry.fromTranslation(entry, locale))
          .toList();
      if (fallback.isNotEmpty) {
        return fallback;
      }
      return TerminologyTranslations.listForLocale('en')
          .map((entry) => TerminologyEntry.fromTranslation(entry, 'en'))
          .toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleSliver = SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Text(
          l10n.terminologyTitle,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );

    return FutureBuilder<List<TerminologyEntry>>(
      future: _terminologyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CustomScrollView(
            slivers: [
              titleSliver,
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return CustomScrollView(
            slivers: [
              titleSliver,
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.unexpectedError(snapshot.error.toString()),
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        final terms = snapshot.data ?? const [];
        if (terms.isEmpty) {
          return CustomScrollView(
            slivers: [
              titleSliver,
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    l10n.profileNoData,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          );
        }

        return CustomScrollView(
          slivers: [
            titleSliver,
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: terms.length,
                itemBuilder: (context, index) {
                  final entry = terms[index];
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.fitness_center,
                                  size: 18,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.term,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            entry.description,
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 12),
              ),
            ),
          ],
        );
      },
    );
  }
}
