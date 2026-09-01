import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_template/data/repository_impl/user/user_subscription_proxy_repository_impl.dart';
import 'package:flutter_template/domain/entity/base/base_entity.dart';
import 'package:flutter_template/domain/exceptions/subscription_required_exception.dart';
import 'package:flutter_template/domain/repository/user/subscription_repository.dart';
import 'package:flutter_template/domain/repository/user/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}

void main() {
  late MockUserRepository innerRepo;
  late MockSubscriptionRepository subscriptionRepo;
  late UserSubscriptionProxyRepositoryImpl repository;

  setUp(() {
    innerRepo = MockUserRepository();
    subscriptionRepo = MockSubscriptionRepository();
    repository = UserSubscriptionProxyRepositoryImpl(
      innerRepo,
      subscriptionRepo,
    );
  });

  const users = [
    UserEntity(
      name: 'Alice',
      email: 'alice@example.com',
      address: 'Street',
      city: 'City',
      latitude: 1,
      longitude: 2,
    ),
  ];

  group('when subscribed', () {
    setUp(() => when(() => subscriptionRepo.isSubscribed()).thenReturn(true));

    test('getUserList delegates to the wrapped repository', () async {
      when(() => innerRepo.getUserList()).thenAnswer((_) async => users);

      final result = await repository.getUserList();

      expect(result, users);
    });

    test('getUserById delegates to the wrapped repository', () async {
      when(
        () => innerRepo.getUserById(userId: 'Alice'),
      ).thenAnswer((_) async => users.first);

      final result = await repository.getUserById(userId: 'Alice');

      expect(result, users.first);
    });
  });

  group('when not subscribed', () {
    setUp(
      () => when(() => subscriptionRepo.isSubscribed()).thenReturn(false),
    );

    test('getUserList throws without touching the wrapped repository', () {
      expect(
        () => repository.getUserList(),
        throwsA(isA<SubscriptionRequiredException>()),
      );
      verifyNever(() => innerRepo.getUserList());
    });

    test('getUserById throws without touching the wrapped repository', () {
      expect(
        () => repository.getUserById(userId: 'Alice'),
        throwsA(isA<SubscriptionRequiredException>()),
      );
      verifyNever(() => innerRepo.getUserById(userId: any(named: 'userId')));
    });
  });
}
