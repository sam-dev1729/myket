import 'package:dio/dio.dart';

import '../../../features/profile/data/models/user_profile.dart';
import '../mock_storage.dart';
import 'mock_handler.dart';

/// Mock handler for authentication endpoints.
class AuthHandler extends MockHandler {
  @override
  bool matches(String method, String path) {
    if (method != 'POST') return false;
    return path == '/user/send-otp' ||
        path == '/user/validate-otp' ||
        path == '/user/register-patient' ||
        path == '/user/login-with-google' ||
        path == '/auth/refresh-token' ||
        path == '/auth/logout';
  }

  @override
  Future<ResponseBody> handle(RequestOptions options) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final storage = MockStorage.instance..ensureSeeded();
    final path = options.path;
    final data = _asMap(options.data);

    switch (path) {
      case '/user/send-otp':
        final mobile = _asString(data['mobile']) ?? '';
        storage.otpCodes[mobile] = '12345';
        return mockSuccess({
          'expiresAt': DateTime.now().add(const Duration(minutes: 2)).toUtc().toIso8601String(),
        });

      case '/user/validate-otp':
        final mobile = _asString(data['mobile']) ?? '';
        final user = storage.users[mobile];
        if (user != null) {
          final tokens = _issueTokens(storage, mobile);
          return mockSuccess({
            'is_registered': true,
            'access_token': tokens['access_token'],
            'refresh_token': tokens['refresh_token'],
            'user': user.toJson(),
            'registration_token': null,
            'registration_token_expires_at': null,
          });
        }

        final regToken = 'mock-reg-$mobile';
        storage.registrationTokens[regToken] = mobile;
        return mockSuccess({
          'is_registered': false,
          'access_token': null,
          'refresh_token': null,
          'user': null,
          'registration_token': regToken,
          'registration_token_expires_at': DateTime.now()
              .add(const Duration(minutes: 5))
              .toUtc()
              .toIso8601String(),
        });

      case '/user/register-patient':
        final mobile = _asString(data['mobile']) ?? '';
        final registrationToken = _asString(data['registration_token']);
        if (registrationToken != null) {
          storage.registrationTokens.remove(registrationToken);
        }

        final newUser = UserProfile(
          id: 'mock-user-${DateTime.now().microsecondsSinceEpoch}',
          role: 'PATIENT',
          mobile: mobile,
          firstName: _asString(data['first_name']),
          lastName: _asString(data['last_name']),
          birthDate: _asString(data['birth_date']),
          isMale: _asBool(data['is_male']),
          height: null,
          weight: null,
          isPregnant: null,
          bloodType: null,
          city: null,
          underlyingDiseases: const [],
          medicalHistories: const [],
          allergies: const [],
          localEthnicity: null,
          googleAccounts: _googleAccountsFromData(data),
        );

        storage.users[mobile] = newUser;
        final tokens = _issueTokens(storage, mobile);
        return mockSuccess({
          'is_registered': true,
          'access_token': tokens['access_token'],
          'refresh_token': tokens['refresh_token'],
          'user': newUser.toJson(),
          'registration_token': null,
          'registration_token_expires_at': null,
        });

      case '/user/login-with-google':
        if (storage.users.isEmpty) {
          return mockError(
            statusCode: 404,
            code: 'USER_NOT_FOUND',
            message: 'No seeded mock user found',
          );
        }
        final user = storage.users.values.first;
        final tokens = _issueTokens(storage, user.mobile);
        return mockSuccess({
          'is_registered': true,
          'access_token': tokens['access_token'],
          'refresh_token': tokens['refresh_token'],
          'user': user.toJson(),
          'registration_token': null,
          'registration_token_expires_at': null,
        });

      case '/auth/refresh-token':
        final refreshToken = _bearerToken(options);
        final mobile =
            _mobileFromRefreshToken(refreshToken) ?? _mobileForRefreshToken(storage, refreshToken);
        if (mobile == null) {
          return mockError(statusCode: 401, code: 'UNAUTHORIZED', message: 'Invalid refresh token');
        }

        final accessToken = 'mock-access-$mobile';
        storage.accessTokens[accessToken] = mobile;
        return mockSuccess({'access_token': accessToken});

      case '/auth/logout':
        final accessToken = _bearerToken(options);
        if (accessToken != null) {
          storage.accessTokens.remove(accessToken);
        }
        return mockSuccess({'msg': 'user loged out successfully'});
    }

    return mockError(statusCode: 404, code: 'NOT_FOUND', message: 'Not found');
  }
}

/// Issues mock access/refresh tokens for a mobile number.
Map<String, String> _issueTokens(MockStorage storage, String mobile) {
  final accessToken = 'mock-access-$mobile';
  final refreshToken = 'mock-refresh-$mobile';
  storage.accessTokens[accessToken] = mobile;
  storage.refreshTokens[refreshToken] = mobile;
  return {'access_token': accessToken, 'refresh_token': refreshToken};
}

/// Extracts the bearer token from request headers.
String? _bearerToken(RequestOptions options) {
  final raw = options.headers['Authorization'] ?? options.headers['authorization'];
  final auth = raw is String
      ? raw
      : raw is List && raw.isNotEmpty
      ? raw.first.toString()
      : null;
  if (auth == null || !auth.startsWith('Bearer ')) return null;
  return auth.substring(7);
}

/// Extracts mobile from a mock refresh token.
String? _mobileFromRefreshToken(String? token) {
  if (token == null || !token.startsWith('mock-refresh-')) return null;
  return token.substring('mock-refresh-'.length);
}

/// Looks up mobile by refresh token in mock storage.
String? _mobileForRefreshToken(MockStorage storage, String? token) {
  if (token == null) return null;
  return storage.refreshTokens[token];
}

/// Builds Google accounts from registration payload, when present.
List<GoogleAccount> _googleAccountsFromData(Map<String, dynamic> data) {
  final email = _asString(data['google_email']);
  if (email == null) return const <GoogleAccount>[];

  return [
    GoogleAccount(
      id:
          _asString(data['google_open_id']) ??
          'mock-google-${DateTime.now().microsecondsSinceEpoch}',
      email: email,
      firstName: _asString(data['google_first_name']),
      picture: _asString(data['google_picture']),
    ),
  ];
}

/// Safely converts an arbitrary request payload to a map.
Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  if (value != null) {
    try {
      final dynamic dynamicValue = value;
      final json = dynamicValue.toJson();
      if (json is Map) {
        return json.map((key, item) => MapEntry(key.toString(), item));
      }
    } catch (_) {
      // Ignore objects without a usable toJson().
    }
  }

  return const <String, dynamic>{};
}

/// Converts a value to a non-empty string, or null.
String? _asString(Object? value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

/// Converts a value to a bool, or null.
bool? _asBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;

  final text = value.toString().toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return null;
}
