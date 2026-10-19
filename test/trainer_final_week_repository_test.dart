import 'dart:convert';

import 'package:calisync/trainer/trainer_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'support/store_demo_backend.dart';

void main() {
  test('batch lookup uses only each trainee’s newest active plan', () async {
    final fixture = StoreDemoBackend();
    var planRequests = 0;
    Map<String, dynamic> plan(String trainee, {required bool finalWeek}) => {
      'trainee_id': trainee,
      'workout_plan_days': [
        {
          'days': {'week': 1, 'completed': finalWeek},
        },
        {
          'days': {'week': 2, 'completed': false},
        },
      ],
    };
    final client = SupabaseClient(
      'https://example.supabase.co',
      'test-key',
      httpClient: MockClient((request) async {
        Object result;
        switch (request.url.path) {
          case '/auth/v1/user':
            result = fixture.user;
          case '/rest/v1/trainees':
            expect(
              request.url.queryParameters['trainee_trainers.trainer_id'],
              'eq.${StoreDemoBackend.userId}',
            );
            result = [
              for (final id in ['first', 'second'])
                {
                  'id': id,
                  'name': id,
                  'trainee_trainers': [
                    {'trainer_id': StoreDemoBackend.userId},
                  ],
                },
            ];
          case '/rest/v1/rpc/current_payment_month':
            result = '2026-10-01';
          case '/rest/v1/workout_plans':
            planRequests++;
            expect(request.url.queryParameters['status'], 'eq.active');
            expect(
              request.url.queryParameters['select'],
              contains('days(week,completed)'),
            );
            expect(
              request.url.queryParameters['order'],
              'starts_on.desc.nullslast,created_at.desc.nullslast',
            );
            result = [
              plan('first', finalWeek: false),
              plan('second', finalWeek: true),
              plan('first', finalWeek: true),
            ];
          case '/rest/v1/trainee_monthly_payments':
            result = [];
          case '/rest/v1/day_exercises':
            result = [];
          default:
            throw StateError('Unexpected request ${request.url.path}');
        }
        return http.Response(
          jsonEncode(result),
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      }),
    );
    addTearDown(client.dispose);
    await client.auth.recoverSession(jsonEncode(fixture.session));
    final trainees = await TrainerRepository(client).loadTrainees();
    expect(trainees.first.isInFinalWeek, isFalse);
    expect(trainees.first.activePlanCount, 2);
    expect(trainees.last.isInFinalWeek, isTrue);
    expect(planRequests, 1);
  });
}
