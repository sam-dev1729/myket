import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage service for managing authentication tokens securely.
/// 
/// Uses `flutter_secure_storage` to store tokens in a platform-specific
/// secure storage (Keychain on iOS, EncryptedSharedPreferences on Android).
class TokenStorage {
  final _storage = const FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';

  /// Saves both access and refresh tokens to secure storage.
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  /// Retrieves the stored access token, if any.
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  /// Retrieves the stored refresh token, if any.
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// Clears all tokens from secure storage.
  Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }
}

/// Riverpod provider for [TokenStorage].
/// 
/// Overridable in tests to inject a mock implementation.
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});