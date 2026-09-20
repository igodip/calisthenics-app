import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_models.dart';

class AdminRepository {
  AdminRepository([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<bool> isCurrentUserAdmin() async {
    final result = await _client.rpc('is_admin');
    return result == true;
  }

  Future<List<AdminUser>> loadUsers() async {
    final result = await _client.rpc('admin_list_users');
    return List<Map<String, dynamic>>.from(
      result as List,
    ).map(AdminUser.fromMap).toList();
  }

  Future<List<AdminAssignment>> loadAssignments() async {
    final result = await _client.rpc('admin_list_assignments');
    return List<Map<String, dynamic>>.from(
      result as List,
    ).map(AdminAssignment.fromMap).toList();
  }

  Future<void> setTrainer(AdminUser user, bool enabled) => _client.rpc(
    'admin_set_trainer',
    params: {'p_user_id': user.id, 'p_enabled': enabled, 'p_name': user.name},
  );

  Future<void> setSuspended(AdminUser user, bool suspended) => _client.rpc(
    'admin_set_user_suspended',
    params: {'p_user_id': user.id, 'p_suspended': suspended},
  );

  Future<void> setAssignment({
    required String traineeId,
    required String trainerId,
    required bool assigned,
  }) => _client.rpc(
    'admin_set_assignment',
    params: {
      'p_trainee_id': traineeId,
      'p_trainer_id': trainerId,
      'p_assigned': assigned,
    },
  );
}
