import 'dart:async';

import 'package:calisync/data/locale_catalog_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a stalled request times out and does not poison later loads', () async {
    final cache = LocaleCatalogCache<int>(
      requestTimeout: const Duration(milliseconds: 1),
    );
    final stalled = Completer<int>();
    await expectLater(
      cache.load('en', () => stalled.future),
      throwsA(isA<TimeoutException>()),
    );
    expect(await cache.load('en', () async => 2), 2);
    stalled.complete(1);
    expect(await cache.load('en', () async => 3), 2);
  });
  test('offline failure is evicted and a subsequent load recovers', () async {
    final cache = LocaleCatalogCache<List<String>>();
    var online = false;
    var requests = 0;
    Future<List<String>> fetch() async {
      requests++;
      if (!online) throw StateError('offline');
      return ['recovered'];
    }

    await expectLater(cache.load('it_IT', fetch), throwsStateError);
    online = true;
    expect(await cache.load('IT-it', fetch), ['recovered']);
    expect(requests, 2);
  });

  test(
    'concurrent loads share a request and normalize regional locales',
    () async {
      final cache = LocaleCatalogCache<int>();
      final pending = Completer<int>();
      var requests = 0;
      Future<int> fetch() {
        requests++;
        return pending.future;
      }

      final first = cache.load(' en-US ', fetch);
      final second = cache.load('en_GB', fetch);
      expect(identical(first, second), isTrue);
      pending.complete(1);
      expect(await second, 1);
      expect(requests, 1);
    },
  );

  test('successful entries refresh after expiry, not on every load', () async {
    var time = DateTime(2026, 10, 21);
    final cache = LocaleCatalogCache<int>(now: () => time);
    var revision = 1;
    Future<int> fetch() async => revision;
    expect(await cache.load('en', fetch), 1);
    revision = 2;
    expect(await cache.load('en', fetch), 1);
    time = time.add(const Duration(minutes: 5));
    expect(await cache.load('en', fetch), 2);
  });

  test(
    'force refresh and locale/all invalidation fetch updated catalogs',
    () async {
      final cache = LocaleCatalogCache<int>();
      var revision = 1;
      Future<int> fetch() async => revision;
      await cache.load('it', fetch);
      await cache.load('es', fetch);
      revision = 2;
      expect(await cache.load('it', fetch, forceRefresh: true), 2);
      expect(await cache.load('es', fetch), 1);
      cache.invalidate(locale: 'es-ES');
      expect(await cache.load('es', fetch), 2);
      revision = 3;
      cache.invalidate();
      expect(await cache.load('it', fetch), 3);
      expect(await cache.load('es', fetch), 3);
    },
  );

  for (final failOld in [false, true]) {
    test(
      'superseded ${failOld ? 'failure' : 'success'} cannot replace refreshed data',
      () async {
        final cache = LocaleCatalogCache<int>();
        final old = Completer<int>();
        final first = cache.load('en', () => old.future);
        final observed = failOld ? expectLater(first, throwsStateError) : first;
        expect(await cache.load('en', () async => 2, forceRefresh: true), 2);
        if (failOld) {
          old.completeError(StateError('old failure'));
        } else {
          old.complete(1);
        }
        await observed;
        expect(await cache.load('en', () async => 3), 2);
      },
    );
  }
}
