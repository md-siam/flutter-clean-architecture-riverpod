import 'package:flutter_template/features/user/data/data_source/local/user_local_data_source.dart';
import 'package:flutter_template/features/user/domain/entity/user_entity.dart';
import 'package:flutter_template/features/user/domain/repository/user_repository.dart';

/// Decorator around a remote-backed [UserRepository]: cache-first reads,
/// with the cache filled from whichever repository it wraps.
class UserCacheRepositoryImpl implements UserRepository {
  UserCacheRepositoryImpl(this._remoteRepo, this._localDataSource);

  final UserRepository _remoteRepo;
  final UserLocalDataSource _localDataSource;

  @override
  Future<List<UserEntity>> getUserList() async {
    // 1. Try to serve from cache first
    final localUsers = await _localDataSource.getUserList();
    if (localUsers.isNotEmpty) {
      return localUsers;
    }

    // 2. If cache is empty, fetch from remote
    final remoteUsers = await _remoteRepo.getUserList();

    // 3. Update cache
    await _localDataSource.saveUserList(remoteUsers);

    return remoteUsers;
  }

  @override
  Future<UserEntity> getUserById({required String userId}) async {
    // 1. Try to serve from cache first
    final cachedUser = await _localDataSource.getUserById(userId: userId);
    if (cachedUser != null) {
      return cachedUser;
    }

    // 2. Cache miss: fetch from remote
    final remoteUser = await _remoteRepo.getUserById(userId: userId);

    // 3. Update cache
    await _localDataSource.saveUser(remoteUser);

    return remoteUser;
  }
}
