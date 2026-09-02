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
flutter test                                                            # all
flutter test test/features/user/presentation/notifier/user_notifier_test.dart  # single file
flutter test --plain-name "maps response models to entities"            # by name
flutter test --coverage                                                 # writes coverage/lcov.info
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
./create_feature.sh feature_name   # generates a lib/features/<name>/{domain,data,presentation} slice following the conventions below
```

## Architecture

Clean Architecture, but organized **feature-first, layers-inside** rather than layer-first: each feature under `lib/features/` owns its own `domain/` → `data/` → `presentation/` slice, and the strict inward dependency rule (`presentation` → `domain` ← `data`) applies *within* that slice. Cross-feature/shared code lives outside `features/`:

- **`lib/features/<name>/`** — one directory per feature (`auth`, `user`, `dashboard`, `settings`, `splash`, `architecture`, `widget_screen`). Not every feature needs every layer — `dashboard`/`settings`/`splash`/`architecture`/`widget_screen` are presentation-only shells with no domain/data of their own.
  - **`domain/`** — business core, no Flutter/data dependencies. `entity/` (freezed models — see the `shared/base/` note below), `repository/` (abstract interfaces), `use_cases/` (one operation each, mixing in `BaseUseCase<Output>` or `BaseUseCaseWithParams<Output, Params>` from `core/use_case/`), `exceptions/` (feature-specific exceptions).
  - **`data/`** — implements this feature's `domain/repository` interfaces. `repository_impl/`; `data_source/` (`remote/` Retrofit `@RestApi`, `mock/`, `local/`) talking to APIs/mocks/cache; `models/` request/response DTOs (see the `shared/base/` note below); `remapper/` extensions mapping DTOs ↔ domain entities.
  - **`presentation/`** — UI for this feature via Riverpod. A `notifier/` folder holds a `@riverpod` `Notifier` class emitting a freezed state wrapping a `BaseStatus`; `components/` holds feature-local widgets. The `user` feature's UI lives here as `home_screen.dart` etc. (home is the presentation of the user feature, not a separate feature).
- **`lib/shared/`** — presentation infra used by *more than one* feature, with no business logic of its own: `app/` (root `App` widget), `route/` (auto_route config + generated router), `theme/`, `widgets/` (reusable, feature-agnostic components), `locale/`.
  - **`base/`** — each feature's `domain/entity/*.dart` file, data `models/*.dart` file, and `data/data_source/remote/*_remote_data_source.dart` file is `part of` one of `shared/base/base_entity.dart` / `base_response.dart` / `base_request.dart` / `base_data_source.dart` rather than a standalone freezed/Retrofit library. This means freezed/json_serializable/retrofit_generator emit one `base_entity.freezed.dart` / `base_response.{freezed,g}.dart` / `base_request.{freezed,g}.dart` / `base_data_source.g.dart` in `shared/base/`, instead of a generated-file pair scattered into every feature. A feature's entity/model/remote-data-source file itself still lives under that feature's own `domain/entity/`, `data/models/`, or `data/data_source/remote/` — only the generated output is centralized. Importing `LoginEntity`/`UserEntity`/`AuthRemoteDataSource`/`UserRemoteDataSource` etc. anywhere means importing the relevant `shared/base/base_*.dart` file, not the feature file directly (Dart resolves `part of` symbols through the library file). `create_feature.sh` wires new entities/models/remote data sources into these aggregators automatically.
- **`lib/core/`** — cross-cutting, non-UI: `injector/` (DI), `env/` (flavors), `state_status/` (`BaseStatus`), `error/` (`ResponseError`), `interceptor/` (Dio interceptors), `data/factory/` (the cross-feature `DataSourceFactory` — see below), `use_case/` (`BaseUseCase` contracts), `helper/`, `extensions/`, `constants/`, `notifier/device_status/`.

A feature's `domain`/`data`/`presentation` never import another feature's `domain`/`data`/`presentation` directly. The only code allowed to know about multiple features at once is the composition root (`core/injector/injected_providers.dart`) and genuinely cross-feature infrastructure explicitly placed in `core/` (e.g. `DataSourceFactory`, which spans `auth` and `user` data sources by design — see below).

### Dependency injection (riverpod_generator)
- The whole app's dependency graph — across every feature — is plain `@Riverpod(keepAlive: true)` provider functions in [lib/core/injector/injected_providers.dart](lib/core/injector/injected_providers.dart) — one file, one provider per dependency, wired with `ref.watch`. There is no separate DI container or generated registration file; classes carry no DI annotations at all. This file is the one place in the app that is allowed to import across feature boundaries.
- `keepAlive: true` makes a provider behave like a singleton (built once, reused for the app's lifetime) — the equivalent of get_it's old `@singleton`/`@lazySingleton`.
- Flavor-conditional wiring (mock vs. remote data sources, cache-only vs. subscription-gated repository) is a plain `if (Env.shared.name == AppEnvironment.development)` branch inside the relevant provider — there's no annotation-based environment gating.
- `SharedPreferences` is the one async dependency: it's resolved once in `Env.bootstrap` ([lib/core/env/env.dart](lib/core/env/env.dart)) and injected via `ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(...)])`, so every other provider can stay synchronous.
- **After adding/removing/changing a provider, re-run build_runner** to regenerate `injected_providers.g.dart`, or the change won't take effect.
- Notifiers and widgets never construct dependencies themselves — they `ref.watch`/`ref.read` the provider from `injected_providers.dart`, which is also the seam tests override (see "Testing conventions" below).

### Flavor-based data mocking (key pattern)
Data sources are obtained through an **Abstract Factory**, not injected directly, so flavor selects real vs. mocked data at DI time. This factory is deliberately cross-feature infrastructure, so it lives in `core/`, not inside `features/auth` or `features/user`:
- `DataSourceFactory` interface ([lib/core/data/factory/data_source_factory.dart](lib/core/data/factory/data_source_factory.dart)) → `createUserDataSource()`, `createAuthDataSource()`.
- `dataSourceFactoryProvider` in [lib/core/injector/injected_providers.dart](lib/core/injector/injected_providers.dart) returns a `MockDataSourceFactory` when `Env.shared.name == AppEnvironment.development` and a `RemoteDataSourceFactory` otherwise.
- Repository impls take `DataSourceFactory` in their constructor and call `factory.createXDataSource()` — they never know whether data is mocked.
- Each data source has an abstract interface (`features/user/data/data_source/user_data_source.dart`) plus `remote/` (Retrofit `@RestApi`) and `mock/` implementations, inside that feature's own `data/data_source/`.
- **Consequence:** the `development` flavor runs fully offline against mock data. Adding a data source means: interface + `remote/` + `mock/` impls inside the feature's `data/data_source/`, then add a provider for each in `injected_providers.dart` and wire both into `dataSourceFactoryProvider`.

Environment names live in one place: `AppEnvironment` ([lib/core/env/app_environment.dart](lib/core/env/app_environment.dart)) — read directly (`Env.shared.name == AppEnvironment.x`) by providers that branch per flavor, and set by config classes. Each flavor has a `main_<flavor>.dart` entry that instantiates its `Env` subclass ([lib/core/env/](lib/core/env/)), which sets `Env.shared` and bootstraps the app (resolve `SharedPreferences`, wrap in `ProviderScope` with an `AppProviderObserver`, `runApp`).

### State handling
Notifier states are freezed classes holding a `BaseStatus` (`loading` / `success` / `failure(ResponseError)`). Notifiers catch exceptions from use cases and emit `BaseStatus.failure(ResponseError.from(e))`. Backend errors flow through `BackendErrorInterceptor` → `ResponseError`.

## Testing conventions
`test/` mirrors the `lib/` feature-first structure (`test/features/<name>/{domain,data,presentation}/...`, plus `test/core/` and `test/shared/` for cross-cutting code); each layer is tested in isolation by mocking the layer directly beneath it (`mocktail`). No real network/storage/DI is touched. When using `any()` with a custom type, `registerFallbackValue(...)` once in `setUpAll`. See README §7 for full patterns.

## Git conventions (enforced by hooks after `./setup.sh`)
- **Branches:** `feat/`, `fix/`, `refactor/`, or `chore/` prefix (except `main`/`develop`/`master`).
- **Commits:** Conventional Commits — `type: description` (≥3 chars). Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `style`, `test`, `perf`, `ci`, `build`, `revert`, `wip`.
- CI (`.github/workflows/main.yaml`) runs on `main`: semantic-PR check, `very_good` Flutter build/test, and spell-check.
