import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_template/core/error/response_error.dart';
import 'package:flutter_template/core/injector/injected_providers.dart';
import 'package:flutter_template/shared/base/base_entity.dart';
import 'package:flutter_template/features/user/domain/exceptions/subscription_required_exception.dart';
import 'package:flutter_template/features/user/domain/use_cases/get_subscription_status_use_case.dart';
import 'package:flutter_template/features/user/domain/use_cases/get_user_list_use_case.dart';
import 'package:flutter_template/features/user/domain/use_cases/set_subscription_status_use_case.dart';
import 'package:flutter_template/features/user/presentation/notifier/user_notifier.dart';
import 'package:flutter_template/features/user/presentation/notifier/user_state.dart';

class MockGetUserListUseCase extends Mock implements GetUserListUseCase {}

class MockGetSubscriptionStatusUseCase extends Mock
    implements GetSubscriptionStatusUseCase {}

class MockSetSubscriptionStatusUseCase extends Mock
    implements SetSubscriptionStatusUseCase {}

class MockLogger extends Mock implements Logger {}

void main() {
  late MockGetUserListUseCase useCase;
  late MockGetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  late MockSetSubscriptionStatusUseCase setSubscriptionStatusUseCase;
  late MockLogger logger;
  late ProviderContainer container;

  setUp(() {
    useCase = MockGetUserListUseCase();
    getSubscriptionStatusUseCase = MockGetSubscriptionStatusUseCase();
    setSubscriptionStatusUseCase = MockSetSubscriptionStatusUseCase();
    logger = MockLogger();

    // Default mock for build() initialization
    when(() => getSubscriptionStatusUseCase.execute()).thenReturn(false);

    // Override the get_it-backed wrapper providers with mocks — the real
    // DI container is never touched.
    container = ProviderContainer(
      overrides: [
        getUserListUseCaseProvider.overrideWithValue(useCase),
        getSubscriptionStatusUseCaseProvider.overrideWithValue(
          getSubscriptionStatusUseCase,
        ),
        setSubscriptionStatusUseCaseProvider.overrideWithValue(
          setSubscriptionStatusUseCase,
        ),
        loggerProvider.overrideWithValue(logger),
      ],
    );
  });

  tearDown(() => container.dispose());

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

  test('emits loading then success with the fetched users', () async {
    when(() => useCase.execute()).thenAnswer((_) async => users);
    final notifier = container.read(userProvider.notifier);

    final states = <UserState>[];
    container.listen(userProvider, (_, next) => states.add(next));

    await notifier.getUserList();

    expect(states[0].status.isLoading, isTrue);
    expect(states[1].status.isSuccess, isTrue);
    expect(states[1].userList, users);
  });

  test('emits loading then failure when the use case throws', () async {
    when(() => useCase.execute()).thenThrow(const ResponseError.notFound());
    final notifier = container.read(userProvider.notifier);

    final states = <UserState>[];
    container.listen(userProvider, (_, next) => states.add(next));

    await notifier.getUserList();

    expect(states[0].status.isLoading, isTrue);
    expect(states[1].status.isFailure, isTrue);
  });

  test('emits isSubscriptionRequired when the proxy blocks access', () async {
    when(
      () => useCase.execute(),
    ).thenThrow(const SubscriptionRequiredException());
    final notifier = container.read(userProvider.notifier);

    final states = <UserState>[];
    container.listen(userProvider, (_, next) => states.add(next));

    await notifier.getUserList();

    expect(states[0].status.isLoading, isTrue);
    expect(states[1].isSubscriptionRequired, isTrue);
    expect(states[1].status.isFailure, isFalse);
  });

  test('subscribeAndRefresh subscribes then refetches the user list', () async {
    when(
      () => setSubscriptionStatusUseCase.execute(true),
    ).thenAnswer((_) async {});
    when(() => useCase.execute()).thenAnswer((_) async => users);
    final notifier = container.read(userProvider.notifier);

    await notifier.subscribeAndRefresh();

    verify(() => setSubscriptionStatusUseCase.execute(true)).called(1);
    final state = container.read(userProvider);
    expect(state.isSubscribed, isTrue);
    expect(state.status.isSuccess, isTrue);
    expect(state.userList, users);
  });
}
