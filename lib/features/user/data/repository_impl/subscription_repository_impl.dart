import 'package:flutter_template/features/user/data/data_source/local/subscription_local_data_source.dart';
import 'package:flutter_template/features/user/domain/repository/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl(this._subscriptionDataSource);

  final SubscriptionLocalDataSource _subscriptionDataSource;

  @override
  bool isSubscribed() => _subscriptionDataSource.isSubscribed();

  @override
  Future<void> setSubscriptionStatus(bool value) =>
      _subscriptionDataSource.setSubscriptionStatus(value);
}
