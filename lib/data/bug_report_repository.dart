import 'package:supabase_flutter/supabase_flutter.dart';

class BugReportRepository {
  BugReportRepository([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('No authenticated user');
    return id;
  }

  Future<void> createBugReport({
    required String title,
    required String description,
    String? reproductionSteps,
    String? expectedBehavior,
    String? actualBehavior,
    String? platform,
    String? appVersion,
  }) async {
    final reporterId = _userId;

    await _client.from('bug_reports').insert({
      'reporter_id': reporterId,
      'title': title,
      'description': description,
      'reproduction_steps': reproductionSteps,
      'expected_behavior': expectedBehavior,
      'actual_behavior': actualBehavior,
      'platform': platform,
      'app_version': appVersion,
      'status': 'open',
    });
  }
}
