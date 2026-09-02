import 'package:flutter_template/features/user/domain/repository/subscription_repository.dart';

class GetSubscriptionStatusUseCase {
  GetSubscriptionStatusUseCase(this._subscriptionRepository);

  final SubscriptionRepository _subscriptionRepository;

  bool execute() => _subscriptionRepository.isSubscribed();
}
