import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_template/features/user/data/data_source/local/subscription_local_data_source.dart';
import 'package:flutter_template/features/user/data/repository_impl/subscription_repository_impl.dart';

class MockSubscriptionLocalDataSource extends Mock
    implements SubscriptionLocalDataSource {}

void main() {
  late MockSubscriptionLocalDataSource dataSource;
  late SubscriptionRepositoryImpl repository;

  setUp(() {
    dataSource = MockSubscriptionLocalDataSource();
    repository = SubscriptionRepositoryImpl(dataSource);
  });

  test('isSubscribed delegates to the local data source', () {
    when(() => dataSource.isSubscribed()).thenReturn(true);

    expect(repository.isSubscribed(), isTrue);
    verify(() => dataSource.isSubscribed()).called(1);
  });

  test('setSubscriptionStatus delegates to the local data source', () async {
    when(
      () => dataSource.setSubscriptionStatus(any()),
    ).thenAnswer((_) async {});

    await repository.setSubscriptionStatus(true);

    verify(() => dataSource.setSubscriptionStatus(true)).called(1);
  });
}
