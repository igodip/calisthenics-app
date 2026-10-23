import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountTutorialRepository {
  AccountTutorialRepository(this.userId, {SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final String userId;
  final SupabaseClient _client;
  String get _doneKey => 'account_tutorial_done:$userId';
  String get _pendingKey => 'account_tutorial_pending:$userId';

  void _checkUser() {
    if (userId.isEmpty || _client.auth.currentUser?.id != userId) {
      throw StateError('Tutorial account changed');
    }
  }

  Future<bool> hasCompleted() async {
    _checkUser();
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_doneKey) == true) {
      await syncPending();
      return true;
    }
    final row = await _client
        .from('account_tutorials')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle()
        .timeout(const Duration(seconds: 5));
    _checkUser();
    if (row == null) return false;
    await preferences.setBool(_doneKey, true);
    return true;
  }

  Future<void> complete({required bool skipped}) async {
    _checkUser();
    final preferences = await SharedPreferences.getInstance();
    // Queue before marking done so interrupted/offline writes can be retried.
    await preferences.setBool(_pendingKey, skipped);
    await preferences.setBool(_doneKey, true);
    await syncPending();
  }

  Future<void> syncPending() async {
    _checkUser();
    final preferences = await SharedPreferences.getInstance();
    final skipped = preferences.getBool(_pendingKey);
    if (skipped == null) return;
    try {
      _checkUser();
      await _client
          .from('account_tutorials')
          .upsert(
            {'user_id': userId, 'skipped': skipped},
            onConflict: 'user_id',
            ignoreDuplicates: true,
          )
          .timeout(const Duration(seconds: 5));
      _checkUser();
      await preferences.remove(_pendingKey);
    } catch (_) {
      // Do not block account controls offline. The next login/resume retries.
    }
  }
}
