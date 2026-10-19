import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/max_tests_dashboard.dart';
import '../data/exercise_guides.dart';
import '../l10n/app_localizations.dart';
import '../model/exercise_guide.dart';
import '../model/max_test.dart';

class MaxTestsContent extends StatefulWidget {
  const MaxTestsContent({
    super.key,
    required this.userId,
    required this.displayName,
    this.historyExpanded = false,
    this.loadTests,
    this.loadGuides,
  });

  final String userId, displayName;
  final bool historyExpanded;
  final Future<List<MaxTest>> Function()? loadTests;
  final Future<List<ExerciseGuide>> Function(String)? loadGuides;

  @override
  State<MaxTestsContent> createState() => _MaxTestsContentState();
}

class _MaxTestsContentState extends State<MaxTestsContent> {
  Future<List<MaxTest>>? _tests;
  Future<List<ExerciseGuide>>? _guides;
  String? _locale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tests ??= _loadTests();
    final locale = AppLocalizations.of(context)!.localeName;
    if (_locale != locale) {
      _locale = locale;
      // History remains usable if the optional technique catalog is offline.
      _guides = _loadGuides(locale);
    }
  }

  Future<List<ExerciseGuide>> _loadGuides(String locale) async {
    try {
      return await (widget.loadGuides?.call(locale) ??
          ExerciseGuides.load(locale));
    } catch (_) {
      return const [];
    }
  }

  @override
  void didUpdateWidget(covariant MaxTestsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) _tests = _loadTests();
  }

  Future<List<MaxTest>> _loadTests() async {
    if (widget.loadTests != null) return widget.loadTests!();
    final rows = await Supabase.instance.client
        .from('max_tests')
        // Trainer-only notes must never be requested by the trainee screen.
        .select(
          'id, exercise_id, exercise, value, unit, recorded_at, created_at',
        )
        .eq('trainee_id', widget.userId)
        .order('recorded_at', ascending: false)
        .order('created_at', ascending: false)
        .order('id', ascending: false);
    return rows.map(MaxTest.fromMap).toList();
  }

  Future<void> _refresh() async {
    final next = _loadTests();
    setState(() {
      _tests = next;
    });
    try {
      await next;
    } catch (_) {
      /* Render the retry state below. */
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<MaxTest>>(
      future: _tests,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.cloud_off_outlined, size: 40),
              const SizedBox(height: 16),
              Text(l10n.maxTestsLoadError, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _refresh, child: Text(l10n.retry)),
            ],
          );
        }
        return FutureBuilder<List<ExerciseGuide>>(
          future: _guides,
          builder: (context, guides) => MaxTestsDashboard(
            tests: snapshot.data ?? const [],
            guides: guides.data ?? const [],
            onRefresh: _refresh,
            historyExpanded: widget.historyExpanded,
          ),
        );
      },
    );
  }
}
