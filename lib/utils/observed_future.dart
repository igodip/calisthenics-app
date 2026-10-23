import 'dart:async';

/// FutureBuilder subscribes on the next frame after setState. Polling while
/// idle can fail before that frame, so observe errors immediately as well.
/// Return the original future: the widget must still receive the failure and
/// show its error/retry UI, not mistake a network error for unpaid access.
Future<T> observedFuture<T>(Future<T> future) {
  unawaited(
    future.then<void>((_) {}, onError: (Object _, StackTrace stack) {}),
  );
  return future;
}
