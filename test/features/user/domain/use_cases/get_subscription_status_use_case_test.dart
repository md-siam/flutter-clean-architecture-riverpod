import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_template/features/user/domain/repository/subscription_repository.dart';
import 'package:flutter_template/features/user/domain/use_cases/get_subscription_status_use_case.dart';

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

void main() {
  late MockSubscriptionRepository repository;
  late GetSubscriptionStatusUseCase useCase;

  setUp(() {
    repository = MockSubscriptionRepository();
    useCase = GetSubscriptionStatusUseCase(repository);
  });

  test('execute returns true when the repository reports subscribed', () {
    when(() => repository.isSubscribed()).thenReturn(true);

    expect(useCase.execute(), isTrue);
  });

  test('execute returns false when the repository reports not subscribed', () {
    when(() => repository.isSubscribed()).thenReturn(false);

    expect(useCase.execute(), isFalse);
  });
}
