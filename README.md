# Flutter Clean Architecture Template (with Riverpod)

## Application Flow

`UserRepository` is resolved by DI (`riverpod_generator`, see `core/injector/injected_providers.dart`) into a different chain per flavor — the notifier and use case never know which chain they got. Development skips the subscription check entirely; staging/production gate every call behind it. Both chains funnel through the same cache-first repository, and the cache is filled from either mock data (development) or the real API (staging/production).

<img src="https://raw.githubusercontent.com/hadiuzzaman524/flutter-clean-architecture/develop/assets/images/Feature%20Access%20by%20Flavor-selection.png" alt="Feature Access by Flavor" width="800" />

## What is Clean Architecture?

[Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html), conceptualized by Robert C. Martin, offers a structured approach to organizing applications by breaking them down into modules, each serving a distinct purpose. Its core principle revolves around dividing an application into three primary layers:

- **Presentation Layer:** This layer's primary role is to present data to users and manage their input. It should remain devoid of any business logic and maintain simplicity as a fundamental principle.
- **Domain Layer:** The hub of business logic within the application. It defines use cases and embodies the essence of the application's functionality. Importantly, it operates independently of other layers, facilitating isolated testing.
- **Data Layer:** Responsible for data operations, this layer handles data retrieval and storage. It remains detached from the domain layer, focusing solely on data access and persistence concerns.

Clean Architecture's central tenet is preserving these well-defined layers to enhance application maintainability, scalability, and testability, while also enabling smoother code evolution.

<p float="left">
  <img src="https://github.com/hadiuzzaman524/flutter-clean-architecture/assets/52348628/6b19d471-5ec9-4ae3-b285-ae57c7af9de8" width="600">
</p>

The concentric circles within the image represent the different areas within the software. The closer to the center, the higher level the software becomes. The sole principle behind Clean Architecture is the **Dependency Rule**: code dependencies can only point inwards.

## Benefits of implementing Clean Architecture

- **Modularity and Maintainability:** Encourages separation of concerns, making the codebase more modular and easier to maintain.
- **Testability:** Separation of the domain layer allows for comprehensive unit testing of business logic.
- **Flexibility and Scalability:** Easier to adapt and scale. Components within a layer can be replaced or upgraded without affecting the entire system.
- **Code Reusability:** Promotes reuse of components, especially in the domain layer.
- **Reduced Dependency Hell:** Discourages high-level layers from having direct dependencies on lower-level layers.

---

## Clean Architecture implementation using Flutter

While Clean Architecture is a broad approach, this project follows a customized structure optimized for Flutter:

<p float="center">
  <img src="https://github.com/hadiuzzaman524/flutter-clean-architecture/assets/52348628/f62ab872-e1e5-4e88-9438-cf055274f6e3" width="600">
</p>

### 1. Domain Layer
The heart of the application, encapsulating business rules and use cases.

**Entity**
Fundamental concepts within the domain.
```dart
@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String name,
    required String email,
    required String address,
    required String city,
    required double latitude,
    required double longitude,
  }) = _UserEntity;
}
```

**UseCase**
Application-specific operations.
```dart
class GetUserListUseCase with BaseUseCase<List<UserEntity>> {
  GetUserListUseCase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<List<UserEntity>> execute() => _userRepository.getUserList();
}
```
Wired into the graph as a plain `@Riverpod(keepAlive: true)` provider in `core/injector/injected_providers.dart` — the class itself carries no DI annotation.

**Repository Interface**
Abstractions that define the contract for data access.
```dart
abstract class UserRepository {
  Future<List<UserEntity>> getUserList();
  Future<UserEntity> getUserById({required String userId});
}
```

### 2. Data Layer
Manages data-related operations, including storage and communication with external sources.

**Data Source**
Origins of data (e.g., APIs via Retrofit), implementing this feature's data source interface. The `@RestApi` class itself is `part of` the shared `shared/base/base_data_source.dart` aggregator rather than a standalone library — see the Architecture note in `CLAUDE.md`.
```dart
@RestApi()
abstract class UserRemoteDataSource implements UserDataSource {
  factory UserRemoteDataSource(Dio dio) = _UserRemoteDataSource;

  @override
  @GET('/users')
  Future<List<UserResponseModel>> getUserList();
}
```

**Repository Implementation**
Implements the domain repository interface and handles data mapping. Data sources are obtained through the `DataSourceFactory` abstract factory rather than injected directly, so the repository never knows whether it's talking to a mock or the real backend (see [§4 Dependency Injection](#4-dependency-injection-riverpod_generator)):
```dart
class UserRepositoryImpl extends UserRepository {
  UserRepositoryImpl(DataSourceFactory factory)
    : _userDataSource = factory.createUserDataSource();

  final UserDataSource _userDataSource;

  @override
  Future<List<UserEntity>> getUserList() async {
    final response = await _userDataSource.getUserList();
    return response.toUserEntities();
  }
}
```

**Response Objects & Mapper**
Data structures for API responses and extensions to map them to domain entities.
```dart
extension UserResponseMapper on List<UserResponseModel> {
  List<UserEntity> toUserEntities() {
    return map((userResponse) => userResponse.toUserEntity()).toList();
  }
}

extension UserResponseItemMapper on UserResponseModel {
  UserEntity toUserEntity() {
    return UserEntity(
      name: name ?? '',
      email: email ?? '',
      address: address?.street ?? '',
      city: address?.city ?? '',
      latitude: double.parse(address?.geo?.lat ?? '0'),
      longitude: double.parse(address?.geo?.lng ?? '0'),
    );
  }
}
```

### 3. Presentation Layer
Responsible for UI rendering and handling user interactions using Riverpod (`@riverpod` notifiers, generated with `riverpod_generator`).

**Communication (Notifier)**
```dart
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  UserState build() => const UserState();

  Future<void> getUserList() async {
    state = state.copyWith(status: const BaseStatus.loading());
    try {
      final userList = await ref.read(getUserListUseCaseProvider).execute();
      state = state.copyWith(userList: userList, status: const BaseStatus.success());
    } catch (e) {
      state = state.copyWith(status: BaseStatus.failure(ResponseError.from(e)));
    }
  }
}
```
The widget watches it with `ref.watch(userProvider)` / triggers actions with `ref.read(userProvider.notifier).getUserList()`. `getUserListUseCaseProvider` comes from `core/injector/injected_providers.dart` (see the Dependency Injection section below) — swapping it for a mock is how tests isolate the notifier.

## 4. Dependency Injection (riverpod_generator)
There's no separate DI container — the whole dependency graph lives as plain `@Riverpod(keepAlive: true)` provider functions in [`lib/core/injector/injected_providers.dart`](lib/core/injector/injected_providers.dart), each one calling `ref.watch` on whatever it needs:

```dart
@Riverpod(keepAlive: true)
UserRepository userRemoteRepository(Ref ref) =>
    UserRepositoryImpl(ref.watch(dataSourceFactoryProvider));

@Riverpod(keepAlive: true)
GetUserListUseCase getUserListUseCase(Ref ref) =>
    GetUserListUseCase(ref.watch(userRepositoryProvider));
```

`keepAlive: true` makes a provider act like a singleton — built once, reused for the app's lifetime. Classes themselves (use cases, repositories, data sources) carry no DI annotation; they're plain constructors, and `injected_providers.dart` is the only place that wires them together. Flavor-specific wiring (mock vs. remote data sources, subscription gating) is a plain `if (Env.shared.name == AppEnvironment.development)` branch inside the relevant provider — see the Abstract Factory pattern below.

The one async dependency, `SharedPreferences`, is resolved once during `Env.bootstrap` and handed in via `ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(...)])`, so every other provider can stay synchronous.

Because every dependency is a provider, tests override exactly the one they care about with a mock (see [§7 Testing](#7-testing)) instead of standing up a real container.

---

## 5. How to run this project? 

This project contains 3 flavors:
- development
- staging
- production

To run the desired flavor:
```bash
# Development
$ flutter run --flavor development --target lib/main_development.dart

# Staging
$ flutter run --flavor staging --target lib/main_staging.dart

# Production
$ flutter run --flavor production --target lib/main_production.dart
```

---

## 6. Initial Setup

To get started with the project, run the following commands:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Then, run the setup script to configure the environment:

```bash
# Make the script executable
chmod +x ./setup.sh

# Run the setup
./setup.sh
```

---

## 7. Testing

Unit tests live under `test/`, mirroring the `lib/` feature-first structure so
each layer is verified in isolation by mocking the layer beneath it — exactly
what the Clean Architecture boundaries are designed to enable.

```
test/
├── core/                          # cross-cutting: error mapping, device status, ...
├── shared/                        # cross-cutting notifiers (theme, locale)
└── features/
    ├── auth/
    │   ├── data/repository_impl/      # repositories (mocked DataSourceFactory + data sources)
    │   ├── domain/use_cases/          # use cases (mocked repositories)
    │   └── presentation/notifier/     # notifiers (mocked use case providers)
    ├── user/
    │   ├── data/repository_impl/
    │   ├── domain/use_cases/
    │   └── presentation/notifier/
    └── dashboard/
        └── presentation/notifier/
```

The suite uses [`flutter_test`](https://docs.flutter.dev/testing) +
[`mocktail`](https://pub.dev/packages/mocktail). No real network, storage, or DI
graph is touched — every collaborator is mocked.

### Run the tests

```bash
# All tests
flutter test

# A single file
flutter test test/features/user/presentation/notifier/user_notifier_test.dart

# By name
flutter test --plain-name "maps response models to domain entities"

# With coverage (writes coverage/lcov.info)
flutter test --coverage
```

To turn coverage into a browsable HTML report (requires `lcov`):

```bash
genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
```

### How to write a test

**1. Mock the dependency below the unit under test:**

```dart
class MockUserRepository extends Mock implements UserRepository {}
```

**2. Use case / repository — stub and verify delegation & mapping:**

```dart
test('getUserList maps response models to domain entities', () async {
  when(() => dataSource.getUserList()).thenAnswer((_) async => response);

  final result = await repository.getUserList();

  expect(result.first.name, 'John');
  verify(() => factory.createUserDataSource()).called(1);
});
```

**3. Notifier — override its provider dependencies, then assert the emitted state sequence:**

```dart
test('emits loading then success', () async {
  when(() => useCase.execute()).thenAnswer((_) async => users);

  final container = ProviderContainer(
    overrides: [
      getUserListUseCaseProvider.overrideWithValue(useCase),
      loggerProvider.overrideWithValue(logger),
    ],
  );
  addTearDown(container.dispose);

  final states = <UserState>[];
  container.listen(userProvider, (_, next) => states.add(next));

  await container.read(userProvider.notifier).getUserList();

  expect(states[0].status.isLoading, isTrue);
  expect(states[1].status.isSuccess, isTrue);
});
```
No real DI graph is built — overriding `getUserListUseCaseProvider` (from `core/injector/injected_providers.dart`) on a fresh `ProviderContainer` is enough to isolate the notifier.

> When using argument matchers like `any()` with a custom type, register a
> fallback once in `setUpAll`:
> ```dart
> registerFallbackValue(const LoginEntity(email: '', pin: ''));
> ```

> **Tip:** run the mock flavor (`development`) to exercise flows end-to-end
> without a backend — the `DataSourceFactory` swaps in mock data sources.

---

## 8. Git Branch & Commit Conventions

### Branch Naming

All branches must follow the format:

```
feat/<feature-name>
fix/<bug-name>
refactor/<refactor-name>
chore/<task-name>
```

### Commit Messages

All commits should follow the Conventional Commit format:

```
type: Short description (at least 3 characters)
```

Allowed types: `feat`, `fix`, `refactor`, `chore`, `docs`, `style`, `test`, `perf`, `ci`, `build`,
`wip`,
`revert`

Example:

```
feat: add localization support
fix: correct padding on lunch card
```

---

## 9. Localization (L10n)

To add new text for localization, run the provided script:

```bash
./l10n_generator.sh
```

* Specify the type as `text` when prompted.
* Access localized text in your code using:

```dart
context.l10n.text
```

---

## 10. Create a New Feature (Clean Architecture)

```bash
./create_feature.sh feature_name
```

This command automatically generates all required files for a new feature, following Clean
Architecture principles, including the **domain**, **data**, and **presentation** layers.

---
