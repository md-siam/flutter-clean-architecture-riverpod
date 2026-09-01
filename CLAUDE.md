# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A Flutter Clean Architecture template (created via Very Good CLI). Requires Dart SDK `^3.11.0`.

## Commands

### Running (three flavors)
```bash
flutter run --flavor development --target lib/main_development.dart  # mocked data, no backend
flutter run --flavor staging     --target lib/main_staging.dart
flutter run --flavor production   --target lib/main_production.dart
```

### First-time setup
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
./setup.sh   # installs git hooks (commit-msg + branch-name enforcement) and makes scripts executable
```

### Code generation (run after touching freezed/riverpod/retrofit/json/asset code)
```bash
dart run build_runner build --delete-conflicting-outputs   # one-off
dart run build_runner watch --delete-conflicting-outputs   # continuous
```
Generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `assets.gen.dart`) are checked in and excluded from analysis. Do not hand-edit them.

### Testing
```bash
flutter test                                                  # all
flutter test test/presentation/user_notifier_test.dart        # single file
flutter test --plain-name "maps response models to entities"  # by name
flutter test --coverage                                       # writes coverage/lcov.info
```

### Lint
```bash
flutter analyze   # uses very_good_analysis via flutter_lints (see analysis_options.yaml)
```

### Localization
```bash
./l10n_generator.sh   # add ARB keys interactively (choose type "text"); access via context.l10n.<key>
```
ARB source: `lib/l10n/arb/app_en.arb` (template) + `app_es.arb`. Generated into `lib/l10n/gen/`.

### Scaffold a new feature
```bash
./create_feature.sh feature_name   # generates domain/data/presentation files following the layer conventions below
```

## Architecture

Clean Architecture with a strict inward dependency rule. Four top-level directories under `lib/`:

- **`domain/`** — business core, no Flutter/data dependencies. `entity/` (freezed models), `repository/` (abstract interfaces), `use_cases/` (one operation each, mixing in `BaseUseCase<Output>` or `BaseUseCaseWithParams<Output, Params>`).
- **`data/`** — implements domain contracts. `repository_impl/` implement `domain/repository` interfaces; `data_source/` talk to APIs (Retrofit) or mocks; `models/` are request/response DTOs; `remapper/` are extensions mapping DTOs ↔ domain entities.
- **`presentation/`** — UI via Riverpod. `app/`, `route/` (auto_route), `theme/`, `widgets/` (reusable), plus feature screens. Each feature has a `notifier/` folder: a `@riverpod` `Notifier` class emitting a freezed state wrapping a `BaseStatus`.
- **`core/`** — cross-cutting: `injector/` (DI), `env/` (flavors), `state_status/` (`BaseStatus`), `error/` (`ResponseError`), `helper/`, `extensions/`, `constants/`.

### Dependency injection (riverpod_generator)
- The whole app's dependency graph is plain `@Riverpod(keepAlive: true)` provider functions in [lib/core/injector/injected_providers.dart](lib/core/injector/injected_providers.dart) — one file, one provider per dependency, wired with `ref.watch`. There is no separate DI container or generated registration file; classes carry no DI annotations at all.
- `keepAlive: true` makes a provider behave like a singleton (built once, reused for the app's lifetime) — the equivalent of get_it's old `@singleton`/`@lazySingleton`.
- Flavor-conditional wiring (mock vs. remote data sources, cache-only vs. subscription-gated repository) is a plain `if (Env.shared.name == AppEnvironment.development)` branch inside the relevant provider — there's no annotation-based environment gating.
- `SharedPreferences` is the one async dependency: it's resolved once in `Env.bootstrap` ([lib/core/env/env.dart](lib/core/env/env.dart)) and injected via `ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(...)])`, so every other provider can stay synchronous.
- **After adding/removing/changing a provider, re-run build_runner** to regenerate `injected_providers.g.dart`, or the change won't take effect.
- Notifiers and widgets never construct dependencies themselves — they `ref.watch`/`ref.read` the provider from `injected_providers.dart`, which is also the seam tests override (see "Testing conventions" below).

### Flavor-based data mocking (key pattern)
Data sources are obtained through an **Abstract Factory**, not injected directly, so flavor selects real vs. mocked data at DI time:
- `DataSourceFactory` interface → `createUserDataSource()`, `createAuthDataSource()`.
- `dataSourceFactoryProvider` in [lib/core/injector/injected_providers.dart](lib/core/injector/injected_providers.dart) returns a `MockDataSourceFactory` when `Env.shared.name == AppEnvironment.development` and a `RemoteDataSourceFactory` otherwise.
- Repository impls take `DataSourceFactory` in their constructor and call `factory.createXDataSource()` — they never know whether data is mocked.
- Each data source has an abstract interface (`user/user_data_source.dart`) plus `remote/` (Retrofit `@RestApi`) and `mock/` implementations.
- **Consequence:** the `development` flavor runs fully offline against mock data. Adding a data source means: interface + `remote/` + `mock/` impls, then add a provider for each in `injected_providers.dart` and wire both into `dataSourceFactoryProvider`.

Environment names live in one place: `AppEnvironment` ([lib/core/env/app_environment.dart](lib/core/env/app_environment.dart)) — read directly (`Env.shared.name == AppEnvironment.x`) by providers that branch per flavor, and set by config classes. Each flavor has a `main_<flavor>.dart` entry that instantiates its `Env` subclass ([lib/core/env/](lib/core/env/)), which sets `Env.shared` and bootstraps the app (resolve `SharedPreferences`, wrap in `ProviderScope` with an `AppProviderObserver`, `runApp`).

### State handling
Notifier states are freezed classes holding a `BaseStatus` (`loading` / `success` / `failure(ResponseError)`). Notifiers catch exceptions from use cases and emit `BaseStatus.failure(ResponseError.from(e))`. Backend errors flow through `BackendErrorInterceptor` → `ResponseError`.

## Testing conventions
`test/` mirrors `lib/` layer structure; each layer is tested in isolation by mocking the layer directly beneath it (`mocktail`). No real network/storage/DI is touched. When using `any()` with a custom type, `registerFallbackValue(...)` once in `setUpAll`. See README §7 for full patterns.

## Git conventions (enforced by hooks after `./setup.sh`)
- **Branches:** `feat/`, `fix/`, `refactor/`, or `chore/` prefix (except `main`/`develop`/`master`).
- **Commits:** Conventional Commits — `type: description` (≥3 chars). Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `style`, `test`, `perf`, `ci`, `build`, `revert`, `wip`.
- CI (`.github/workflows/main.yaml`) runs on `main`: semantic-PR check, `very_good` Flutter build/test, and spell-check.
