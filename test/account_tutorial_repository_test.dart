import 'dart:convert';

import 'package:calisync/data/account_tutorial_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'support/store_demo_backend.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  bool online = true, remoteDone = false;
  var writes = 0;
  late SupabaseClient client;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    online = true;
    remoteDone = false;
    writes = 0;
    final fixture = StoreDemoBackend();
    client = SupabaseClient(
      'https://example.supabase.co',
      'test-key',
      httpClient: MockClient((request) async {
        if (request.url.path == '/auth/v1/user') {
          return http.Response(
            jsonEncode(fixture.user),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }
        expect(request.url.path, '/rest/v1/account_tutorials');
        if (!online) {
          return http.Response(
            '{"message":"offline","code":"offline"}',
            400,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }
        if (request.method == 'GET') {
          expect(
            request.url.queryParameters['user_id'],
            'eq.${StoreDemoBackend.userId}',
          );
          return http.Response(
            jsonEncode(
              remoteDone
                  ? [
                      {'user_id': StoreDemoBackend.userId},
                    ]
                  : [],
            ),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }
        final body = jsonDecode(request.body) as Map;
        expect(body['user_id'], StoreDemoBackend.userId);
        expect(
          request.headers['prefer'],
          contains('resolution=ignore-duplicates'),
        );
        writes++;
        remoteDone = true;
        return http.Response('', 201, request: request);
      }),
    );
    await client.auth.recoverSession(jsonEncode(fixture.session));
  });
  tearDown(() async {
    await client.dispose();
  });

  test('completion is account scoped and survives a fresh device', () async {
    final repo = AccountTutorialRepository(
      StoreDemoBackend.userId,
      client: client,
    );
    expect(await repo.hasCompleted(), isFalse);
    await repo.complete(skipped: false);
    expect(remoteDone, isTrue);
    SharedPreferences.setMockInitialValues({});
    expect(
      await AccountTutorialRepository(
        StoreDemoBackend.userId,
        client: client,
      ).hasCompleted(),
      isTrue,
    );
    expect(writes, 1);
  });

  test('offline skip is remembered locally and synced on recovery', () async {
    final repo = AccountTutorialRepository(
      StoreDemoBackend.userId,
      client: client,
    );
    online = false;
    await repo.complete(skipped: true);
    expect(await repo.hasCompleted(), isTrue);
    expect(remoteDone, isFalse);
    online = true;
    await repo.syncPending();
    expect(remoteDone, isTrue);
    expect(
      (await SharedPreferences.getInstance()).getBool(
        'account_tutorial_pending:${StoreDemoBackend.userId}',
      ),
      isNull,
    );
  });

  test('failed lookup is not mistaken for completion', () async {
    final repo = AccountTutorialRepository(
      StoreDemoBackend.userId,
      client: client,
    );
    online = false;
    await expectLater(repo.hasCompleted(), throwsA(isA<PostgrestException>()));
    online = true;
    expect(await repo.hasCompleted(), isFalse);
  });

  test(
    'another account cannot reuse local completion or write a receipt',
    () async {
      await AccountTutorialRepository(
        StoreDemoBackend.userId,
        client: client,
      ).complete(skipped: true);
      final other = AccountTutorialRepository('other-account', client: client);
      await expectLater(other.hasCompleted(), throwsStateError);
      await expectLater(other.complete(skipped: true), throwsStateError);
      expect(writes, 1);
    },
  );
}
