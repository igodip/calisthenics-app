import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Test-only, in-memory responses for the app's existing PostgREST queries.
/// No request is ever forwarded to a network client.
class StoreDemoBackend {
  static const userId = '11111111-1111-4111-8111-111111111111';
  static const planId = '22222222-2222-4222-8222-222222222222';
  static const host = 'store-demo.invalid';
  final DateTime now = DateTime.now();
  String locale = 'en';
  final List<String> unexpectedRequests = [];
  late final http.Client client = MockClient(_respond);

  String text(String en, String it) => locale == 'it' ? it : en;
  String get planTitle => text('Strength & control', 'Forza e controllo');
  String get coachMessage => text(
    'Great control today. Keep the same tempo in your next session.',
    'Ottimo controllo oggi. Mantieni lo stesso ritmo nella prossima sessione.',
  );
  String get monthStart =>
      DateTime(now.year, now.month).toIso8601String().split('T').first;

  Map<String, dynamic> get user => {
    'id': userId,
    'aud': 'authenticated',
    'role': 'authenticated',
    'email': 'alex@example.invalid',
    'app_metadata': {
      'provider': 'email',
      'providers': ['email'],
    },
    'user_metadata': {'name': 'Alex'},
    'created_at': '2026-01-01T00:00:00Z',
  };

  Map<String, dynamic> get session {
    String encode(Object value) =>
        base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
    final expiry =
        now.add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000;
    final token = [
      encode({'alg': 'HS256', 'typ': 'JWT'}),
      encode({'sub': userId, 'exp': expiry, 'role': 'authenticated'}),
      'fixture-only-not-a-real-signature',
    ].join('.');
    return {
      'access_token': token,
      'refresh_token': 'fixture-only-refresh-token',
      'token_type': 'bearer',
      'expires_in': 86400,
      'expires_at': expiry,
      'user': user,
    };
  }

  List<Map<String, dynamic>> get exercises => [
    {
      'id': 'ex-pull',
      'slug': 'pull-up',
      'name': 'Pull-up',
      'difficulty': 'intermediate',
      'sort_order': 0,
    },
    {
      'id': 'ex-push',
      'slug': 'push-up',
      'name': 'Push-up',
      'difficulty': 'beginner',
      'sort_order': 1,
    },
    {
      'id': 'ex-squat',
      'slug': 'squat',
      'name': 'Squat',
      'difficulty': 'beginner',
      'sort_order': 2,
    },
    {
      'id': 'ex-plank',
      'slug': 'plank',
      'name': 'Plank',
      'difficulty': 'beginner',
      'sort_order': 3,
    },
  ];

  List<Map<String, dynamic>> get days => List.generate(4, (index) {
    final done = index < 2;
    return {
      'id': 'day-$index',
      'week': index ~/ 2 + 1,
      'day_code': index.isEven ? 'A' : 'B',
      'title': index.isEven
          ? text('Upper body', 'Parte superiore')
          : text('Legs & core', 'Gambe e core'),
      'notes': text(
        'Controlled repetitions. Rest 90 seconds between sets.',
        'Ripetizioni controllate. Recupero di 90 secondi tra le serie.',
      ),
      'completed': done,
      'completed_at': done
          ? DateTime(now.year, now.month, 1).toIso8601String()
          : null,
      'workout_plan_days': {
        'position': index,
        'workout_plans': {
          'id': planId,
          'title': planTitle,
          'starts_on': monthStart,
          'created_at': monthStart,
        },
      },
      'day_exercises': [
        for (var e = 0; e < exercises.length; e++)
          {
            'id': 'day-exercise-$index-$e',
            'exercise_id': exercises[e]['id'],
            'exercise': exercises[e]['name'],
            'exercises': exercises[e],
            'position': e,
            'notes': '3 × 8',
            'trainee_notes': null,
            'exercise_feedback': null,
            'duration_minutes': 10,
            'completed': done,
            'completed_reps': done ? 24 : 0,
          },
      ],
    };
  });

  List<Map<String, dynamic>> _rows(String table) => switch (table) {
    'trainers' || 'admins' || 'terminology' => [],
    'trainees' => [
      {
        'id': userId,
        'name': 'Alex',
        'weight': 74,
        'height': 178,
        'profile_image_url': null,
      },
    ],
    'trainee_monthly_payments' => [
      {'trainee_id': userId, 'paid': true, 'month_start': monthStart},
    ],
    'trainee_trainers' => [
      {'trainee_id': userId, 'coach_tip': coachMessage},
    ],
    'workout_plans' => [
      {
        'id': planId,
        'trainee_id': userId,
        'title': planTitle,
        'status': 'active',
        'starts_on': monthStart,
        'created_at': monthStart,
      },
    ],
    'days' => days,
    'exercises' => exercises,
    'exercise_translations' => [
      for (final language in ['en', 'it'])
        for (final exercise in exercises)
          {
            'exercise_id': exercise['id'],
            'locale': language,
            'name': exercise['name'],
            'focus': language == 'it'
                ? 'Forza e controllo del corpo'
                : 'Bodyweight strength and control',
            'tip': language == 'it'
                ? 'Mantieni un movimento lento e controllato.'
                : 'Keep each repetition slow and controlled.',
            'description': language == 'it'
                ? 'Cura la tecnica e mantieni il core attivo durante il movimento.'
                : 'Focus on technique and keep your core engaged throughout the movement.',
          },
    ],
    'trainee_feedbacks' => [
      {
        'id': 'feedback-1',
        'trainee_id': userId,
        'message': text(
          'The last set felt easier today. Ready for the next session!',
          'Oggi l’ultima serie è stata più facile. Pronto per la prossima sessione!',
        ),
        'answer_message': coachMessage,
        'created_at': '${monthStart}T09:00:00Z',
        'answered_at': '${monthStart}T10:00:00Z',
      },
    ],
    'max_tests' => [
      for (var index = 0; index < 4; index++)
        {
          'id': 'max-$index',
          'trainee_id': userId,
          'exercise_id': 'pull-up',
          'exercise': 'Pull-up',
          'value': 5 + index * 2,
          'unit': 'reps',
          'recorded_at': now
              .subtract(Duration(days: (3 - index) * 14))
              .toIso8601String(),
          'created_at': now
              .subtract(Duration(days: (3 - index) * 14))
              .toIso8601String(),
        },
    ],
    _ => throw StateError('Missing screenshot fixture for $table'),
  };

  Future<http.Response> _respond(http.Request request) async {
    try {
      if (request.url.host != host) throw StateError('Unexpected host');
      final path = request.url.path;
      Object? result;
      if (path == '/auth/v1/token' && request.method == 'POST') {
        result = session;
      } else if (path == '/auth/v1/user' && request.method == 'GET') {
        result = user;
      } else if (path == '/rest/v1/rpc/is_admin' && request.method == 'POST') {
        result = false;
      } else if (path.startsWith('/rest/v1/') && request.method == 'GET') {
        var rows = _rows(path.substring('/rest/v1/'.length));
        final limit = int.tryParse(request.url.queryParameters['limit'] ?? '');
        if (limit != null) rows = rows.take(limit).toList();
        final wantsObject =
            request.headers['accept']?.contains('vnd.pgrst.object') ?? false;
        result = wantsObject ? (rows.isEmpty ? null : rows.single) : rows;
      } else {
        throw StateError('Unexpected method or endpoint');
      }
      return http.Response(
        jsonEncode(result),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    } catch (error) {
      final description = '${request.method} ${request.url}: $error';
      unexpectedRequests.add(description);
      return http.Response(
        jsonEncode({'message': description}),
        500,
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
