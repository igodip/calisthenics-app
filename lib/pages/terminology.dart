import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/terminology_translations.dart';
import '../l10n/app_localizations.dart';
import '../model/terminology_entry.dart';

class TerminologyPage extends StatefulWidget {
  const TerminologyPage({super.key, this.termKey});

  final String? termKey;

  @override
  State<TerminologyPage> createState() => _TerminologyPageState();
}

class _TerminologyPageState extends State<TerminologyPage> {
  Future<List<TerminologyEntry>>? _terminologyFuture;
  String? _localeCode;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _entryKeys = {};
  String? _highlightedTermKey;
  bool _didScrollToTarget = false;

  @override
  void initState() {
    super.initState();
    _highlightedTermKey = widget.termKey?.trim().toLowerCase();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (_localeCode != locale) {
      _localeCode = locale;
      _terminologyFuture = _loadTerminology(locale);
      _entryKeys.clear();
      _didScrollToTarget = false;
    }
  }

  @override
  void didUpdateWidget(covariant TerminologyPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.termKey != widget.termKey) {
      _highlightedTermKey = widget.termKey?.trim().toLowerCase();
      _didScrollToTarget = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _scrollToHighlightedEntry(List<TerminologyEntry> terms) {
    if (_didScrollToTarget || _highlightedTermKey == null) {
      return;
    }
    final targetKey = _highlightedTermKey!;
    final exists =
        terms.any((entry) => entry.termKey.toLowerCase() == targetKey);
    if (!exists) {
      _didScrollToTarget = true;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _entryKeys[targetKey];
      final context = key?.currentContext;
      if (!mounted || context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
      if (mounted) {
        setState(() {
          _didScrollToTarget = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<List<TerminologyEntry>>(
      future: _terminologyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CustomScrollView(
            slivers: [
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

        _scrollToHighlightedEntry(terms);

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: terms.length,
                itemBuilder: (context, index) {
                  final entry = terms[index];
                  final termKey = entry.termKey.toLowerCase();
                  final entryKey = _entryKeys.putIfAbsent(
                    termKey,
                    () => GlobalKey(),
                  );
                  final isHighlighted =
                      termKey == _highlightedTermKey;
                  return DecoratedBox(
                    key: entryKey,
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? colorScheme.primaryContainer.withValues(
                              alpha: 0.6,
                            )
                          : colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isHighlighted
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: isHighlighted ? 1.5 : 1,
                      ),
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
