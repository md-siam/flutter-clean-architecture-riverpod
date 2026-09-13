import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_template/features/user/data/data_source/local/user_local_data_source.dart';
import 'package:flutter_template/features/user/data/repository_impl/user_cache_repository_impl.dart';
import 'package:flutter_template/features/user/domain/entity/user_entity.dart';
import 'package:flutter_template/features/user/domain/repository/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockUserLocalDataSource extends Mock implements UserLocalDataSource {}

void main() {
  late MockUserRepository remoteRepo;
  late MockUserLocalDataSource localDataSource;
  late UserCacheRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const <UserEntity>[]);
    registerFallbackValue(
      const UserEntity(
        name: '',
        email: '',
        address: '',
        city: '',
        latitude: 0,
        longitude: 0,
      ),
    );
  });

  setUp(() {
    remoteRepo = MockUserRepository();
    localDataSource = MockUserLocalDataSource();
    repository = UserCacheRepositoryImpl(remoteRepo, localDataSource);
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

  group('getUserList', () {
    test('serves from cache without calling the remote repository', () async {
      when(() => localDataSource.getUserList()).thenAnswer((_) async => users);

      final result = await repository.getUserList();

      expect(result, users);
      verifyNever(() => remoteRepo.getUserList());
    });

    test('falls back to remote and fills the cache when empty', () async {
      when(() => localDataSource.getUserList()).thenAnswer((_) async => []);
      when(() => remoteRepo.getUserList()).thenAnswer((_) async => users);
      when(() => localDataSource.saveUserList(any())).thenAnswer((_) async {});

      final result = await repository.getUserList();

      expect(result, users);
      verify(() => localDataSource.saveUserList(users)).called(1);
    });
  });

  group('getUserById', () {
    const userId = 'Alice';

    test('serves from cache without calling the remote repository', () async {
      when(
        () => localDataSource.getUserById(userId: userId),
      ).thenAnswer((_) async => users.first);

      final result = await repository.getUserById(userId: userId);

      expect(result, users.first);
      verifyNever(() => remoteRepo.getUserById(userId: any(named: 'userId')));
    });

    test('falls back to remote and caches the result on a miss', () async {
      when(
        () => localDataSource.getUserById(userId: userId),
      ).thenAnswer((_) async => null);
      when(
        () => remoteRepo.getUserById(userId: userId),
      ).thenAnswer((_) async => users.first);
      when(() => localDataSource.saveUser(any())).thenAnswer((_) async {});

      final result = await repository.getUserById(userId: userId);

      expect(result, users.first);
      verify(() => localDataSource.saveUser(users.first)).called(1);
    });
  });
}
