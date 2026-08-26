import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_config.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!FirebaseConfig.isConfigured) return;
  await Firebase.initializeApp(options: FirebaseConfig.current);
}

class PushNotificationService extends ChangeNotifier {
  PushNotificationService._();

  static final instance = PushNotificationService._();
  static const _firebaseInstallationStorageKey =
      'push_notification_firebase_installation';

  final _client = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  Timer? _registrationRetry;
  String? _registeredToken;
  String? _pendingRoute;
  bool _initialized = false;
  bool _registrationInProgress = false;

  final messengerKey = GlobalKey<ScaffoldMessengerState>();

  bool get isEnabled => _initialized;

  Future<void> initialize() async {
    if (_initialized || !FirebaseConfig.isConfigured) return;
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      await Firebase.initializeApp(options: FirebaseConfig.current);
      await _resetTokenAfterFirebaseProjectChange();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      _initialized = true;
      _authSubscription = _client.auth.onAuthStateChange.listen((state) {
        if (state.session == null) {
          _registeredToken = null;
        } else {
          unawaited(_registerForCurrentUser());
        }
      });
      _tokenSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(
        (token) => unawaited(_registerToken(token)),
      );
      _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        _handleOpenedMessage,
      );
      _foregroundSubscription = FirebaseMessaging.onMessage.listen(
        _showForegroundMessage,
      );

      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) _handleOpenedMessage(initialMessage);
      if (_client.auth.currentSession != null) {
        await _registerForCurrentUser();
      }
    } catch (error, stackTrace) {
      _initialized = false;
      debugPrint('Push notification initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _resetTokenAfterFirebaseProjectChange() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString(_firebaseInstallationStorageKey) ==
        FirebaseConfig.installationKey) {
      return;
    }
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (error) {
      debugPrint('Existing FCM token cleanup failed: $error');
    }
    await preferences.setString(
      _firebaseInstallationStorageKey,
      FirebaseConfig.installationKey,
    );
  }

  Future<void> _registerForCurrentUser() async {
    if (_registrationInProgress) return;
    _registrationInProgress = true;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        _registrationRetry?.cancel();
        await _registerToken(token);
      }
    } catch (error) {
      debugPrint('FCM token request failed; retrying later: $error');
      _registrationRetry?.cancel();
      _registrationRetry = Timer(const Duration(seconds: 30), () {
        if (_initialized && _client.auth.currentSession != null) {
          unawaited(_registerForCurrentUser());
        }
      });
    } finally {
      _registrationInProgress = false;
    }
  }

  Future<void> _registerToken(String token) async {
    if (_client.auth.currentUser == null || token == _registeredToken) return;
    try {
      await _client.rpc(
        'register_push_token',
        params: {
          'p_token': token,
          'p_platform': Platform.isIOS ? 'ios' : 'android',
        },
      );
      _registeredToken = token;
    } catch (error) {
      debugPrint('Push token registration failed: $error');
    }
  }

  Future<void> unregisterCurrentDevice() async {
    if (!_initialized || _client.auth.currentUser == null) return;
    final token =
        _registeredToken ?? await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    try {
      await _client.rpc('unregister_push_token', params: {'p_token': token});
      _registeredToken = null;
    } catch (error) {
      debugPrint('Push token removal failed: $error');
    }
  }

  Future<void> notifyEvent(String type, Object entityId) async {
    if (!_initialized || _client.auth.currentSession == null) return;
    try {
      await _client.functions.invoke(
        'send-push-notification',
        body: {'type': type, 'entityId': entityId.toString()},
      );
    } catch (error) {
      // The underlying data mutation already succeeded. A notification failure
      // must never turn that successful user action into an error.
      debugPrint('Push dispatch failed for $type: $error');
    }
  }

  String? takePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  void _handleOpenedMessage(RemoteMessage message) {
    final route = message.data['route'];
    if (route == null || route.isEmpty) return;
    _pendingRoute = route;
    notifyListeners();
  }

  void _showForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    final route = message.data['route'];
    messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            [
              notification.title,
              notification.body,
            ].whereType<String>().where((value) => value.isNotEmpty).join('\n'),
          ),
          action: route == null || route.isEmpty
              ? null
              : SnackBarAction(
                  label: 'Open',
                  onPressed: () {
                    _pendingRoute = route;
                    notifyListeners();
                  },
                ),
        ),
      );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _tokenSubscription?.cancel();
    _openedSubscription?.cancel();
    _foregroundSubscription?.cancel();
    _registrationRetry?.cancel();
    super.dispose();
  }
}
