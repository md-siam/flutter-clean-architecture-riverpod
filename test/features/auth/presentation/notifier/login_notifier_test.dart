import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_template/core/error/response_error.dart';
import 'package:flutter_template/core/injector/injected_providers.dart';
import 'package:flutter_template/shared/base/base_entity.dart';
import 'package:flutter_template/features/auth/domain/use_cases/login_use_case.dart';
import 'package:flutter_template/features/auth/presentation/notifier/login_notifier.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogger extends Mock implements Logger {}

void main() {
  setUpAll(() {
    registerFallbackValue(const LoginEntity(email: '', pin: ''));
  });

  late MockLoginUseCase useCase;
  late MockLogger logger;
  late ProviderContainer container;

  setUp(() {
    useCase = MockLoginUseCase();
    logger = MockLogger();

    container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(useCase),
        loggerProvider.overrideWithValue(logger),
      ],
    );
  });

  tearDown(() => container.dispose());

  const input = LoginEntity(email: 'a@a.com', pin: '123456');

  test('emits loading then success and keeps the submitted entity', () async {
    when(() => useCase.execute(any())).thenAnswer((_) async {});
    final notifier = container.read(loginProvider.notifier);

    final states = <LoginState>[];
    container.listen(loginProvider, (_, next) => states.add(next));

    await notifier.login(input);

    expect(states[0].loginStatus.isLoading, isTrue);
    expect(states[1].loginStatus.isSuccess, isTrue);
    expect(states[1].loginEntity, input);
  });

  test('emits loading then failure when the use case throws', () async {
    when(() => useCase.execute(any())).thenThrow(const ResponseError.unknown());
    final notifier = container.read(loginProvider.notifier);

    final states = <LoginState>[];
    container.listen(loginProvider, (_, next) => states.add(next));

    await notifier.login(input);

    expect(states[0].loginStatus.isLoading, isTrue);
    expect(states[1].loginStatus.isFailure, isTrue);
  });
}
