import 'dart:convert';

import 'package:calisync/data/trainee_final_week.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('lookup uses active plan completion, not calendar dates', () async {
    final client = SupabaseClient(
      'https://example.supabase.co',
      'test-key',
      httpClient: MockClient((request) async {
        expect(request.url.path, '/rest/v1/workout_plans');
        final query = request.url.queryParameters;
        expect(query['trainee_id'], 'eq.trainee');
        expect(query['status'], 'eq.active');
        expect(query.containsKey('starts_on'), isFalse);
        expect(query['select'], contains('completed'));
        expect(
          query['order'],
          'starts_on.desc.nullslast,created_at.desc.nullslast',
        );
        expect(query['limit'], '1');
        return http.Response(
          jsonEncode([
            {
              'workout_plan_days': [
                for (var week = 1; week <= 5; week++)
                  for (var day = 0; day < 3; day++)
                    {
                      'days': {'week': week, 'completed': week < 5 || day == 0},
                    },
              ],
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      }),
    );
    addTearDown(client.dispose);
    expect(await loadTraineeFinalWeek(client, 'trainee'), isTrue);
  });

  List<TrainingDayProgress> plan({int currentWeek = 5, int lastWeek = 5}) => [
    for (var week = 1; week <= lastWeek; week++)
      for (var day = 0; day < 3; day++)
        (
          week: week,
          completed: week < currentWeek || (week == currentWeek && day == 0),
        ),
  ];

  test('completed weeks 1–4 and one of three days in week 5 enables aura', () {
    expect(isFinalTrainingWeek(plan()), isTrue);
    expect(isFinalTrainingWeek(plan(currentWeek: 4)), isFalse);
    expect(isFinalTrainingWeek(plan(currentWeek: 1)), isFalse);
  });

  test('skipped earlier days prevent premature final-week aura', () {
    final days = plan();
    days[3] = (week: 2, completed: false);
    expect(isFinalTrainingWeek(days), isFalse);
  });

  test('finishing all plan days turns the aura off', () {
    expect(
      isFinalTrainingWeek(
        plan().map((day) => (week: day.week, completed: true)),
      ),
      isFalse,
    );
  });

  test('supports different lengths, deload, and a single-week plan', () {
    expect(isFinalTrainingWeek(plan(currentWeek: 4, lastWeek: 4)), isTrue);
    expect(isFinalTrainingWeek(plan(currentWeek: 4, lastWeek: 5)), isFalse);
    expect(isFinalTrainingWeek(plan(currentWeek: 1, lastWeek: 1)), isTrue);
  });

  test('empty and unnumbered plans do not qualify', () {
    expect(isFinalTrainingWeek([]), isFalse);
    expect(
      isFinalTrainingWeek([
        (week: 0, completed: false),
        (week: -1, completed: false),
      ]),
      isFalse,
    );
    expect(
      isFinalTrainingWeek([...plan(), (week: 0, completed: false)]),
      isTrue,
    );
  });
}
