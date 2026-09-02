import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_template/features/user/domain/repository/subscription_repository.dart';
import 'package:flutter_template/features/user/domain/use_cases/set_subscription_status_use_case.dart';

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

void main() {
  late MockSubscriptionRepository repository;
  late SetSubscriptionStatusUseCase useCase;

  setUp(() {
    repository = MockSubscriptionRepository();
    useCase = SetSubscriptionStatusUseCase(repository);
  });

  test(
    'execute forwards the value to repository.setSubscriptionStatus',
    () async {
      when(
        () => repository.setSubscriptionStatus(any()),
      ).thenAnswer((_) async {});

      await useCase.execute(true);

      verify(() => repository.setSubscriptionStatus(true)).called(1);
    },
  );
}
