import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../model/exercise_guide.dart';
import '../model/max_test.dart';
import '../model/max_test_series.dart';
import '../utils/app_date_format.dart';

String maxCategoryLabel(AppLocalizations l10n, MaxTestCategory category) =>
    switch (category) {
      MaxTestCategory.pull => l10n.maxCategoryPull,
      MaxTestCategory.push => l10n.maxCategoryPush,
      MaxTestCategory.legs => l10n.maxCategoryLegs,
      MaxTestCategory.core => l10n.maxCategoryCore,
      MaxTestCategory.skills => l10n.maxCategorySkills,
      MaxTestCategory.other => l10n.maxCategoryOther,
    };

String maxUnitLabel(AppLocalizations l10n, String unit) =>
    switch (normalizeMaxTestUnit(unit)) {
      'reps' => l10n.maxUnitReps,
      'seconds' => l10n.maxUnitSeconds,
      'minutes' => l10n.maxUnitMinutes,
      final unit => unit,
    };

class MaxTestsDashboard extends StatefulWidget {
  const MaxTestsDashboard({
    super.key,
    required this.tests,
    required this.guides,
    required this.onRefresh,
    this.onAdd,
    this.onAddForExercise,
    this.onEditNotes,
    this.onDelete,
    this.trainerNotes = const {},
    this.historyExpanded = false,
  });

  final List<MaxTest> tests;
  final List<ExerciseGuide> guides;
  final Future<void> Function() onRefresh;
  final VoidCallback? onAdd;
  final ValueChanged<MaxTest>? onAddForExercise;
  final ValueChanged<MaxTest>? onEditNotes;
  final ValueChanged<MaxTest>? onDelete;
  final Map<String, String> trainerNotes;
  final bool historyExpanded;

  @override
  State<MaxTestsDashboard> createState() => _MaxTestsDashboardState();
}

class _MaxTestsDashboardState extends State<MaxTestsDashboard> {
  MaxTestCategory? _category;
  String _query = '';
  int? _periodDays;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final since = _periodDays == null
        ? null
        : DateTime.now().subtract(Duration(days: _periodDays!));
    final filtered = widget.tests
        .where((test) => since == null || !test.recordedAt.isBefore(since))
        .toList();
    final series = MaxTestSeries.build(filtered, widget.guides);
    final visible = series
        .where(
          (group) =>
              (_category == null || group.category == _category) &&
              group.name.toLowerCase().contains(_query.trim().toLowerCase()),
        )
        .toList();
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        key: const PageStorageKey('max-tests-dashboard'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 28),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.maxTestsResultsTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.onAdd == null
                        ? l10n.maxTestsTraineeIntro
                        : l10n.maxTestsTrainerIntro,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (widget.onAdd != null)
                        FilledButton.icon(
                          key: const ValueKey('max-tests-add'),
                          onPressed: widget.onAdd,
                          icon: const Icon(Icons.add),
                          label: Text(l10n.trainerAddMaxTest),
                        ),
                      OutlinedButton.icon(
                        onPressed: widget.onRefresh,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.profileMaxTestsRefresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const ValueKey('max-tests-search'),
                    decoration: InputDecoration(
                      labelText: l10n.maxTestsSearch,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    itemHeight: null,
                    initialValue: _periodDays ?? 0,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.profileMaxTestsPeriodLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 0,
                        child: Text(l10n.profileMaxTestsPeriodAll),
                      ),
                      DropdownMenuItem(
                        value: 30,
                        child: Text(l10n.profileMaxTestsPeriodMonth),
                      ),
                      DropdownMenuItem(
                        value: 182,
                        child: Text(l10n.profileMaxTestsPeriodHalfYear),
                      ),
                      DropdownMenuItem(
                        value: 365,
                        child: Text(l10n.profileMaxTestsPeriodYear),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _periodDays = value == 0 ? null : value),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(
                          '${l10n.maxCategoryAll} (${series.length})',
                        ),
                        selected: _category == null,
                        onSelected: (_) => setState(() => _category = null),
                      ),
                      for (final category in MaxTestCategory.values)
                        if (series.any((group) => group.category == category))
                          ChoiceChip(
                            key: ValueKey('max-category-${category.name}'),
                            label: Text(maxCategoryLabel(l10n, category)),
                            selected: _category == category,
                            onSelected: (_) =>
                                setState(() => _category = category),
                          ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (visible.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          widget.tests.isEmpty
                              ? (widget.onAdd == null
                                    ? l10n.maxTestsNoResults
                                    : l10n.trainerNoMaxTests)
                              : l10n.maxTestsNoMatches,
                        ),
                      ),
                    )
                  else
                    for (final group in visible)
                      _SeriesCard(
                        key: ValueKey(group.key),
                        group: group,
                        dashboard: widget,
                        periodFiltered: _periodDays != null,
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({
    super.key,
    required this.group,
    required this.dashboard,
    required this.periodFiltered,
  });
  final MaxTestSeries group;
  final MaxTestsDashboard dashboard;
  final bool periodFiltered;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final format = NumberFormat('0.##', l10n.localeName);
    final unit = maxUnitLabel(l10n, group.unit);
    String value(double result) => '${format.format(result)} $unit'.trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              group.name.isEmpty ? l10n.trainerExerciseFallback : group.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              unit.isEmpty
                  ? maxCategoryLabel(l10n, group.category)
                  : '${maxCategoryLabel(l10n, group.category)} · $unit',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _ResultMetric(
                  label: l10n.maxTestsLatest,
                  value: value(group.latest.value),
                ),
                _ResultMetric(
                  label: periodFiltered
                      ? l10n.profileMaxTestsBestPeriodLabel
                      : l10n.profileMaxTestsBestLabel,
                  value: value(group.best),
                ),
                if (group.change != null)
                  _ResultMetric(
                    label: l10n.maxTestsChange,
                    value:
                        '${group.change! > 0 ? '+' : ''}${value(group.change!)}',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppDateFormat.date(group.latest.recordedAt),
              style: theme.textTheme.bodySmall,
            ),
            if (dashboard.onEditNotes != null &&
                (dashboard.trainerNotes[group.latest.id]?.trim().isNotEmpty ??
                    false)) ...[
              const SizedBox(height: 12),
              Text(l10n.trainerPrivateNotes, style: theme.textTheme.labelLarge),
              Text(dashboard.trainerNotes[group.latest.id]!),
            ],
            if (group.tests.length > 1) ...[
              const SizedBox(height: 12),
              ExcludeSemantics(
                child: SizedBox(
                  height: 64,
                  child: CustomPaint(
                    painter: _MaxTrendPainter(
                      values: group.tests.reversed
                          .map((test) => test.value)
                          .toList(),
                      color: theme.colorScheme.primary,
                      track: theme.colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (dashboard.onAddForExercise != null)
                  TextButton.icon(
                    onPressed: () => dashboard.onAddForExercise!(group.latest),
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(l10n.trainerAddMaxTest),
                  ),
                if (dashboard.onEditNotes != null)
                  TextButton.icon(
                    key: ValueKey('max-series-notes-${group.latest.id}'),
                    onPressed: () => dashboard.onEditNotes!(group.latest),
                    icon: const Icon(Icons.edit_note),
                    label: Text(l10n.trainerEditMaxTestNotes),
                  ),
              ],
            ),
            ExpansionTile(
              key: PageStorageKey('max-history-${group.key}'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              initiallyExpanded: dashboard.historyExpanded,
              title: Text(
                '${periodFiltered ? l10n.maxTestsFilteredHistory : l10n.maxTestsHistory} (${group.tests.length})',
                style: theme.textTheme.titleSmall,
              ),
              children: [
                for (var i = 0; i < group.tests.length; i++)
                  _AttemptRow(
                    test: group.tests[i],
                    previous: i + 1 < group.tests.length
                        ? group.tests[i + 1]
                        : null,
                    formatValue: value,
                    dashboard: dashboard,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _AttemptRow extends StatelessWidget {
  const _AttemptRow({
    required this.test,
    required this.previous,
    required this.formatValue,
    required this.dashboard,
  });
  final MaxTest test;
  final MaxTest? previous;
  final String Function(double) formatValue;
  final MaxTestsDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notes = dashboard.onEditNotes == null
        ? ''
        : dashboard.trainerNotes[test.id]?.trim() ?? '';
    final delta = previous == null ? null : test.value - previous!.value;
    return Container(
      key: ValueKey('max-attempt-${test.id}'),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            formatValue(test.value),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(AppDateFormat.date(test.recordedAt)),
          Text(
            delta == null
                ? l10n.profileMaxTestsHistoryFirstEntry
                : l10n.profileMaxTestsHistoryDeltaLabel(
                    '${delta > 0 ? '+' : ''}${formatValue(delta)}',
                  ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.trainerPrivateNotes,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(notes),
          ],
          if (dashboard.onEditNotes != null || dashboard.onDelete != null)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (dashboard.onEditNotes != null)
                  TextButton.icon(
                    key: ValueKey('max-notes-${test.id}'),
                    onPressed: () => dashboard.onEditNotes!(test),
                    icon: const Icon(Icons.edit_note),
                    label: Text(l10n.trainerEditMaxTestNotes),
                  ),
                if (dashboard.onDelete != null)
                  TextButton.icon(
                    key: ValueKey('max-delete-${test.id}'),
                    onPressed: () => dashboard.onDelete!(test),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.trainerDeleteMaxTest),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MaxTrendPainter extends CustomPainter {
  const _MaxTrendPainter({
    required this.values,
    required this.color,
    required this.track,
  });
  final List<double> values;
  final Color color, track;
  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.width <= 0) return;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    canvas.drawLine(
      Offset(4, size.height - 4),
      Offset(size.width - 4, size.height - 4),
      Paint()..color = track,
    );
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = 4 + (size.width - 8) * i / (values.length - 1);
      final y = max == min
          ? size.height / 2
          : size.height -
                8 -
                (values[i] - min) / (max - min) * (size.height - 16);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MaxTrendPainter old) =>
      old.values != values || old.color != color || old.track != track;
}
