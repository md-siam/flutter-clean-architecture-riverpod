import 'package:flutter_template/shared/base/base_entity.dart';
import 'package:flutter_template/features/user/domain/exceptions/subscription_required_exception.dart';
import 'package:flutter_template/features/user/domain/repository/subscription_repository.dart';
import 'package:flutter_template/features/user/domain/repository/user_repository.dart';

/// Proxy around a cache-backed [UserRepository]: gates every call behind
/// the subscription check. Only wired in for staging/production — see
/// `userRepositoryProvider` in `injected_providers.dart`.
class UserSubscriptionProxyRepositoryImpl implements UserRepository {
  UserSubscriptionProxyRepositoryImpl(
    this._repository,
    this._subscriptionRepository,
  );

  final UserRepository _repository;
  final SubscriptionRepository _subscriptionRepository;

  @override
  Future<List<UserEntity>> getUserList() async {
    _ensureSubscribed();
    return _repository.getUserList();
  }

  @override
  Future<UserEntity> getUserById({required String userId}) async {
    _ensureSubscribed();
    return _repository.getUserById(userId: userId);
  }

  void _ensureSubscribed() {
    if (!_subscriptionRepository.isSubscribed()) {
      throw const SubscriptionRequiredException();
    }
  }
}
