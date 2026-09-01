import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around [FlutterSecureStorage] for access-token storage.
///
/// Provided via DI (see `injected_providers.dart`) so it can be mocked in
/// tests instead of relying on a global static.
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';

  Future<void> setAccessToken(String token) {
    return _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<bool> hasAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAccessToken() {
    return _storage.delete(key: _accessTokenKey);
  }

  String generateToken() {
    final random = Random.secure();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'mock_access_token_${timestamp}_${random.nextInt(999999)}';
  }
}
