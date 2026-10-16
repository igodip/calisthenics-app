import 'package:supabase_flutter/supabase_flutter.dart';

class AccountAccess {
  const AccountAccess({
    required this.isTrainer,
    required this.isAdmin,
    required this.isTrainee,
    required this.isPaid,
    required this.isActive,
    required this.monthStart,
    required this.name,
  });
  final bool isTrainer, isAdmin, isTrainee, isPaid, isActive;
  final String monthStart, name;
  bool get hasTrainingAccess => isActive && (isTrainer || isAdmin || isPaid);
  factory AccountAccess.fromMap(Map<String, dynamic> row) => AccountAccess(
    isTrainer: row['is_trainer'] == true,
    isAdmin: row['is_admin'] == true,
    isTrainee: row['is_trainee'] == true,
    isPaid: row['is_paid'] == true,
    isActive: row['is_active'] == true,
    monthStart: row['month_start'] as String,
    name: row['name'] as String? ?? '',
  );
  static Future<AccountAccess> load([SupabaseClient? client]) async {
    final result = await (client ?? Supabase.instance.client).rpc(
      'current_account_access',
    );
    return AccountAccess.fromMap(Map<String, dynamic>.from(result as Map));
  }
}
