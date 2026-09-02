import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_template/shared/base/base_entity.dart';
import 'package:flutter_template/features/user/domain/repository/user_repository.dart';
import 'package:flutter_template/features/user/domain/use_cases/get_user_list_use_case.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository repository;
  late GetUserListUseCase useCase;

  setUp(() {
    repository = MockUserRepository();
    useCase = GetUserListUseCase(repository);
  });

  test(
    'execute delegates to repository.getUserList and returns its result',
    () async {
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
      when(() => repository.getUserList()).thenAnswer((_) async => users);

      final result = await useCase.execute();

      expect(result, users);
      verify(() => repository.getUserList()).called(1);
    },
  );
}
