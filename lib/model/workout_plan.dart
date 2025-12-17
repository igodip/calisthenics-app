import 'package:intl/intl.dart';

class WorkoutPlan {
  final String? id;
  final String name;
  final String? status;
  final String? notes;
  final DateTime? startsOn;
  final DateTime? endsAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WorkoutPlan({
    required this.name,
    this.id,
    this.status,
    this.notes,
    this.startsOn,
    this.endsAt,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return WorkoutPlan(
      id: json['id'] as String?,
      name: (json['name'] as String? ?? '').trim(),
      status: (json['status'] as String? ?? '').trim(),
      notes: json['notes'] as String?,
      startsOn: parseDate(json['starts_on']),
      endsAt: parseDate(json['ends_at']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  String statusLabel(String Function(String) fallback) {
    final normalized = status?.toLowerCase().trim();
    if (normalized == 'active') return fallback('active');
    if (normalized == 'draft') return fallback('draft');
    if (normalized == 'archived') return fallback('archived');
    if (normalized == 'completed') return fallback('completed');
    if (normalized == 'upcoming') return fallback('upcoming');
    return fallback('unknown');
  }

  String? dateRangeLabel(DateFormat formatter) {
    if (startsOn == null && endsAt == null) return null;
    if (startsOn != null && endsAt != null) {
      return '${formatter.format(startsOn!)} — ${formatter.format(endsAt!)}';
    }
    if (startsOn != null) {
      return formatter.format(startsOn!);
    }
    return formatter.format(endsAt!);
  }
}
