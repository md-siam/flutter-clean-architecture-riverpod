import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_template/core/env/app_environment.dart';
import 'package:flutter_template/core/env/env.dart';
import 'package:flutter_template/core/helper/secure_storage_service.dart';
import 'package:flutter_template/data/data_source/auth/mock/auth_mock_data_source.dart';
import 'package:flutter_template/data/data_source/auth/remote/auth_remote_data_source.dart';
import 'package:flutter_template/data/data_source/base/auth_interceptor.dart';
import 'package:flutter_template/data/data_source/base/backend_error_interceptor.dart';
import 'package:flutter_template/data/data_source/base/factory/data_source_factory.dart';
import 'package:flutter_template/data/data_source/base/factory/mock_data_source_factory.dart';
import 'package:flutter_template/data/data_source/base/factory/remote_data_source_factory.dart';
import 'package:flutter_template/data/data_source/user/local/subscription_local_data_source.dart';
import 'package:flutter_template/data/data_source/user/local/user_local_data_source.dart';
import 'package:flutter_template/data/data_source/user/mock/user_mock_data_source.dart';
import 'package:flutter_template/data/data_source/user/remote/user_remote_data_source.dart';
import 'package:flutter_template/data/repository_impl/auth/auth_repository_impl.dart';
import 'package:flutter_template/data/repository_impl/user/subscription_repository_impl.dart';
import 'package:flutter_template/data/repository_impl/user/user_cache_repository_impl.dart';
import 'package:flutter_template/data/repository_impl/user/user_repository_impl.dart';
import 'package:flutter_template/data/repository_impl/user/user_subscription_proxy_repository_impl.dart';
import 'package:flutter_template/domain/repository/auth/auth_repository.dart';
import 'package:flutter_template/domain/repository/user/subscription_repository.dart';
import 'package:flutter_template/domain/repository/user/user_repository.dart';
import 'package:flutter_template/domain/use_cases/auth/login_use_case.dart';
import 'package:flutter_template/domain/use_cases/user/get_subscription_status_use_case.dart';
import 'package:flutter_template/domain/use_cases/user/get_user_list_use_case.dart';
import 'package:flutter_template/domain/use_cases/user/set_subscription_status_use_case.dart';

part 'injected_providers.g.dart';

// The app's whole dependency graph, wired with riverpod_generator instead of
// get_it/injectable. Every provider is `keepAlive: true` so it behaves like
// a singleton — built once and reused for the app's lifetime — while still
// being trivially overridable in tests (see "Testing conventions" in
// CLAUDE.md): override the leaf provider a test cares about and every
// provider built on top of it picks up the mock.

@Riverpod(keepAlive: true)
Logger logger(Ref ref) => Logger();

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) =>
    const FlutterSecureStorage(aOptions: AndroidOptions());

@Riverpod(keepAlive: true)
SecureStorageService secureStorageService(Ref ref) =>
    SecureStorageService(ref.watch(secureStorageProvider));

/// Resolved once during bootstrap ([Env.bootstrap]) and handed in via
/// `ProviderScope.overrides` — mirrors get_it's `@preResolve`, so every
/// other provider in this file can stay synchronous.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) => throw UnimplementedError(
  'sharedPreferencesProvider must be overridden in ProviderScope — see '
  'Env.bootstrap.',
);

Dio _createBaseDio() {
  final dio = Dio()..options.baseUrl = Env.shared.baseUrl;
  dio.options.connectTimeout = const Duration(seconds: 12);
  dio.options.receiveTimeout = const Duration(seconds: 12);
  dio.options.contentType = 'application/json';
  dio.interceptors.add(BackendErrorInterceptor());
  return dio;
}

@Riverpod(keepAlive: true)
Dio unauthenticatedDio(Ref ref) => _createBaseDio();

@Riverpod(keepAlive: true)
Dio authenticatedDio(Ref ref) {
  final dio = _createBaseDio();
  dio.interceptors.add(AuthInterceptor(ref.watch(secureStorageServiceProvider)));
  return dio;
}

@Riverpod(keepAlive: true)
AuthMockDataSource authMockDataSource(Ref ref) => AuthMockDataSource();

@Riverpod(keepAlive: true)
UserMockDataSource userMockDataSource(Ref ref) => UserMockDataSource();

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) =>
    AuthRemoteDataSource(ref.watch(unauthenticatedDioProvider));

@Riverpod(keepAlive: true)
UserRemoteDataSource userRemoteDataSource(Ref ref) =>
    UserRemoteDataSource(ref.watch(unauthenticatedDioProvider));

/// Abstract Factory: which concrete data sources get built is decided here,
/// by flavor, so repositories never know whether they're talking to mocks
/// or the real API.
@Riverpod(keepAlive: true)
DataSourceFactory dataSourceFactory(Ref ref) {
  if (Env.shared.name == AppEnvironment.development) {
    return MockDataSourceFactory(
      ref.watch(userMockDataSourceProvider),
      ref.watch(authMockDataSourceProvider),
    );
  }
  return RemoteDataSourceFactory(
    ref.watch(userRemoteDataSourceProvider),
    ref.watch(authRemoteDataSourceProvider),
  );
}

@Riverpod(keepAlive: true)
UserLocalDataSource userLocalDataSource(Ref ref) =>
    UserLocalDataSourceImpl(ref.watch(sharedPreferencesProvider));

@Riverpod(keepAlive: true)
SubscriptionLocalDataSource subscriptionLocalDataSource(Ref ref) =>
    SubscriptionLocalDataSource(ref.watch(sharedPreferencesProvider));

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  ref.watch(dataSourceFactoryProvider),
  ref.watch(secureStorageServiceProvider),
);

@Riverpod(keepAlive: true)
SubscriptionRepository subscriptionRepository(Ref ref) =>
    SubscriptionRepositoryImpl(ref.watch(subscriptionLocalDataSourceProvider));

@Riverpod(keepAlive: true)
UserRepository userRemoteRepository(Ref ref) =>
    UserRepositoryImpl(ref.watch(dataSourceFactoryProvider));

/// Decorator: cache-first reads/writes layered around the remote repository.
@Riverpod(keepAlive: true)
UserRepository userCacheRepository(Ref ref) => UserCacheRepositoryImpl(
  ref.watch(userRemoteRepositoryProvider),
  ref.watch(userLocalDataSourceProvider),
);

/// Proxy: gates every call behind the subscription check. Development builds
/// skip the paywall entirely and resolve straight to the cache repository.
@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  final cached = ref.watch(userCacheRepositoryProvider);
  if (Env.shared.name == AppEnvironment.development) {
    return cached;
  }
  return UserSubscriptionProxyRepositoryImpl(
    cached,
    ref.watch(subscriptionRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
GetUserListUseCase getUserListUseCase(Ref ref) =>
    GetUserListUseCase(ref.watch(userRepositoryProvider));

@Riverpod(keepAlive: true)
GetSubscriptionStatusUseCase getSubscriptionStatusUseCase(Ref ref) =>
    GetSubscriptionStatusUseCase(ref.watch(subscriptionRepositoryProvider));

@Riverpod(keepAlive: true)
SetSubscriptionStatusUseCase setSubscriptionStatusUseCase(Ref ref) =>
    SetSubscriptionStatusUseCase(ref.watch(subscriptionRepositoryProvider));

@Riverpod(keepAlive: true)
LoginUseCase loginUseCase(Ref ref) =>
    LoginUseCase(ref.watch(authRepositoryProvider));

// New features scaffolded by ./create_feature.sh append their providers
// below this line — see the script's "Add providers to injected_providers"
// step.
