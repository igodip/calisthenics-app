import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class FitbitSyncSummary {
  const FitbitSyncSummary({
    this.activityDate,
    this.steps,
    this.calories,
    this.restingHeartRate,
    this.activeZoneMinutes,
    this.vo2Max,
  });

  final String? activityDate;
  final int? steps;
  final int? calories;
  final int? restingHeartRate;
  final int? activeZoneMinutes;
  final String? vo2Max;

  Map<String, dynamic> toJson() => {
        'activity_date': activityDate,
        'steps': steps,
        'calories': calories,
        'resting_heart_rate': restingHeartRate,
        'active_zone_minutes': activeZoneMinutes,
        'vo2_max': vo2Max,
      };

  factory FitbitSyncSummary.fromJson(Map<String, dynamic> json) {
    return FitbitSyncSummary(
      activityDate: json['activity_date'] as String?,
      steps: _asInt(json['steps']),
      calories: _asInt(json['calories']),
      restingHeartRate: _asInt(json['resting_heart_rate']),
      activeZoneMinutes: _asInt(json['active_zone_minutes']),
      vo2Max: _asString(json['vo2_max']),
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('${value ?? ''}');
  }

  static String? _asString(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }
}

class FitbitHeartRateSample {
  const FitbitHeartRateSample({
    required this.sampledAt,
    required this.value,
  });

  final DateTime sampledAt;
  final int value;

  Map<String, dynamic> toJson() => {
        'sampled_at': sampledAt.toUtc().toIso8601String(),
        'value': value,
      };
}

class FitbitHeartRateWindow {
  const FitbitHeartRateWindow({
    required this.startAt,
    required this.endAt,
    required this.detailLevelUsed,
    required this.samples,
  });

  final DateTime startAt;
  final DateTime endAt;
  final String detailLevelUsed;
  final List<FitbitHeartRateSample> samples;

  Map<String, dynamic> toJson() => {
        'start_at': startAt.toUtc().toIso8601String(),
        'end_at': endAt.toUtc().toIso8601String(),
        'detail_level_used': detailLevelUsed,
        'sample_count': samples.length,
        'samples': samples.map((sample) => sample.toJson()).toList(),
      };

  factory FitbitHeartRateWindow.fromJson(Map<String, dynamic> json) {
    final rawSamples = (json['samples'] as List<dynamic>? ?? const []);
    return FitbitHeartRateWindow(
      startAt: DateTime.parse(json['start_at'] as String).toLocal(),
      endAt: DateTime.parse(json['end_at'] as String).toLocal(),
      detailLevelUsed: json['detail_level_used'] as String? ?? 'unknown',
      samples: rawSamples
          .map((entry) => entry as Map)
          .map(
            (entry) => FitbitHeartRateSample(
              sampledAt: DateTime.parse(entry['sampled_at'] as String).toLocal(),
              value: FitbitSyncSummary._asInt(entry['value']) ?? 0,
            ),
          )
          .toList(),
    );
  }
}

class FitbitConnectionState {
  const FitbitConnectionState({
    required this.isConnected,
    required this.isConnecting,
    this.fitbitUserId,
    this.linkedAt,
    this.lastSyncAt,
    this.lastError,
    this.scopes = const <String>[],
    this.summary,
  });

  final bool isConnected;
  final bool isConnecting;
  final String? fitbitUserId;
  final DateTime? linkedAt;
  final DateTime? lastSyncAt;
  final String? lastError;
  final List<String> scopes;
  final FitbitSyncSummary? summary;

  bool get hasSummary => summary != null;
}

class FitbitService {
  FitbitService._();

  static final FitbitService instance = FitbitService._();
  static const String _supabaseProjectRef = 'jrqjysycoqhlnyufhliy';
  static const String _defaultFunctionsBaseUrl =
      'https://$_supabaseProjectRef.supabase.co/functions/v1';

  static const String _scheme = 'com.idipaolo.calisync';
  static const String _host = 'fitbit-callback';
  static const String redirectUri = '$_scheme://$_host';

  static const String _connectInitUrl = String.fromEnvironment(
    'FITBIT_CONNECT_INIT_URL',
    defaultValue: '$_defaultFunctionsBaseUrl/fitbit-connect-init',
  );
  static const String _syncUrl = String.fromEnvironment(
    'FITBIT_SYNC_URL',
    defaultValue: '$_defaultFunctionsBaseUrl/fitbit-sync',
  );
  static const String _heartRateWindowUrl = String.fromEnvironment(
    'FITBIT_HEART_RATE_WINDOW_URL',
    defaultValue: '$_defaultFunctionsBaseUrl/fitbit-heart-rate-window',
  );

  static const String _connectedKey = 'fitbit_connected';
  static const String _connectingKey = 'fitbit_connecting';
  static const String _fitbitUserIdKey = 'fitbit_user_id';
  static const String _linkedAtKey = 'fitbit_linked_at';
  static const String _lastSyncAtKey = 'fitbit_last_sync_at';
  static const String _lastErrorKey = 'fitbit_last_error';
  static const String _scopesKey = 'fitbit_scopes';
  static const String _summaryKey = 'fitbit_summary';

  bool get hasConnectConfiguration => _connectInitUrl.trim().isNotEmpty;
  bool get hasSyncConfiguration => _syncUrl.trim().isNotEmpty;
  bool get hasHeartRateWindowConfiguration =>
      _heartRateWindowUrl.trim().isNotEmpty;

  Future<FitbitConnectionState> loadState() async {
    final preferences = await SharedPreferences.getInstance();
    final summaryJson = preferences.getString(_summaryKey);

    return FitbitConnectionState(
      isConnected: preferences.getBool(_connectedKey) ?? false,
      isConnecting: preferences.getBool(_connectingKey) ?? false,
      fitbitUserId: preferences.getString(_fitbitUserIdKey),
      linkedAt: _parseDate(preferences.getString(_linkedAtKey)),
      lastSyncAt: _parseDate(preferences.getString(_lastSyncAtKey)),
      lastError: preferences.getString(_lastErrorKey),
      scopes: preferences.getStringList(_scopesKey) ?? const <String>[],
      summary: summaryJson == null || summaryJson.isEmpty
          ? null
          : FitbitSyncSummary.fromJson(
              jsonDecode(summaryJson) as Map<String, dynamic>,
            ),
    );
  }

  Future<void> startConnection({
    required String userId,
  }) async {
    if (!hasConnectConfiguration) {
      throw const FitbitServiceException(
        'FITBIT_CONNECT_INIT_URL is not configured.',
      );
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw const FitbitServiceException('User is not authenticated.');
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_connectingKey, true);
    await preferences.remove(_lastErrorKey);

    final response = await http.get(
      Uri.parse(_connectInitUrl).replace(
        queryParameters: <String, String>{
          'redirect_uri': redirectUri,
          'user_id': userId,
        },
      ),
      headers: <String, String>{
        'Authorization': 'Bearer ${session.accessToken}',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      await preferences.setBool(_connectingKey, false);
      throw FitbitServiceException(
        'Unable to initialize Fitbit connection: ${response.statusCode} ${response.body}',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      await preferences.setBool(_connectingKey, false);
      throw const FitbitServiceException(
        'Unexpected Fitbit connection init response format.',
      );
    }
    final authorizeUrl = payload['authorize_url']?.toString().trim() ?? '';
    if (authorizeUrl.isEmpty) {
      await preferences.setBool(_connectingKey, false);
      throw const FitbitServiceException(
        'Fitbit connection init did not return an authorize URL.',
      );
    }
    final connectUri = Uri.parse(authorizeUrl);

    final launched = await launchUrl(
      connectUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      await preferences.setBool(_connectingKey, false);
      throw FitbitServiceException(
        'Unable to open Fitbit connection URL: $connectUri',
      );
    }
  }

  Future<FitbitConnectionState> syncLatestData() async {
    if (!hasSyncConfiguration) {
      throw const FitbitServiceException(
        'FITBIT_SYNC_URL is not configured.',
      );
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw const FitbitServiceException('User is not authenticated.');
    }

    final response = await http.get(
      Uri.parse(_syncUrl),
      headers: <String, String>{
        'Authorization': 'Bearer ${session.accessToken}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FitbitServiceException(
        'Sync request failed with status ${response.statusCode}.',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const FitbitServiceException('Unexpected sync response format.');
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_connectedKey, true);
    await preferences.setBool(_connectingKey, false);
    await preferences.remove(_lastErrorKey);

    final lastSyncAt = payload['last_sync_at'] as String? ??
        DateTime.now().toUtc().toIso8601String();
    await preferences.setString(_lastSyncAtKey, lastSyncAt);

    final fitbitUserId = payload['fitbit_user_id'] as String?;
    if (fitbitUserId != null && fitbitUserId.isNotEmpty) {
      await preferences.setString(_fitbitUserIdKey, fitbitUserId);
    }

    final scopeValue = payload['scope'];
    if (scopeValue is String && scopeValue.trim().isNotEmpty) {
      await preferences.setStringList(
        _scopesKey,
        scopeValue.split(RegExp(r'[\s,]+')).where((scope) => scope.isNotEmpty).toList(),
      );
    }

    final summaryMap = payload['summary'];
    if (summaryMap is Map<String, dynamic>) {
      await preferences.setString(_summaryKey, jsonEncode(summaryMap));
    }

    return loadState();
  }

  Future<FitbitHeartRateWindow> fetchHeartRateWindow({
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    if (!hasHeartRateWindowConfiguration) {
      throw const FitbitServiceException(
        'FITBIT_HEART_RATE_WINDOW_URL is not configured.',
      );
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw const FitbitServiceException('User is not authenticated.');
    }

    final response = await http.get(
      Uri.parse(_heartRateWindowUrl).replace(
        queryParameters: {
          'start_at': startAt.toUtc().toIso8601String(),
          'end_at': endAt.toUtc().toIso8601String(),
        },
      ),
      headers: <String, String>{
        'Authorization': 'Bearer ${session.accessToken}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FitbitServiceException(
        'Heart-rate window request failed with status ${response.statusCode}: ${response.body}',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const FitbitServiceException(
        'Unexpected heart-rate window response format.',
      );
    }

    return FitbitHeartRateWindow.fromJson(payload);
  }

  Future<bool> handleCallback(Uri uri) async {
    if (uri.scheme != _scheme || uri.host != _host) {
      return false;
    }

    final preferences = await SharedPreferences.getInstance();
    final status = uri.queryParameters['status'];
    final errorMessage = uri.queryParameters['error'] ??
        uri.queryParameters['message'];

    if (status == 'error' || errorMessage != null) {
      await preferences.setBool(_connectingKey, false);
      await preferences.setString(
        _lastErrorKey,
        errorMessage ?? 'Fitbit connection failed.',
      );
      return true;
    }

    final linkedAt = uri.queryParameters['linked_at'] ??
        DateTime.now().toUtc().toIso8601String();
    final fitbitUserId = uri.queryParameters['fitbit_user_id'];
    final scopeValue = uri.queryParameters['scope'];

    await preferences.setBool(_connectedKey, true);
    await preferences.setBool(_connectingKey, false);
    await preferences.setString(_linkedAtKey, linkedAt);
    await preferences.remove(_lastErrorKey);

    if (fitbitUserId != null && fitbitUserId.isNotEmpty) {
      await preferences.setString(_fitbitUserIdKey, fitbitUserId);
    }
    if (scopeValue != null && scopeValue.trim().isNotEmpty) {
      await preferences.setStringList(
        _scopesKey,
        scopeValue.split(RegExp(r'[\s,]+')).where((scope) => scope.isNotEmpty).toList(),
      );
    }

    return true;
  }

  Future<void> disconnect() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_connectedKey);
    await preferences.remove(_connectingKey);
    await preferences.remove(_fitbitUserIdKey);
    await preferences.remove(_linkedAtKey);
    await preferences.remove(_lastSyncAtKey);
    await preferences.remove(_lastErrorKey);
    await preferences.remove(_scopesKey);
    await preferences.remove(_summaryKey);
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toLocal();
  }
}

class FitbitServiceException implements Exception {
  const FitbitServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
