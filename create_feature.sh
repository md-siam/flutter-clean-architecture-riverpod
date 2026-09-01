#!/bin/bash
set -e

FEATURE_NAME=$1

if [ -z "$FEATURE_NAME" ]; then
  echo "❌ Usage: ./create_feature.sh <feature_name>"
  echo "Example: ./create_feature.sh test_feature"
  exit 1
fi

# Convert feature name to snake case (all lowercase, underscores)
FEATURE_SNAKE=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]')
# PascalCase, e.g. "test_feature" -> "TestFeature". Built with plain bash
# string ops rather than sed's `\U` — that's a GNU extension BSD sed
# (macOS) doesn't support, so it produced literal "U"s instead of casing.
ENTITY_CAMEL=""
IFS='_' read -ra _feature_parts <<< "$FEATURE_SNAKE"
for _part in "${_feature_parts[@]}"; do
  ENTITY_CAMEL+="$(tr '[:lower:]' '[:upper:]' <<< "${_part:0:1}")${_part:1}"
done
# lowerCamelCase, e.g. "test_feature" -> "testFeature" — riverpod_generator
# names a `@riverpod class ${ENTITY_CAMEL}Notifier` provider by stripping the
# trailing "Notifier" and lowercasing the first letter, so this is the name
# widgets actually `ref.watch`/`ref.read` (see every *_notifier.g.dart).
FEATURE_CAMEL="$(printf '%s' "${ENTITY_CAMEL:0:1}" | tr '[:upper:]' '[:lower:]')${ENTITY_CAMEL:1}"

# Insert $2 (a line) immediately before the first line of file $3 that
# matches ERE $1. Uses awk instead of `sed ... i ...` because the `i`
# (insert) command's syntax differs between GNU sed (Linux) and BSD sed
# (macOS) — awk's behavior here is identical on both.
insert_before() {
  local pattern="$1" line="$2" file="$3"
  awk -v pat="$pattern" -v line="$line" '
    !done && $0 ~ pat { print line; done = 1 }
    { print }
  ' "$file" > "$file.tmp.$$" && mv "$file.tmp.$$" "$file"
}


# ---------------------------
# Paths
# ---------------------------
DOMAIN_ENTITY_DIR="lib/domain/entity/$FEATURE_SNAKE"
DOMAIN_REPO_DIR="lib/domain/repository/$FEATURE_SNAKE"
DOMAIN_USECASE_DIR="lib/domain/use_cases/$FEATURE_SNAKE"

DATA_MODEL_DIR="lib/data/models/response_model/$FEATURE_SNAKE"
DATA_REPO_IMPL_DIR="lib/data/repository_impl/$FEATURE_SNAKE"
DATA_REMAPPER_DIR="lib/data/remapper/$FEATURE_SNAKE"
DATA_DS_DIR="lib/data/data_source/$FEATURE_SNAKE"

PRESENTATION_DIR="lib/presentation/screen/$FEATURE_SNAKE"
NOTIFIER_DIR="$PRESENTATION_DIR/notifier"
COMPONENTS_DIR="$PRESENTATION_DIR/components"

# ---------------------------
# Files
# ---------------------------
DOMAIN_ENTITY_FILE="$DOMAIN_ENTITY_DIR/${FEATURE_SNAKE}_entity.dart"
DOMAIN_REPO_FILE="$DOMAIN_REPO_DIR/${FEATURE_SNAKE}_repository.dart"
DOMAIN_USECASE_FILE="$DOMAIN_USECASE_DIR/get_${FEATURE_SNAKE}_usecase.dart"

DATA_MODEL_FILE="$DATA_MODEL_DIR/${FEATURE_SNAKE}_model.dart"
DATA_REPO_IMPL_FILE="$DATA_REPO_IMPL_DIR/${FEATURE_SNAKE}_repository_impl.dart"
DATA_REMAPPER_FILE="$DATA_REMAPPER_DIR/${FEATURE_SNAKE}_remapper.dart"
DATA_REMOTE_DS_FILE="$DATA_DS_DIR/${FEATURE_SNAKE}_remote_data_source.dart"
DATA_LOCAL_DS_FILE="$DATA_DS_DIR/${FEATURE_SNAKE}_local_data_source.dart"

NOTIFIER_FILE="$NOTIFIER_DIR/${FEATURE_SNAKE}_notifier.dart"
STATE_FILE="$NOTIFIER_DIR/${FEATURE_SNAKE}_state.dart"

SCREEN_FILE="$PRESENTATION_DIR/${FEATURE_SNAKE}_screen.dart"
PORTRAIT_VIEW_FILE="$PRESENTATION_DIR/${FEATURE_SNAKE}_portrait_view.dart"
LANDSCAPE_VIEW_FILE="$PRESENTATION_DIR/${FEATURE_SNAKE}_landscape_view.dart"
LIST_VIEW_FILE="$COMPONENTS_DIR/${FEATURE_SNAKE}_list_view.dart"

# ---------------------------
# Create directories
# ---------------------------
mkdir -p "$DOMAIN_ENTITY_DIR" "$DOMAIN_REPO_DIR" "$DOMAIN_USECASE_DIR"
mkdir -p "$DATA_MODEL_DIR" "$DATA_REPO_IMPL_DIR" "$DATA_REMAPPER_DIR" "$DATA_DS_DIR"
mkdir -p "$NOTIFIER_DIR"
mkdir -p "$PRESENTATION_DIR" "$COMPONENTS_DIR"

# ---------------------------
# Domain Entity
# ---------------------------
cat <<EOF > "$DOMAIN_ENTITY_FILE"
part of '../base/base_entity.dart';

@freezed
abstract class ${ENTITY_CAMEL}Entity with _\$${ENTITY_CAMEL}Entity {
  const factory ${ENTITY_CAMEL}Entity({
    required String id,
    required String title,
  }) = _${ENTITY_CAMEL}Entity;
}
EOF

# ---------------------------
# Add entity part to base_entity.dart
# ---------------------------
BASE_ENTITY_FILE="lib/domain/entity/base/base_entity.dart"
ENTITY_PART_LINE="part '../$FEATURE_SNAKE/${FEATURE_SNAKE}_entity.dart';"
if ! grep -Fxq "$ENTITY_PART_LINE" "$BASE_ENTITY_FILE"; then
  insert_before "part '.*\\.freezed\\.dart';" "$ENTITY_PART_LINE" "$BASE_ENTITY_FILE"
  echo "Added $ENTITY_PART_LINE to base_entity.dart"
fi

# ---------------------------
# Domain Repository
# ---------------------------
cat <<EOF > "$DOMAIN_REPO_FILE"
import '../../entity/base/base_entity.dart';

abstract class ${ENTITY_CAMEL}Repository {
  Future<List<${ENTITY_CAMEL}Entity>> getAll();
  Future<${ENTITY_CAMEL}Entity> getById({required String id});
}
EOF

# ---------------------------
# Domain UseCase
# ---------------------------
cat <<EOF > "$DOMAIN_USECASE_FILE"
import '../../entity/base/base_entity.dart';
import '../../repository/$FEATURE_SNAKE/${FEATURE_SNAKE}_repository.dart';

class Get${ENTITY_CAMEL}UseCase {
  final ${ENTITY_CAMEL}Repository repository;

  Get${ENTITY_CAMEL}UseCase(this.repository);

  Future<List<${ENTITY_CAMEL}Entity>> call() async {
    return await repository.getAll();
  }
}
EOF

# ---------------------------
# Data Model (Freezed)
# ---------------------------
cat <<EOF > "$DATA_MODEL_FILE"
part of '../base/base_response.dart';

@freezed
abstract class ${ENTITY_CAMEL}ResponseModel with _\$${ENTITY_CAMEL}ResponseModel {
  const factory ${ENTITY_CAMEL}ResponseModel({
    required String id,
    required String title,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _${ENTITY_CAMEL}ResponseModel;

  factory ${ENTITY_CAMEL}ResponseModel.fromJson(Map<String, dynamic> json) =>
      _\$${ENTITY_CAMEL}ResponseModelFromJson(json);
}
EOF

# ---------------------------
# Add model part to base_response.dart
# ---------------------------
BASE_RESPONSE_FILE="lib/data/models/response_model/base/base_response.dart"
MODEL_PART_LINE="part '../$FEATURE_SNAKE/${FEATURE_SNAKE}_model.dart';"
if ! grep -Fxq "$MODEL_PART_LINE" "$BASE_RESPONSE_FILE"; then
  insert_before "part '.*\\.freezed\\.dart';" "$MODEL_PART_LINE" "$BASE_RESPONSE_FILE"
  echo "Added $MODEL_PART_LINE to base_response.dart"
fi

# ---------------------------
# Repository Implementation
# ---------------------------
cat <<EOF > "$DATA_REPO_IMPL_FILE"
import '../../../domain/entity/base/base_entity.dart';
import '../../../domain/repository/$FEATURE_SNAKE/${FEATURE_SNAKE}_repository.dart';
import '../../data_source/$FEATURE_SNAKE/${FEATURE_SNAKE}_local_data_source.dart';
import '../../data_source/$FEATURE_SNAKE/${FEATURE_SNAKE}_remote_data_source.dart';
import '../../remapper/$FEATURE_SNAKE/${FEATURE_SNAKE}_remapper.dart';

class ${ENTITY_CAMEL}RepositoryImpl implements ${ENTITY_CAMEL}Repository {
  final ${ENTITY_CAMEL}RemoteDataSource remoteDataSource;
  final ${ENTITY_CAMEL}LocalDataSource localDataSource;

  ${ENTITY_CAMEL}RepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<List<${ENTITY_CAMEL}Entity>> getAll() async {
    // Use local data for now
    final localData = await localDataSource.fetchCachedData();
    return localData.map((m) => m.toEntity()).toList();
  }

  @override
  Future<${ENTITY_CAMEL}Entity> getById({required String id}) async {
    final localData = await localDataSource.fetchCachedData();
    return localData.firstWhere((e) => e.id == id).toEntity();
  }
}
EOF

# ---------------------------
# Remapper
# ---------------------------
cat <<EOF > "$DATA_REMAPPER_FILE"
import '../../../domain/entity/base/base_entity.dart';
import '../../models/response_model/base/base_response.dart';

extension ${ENTITY_CAMEL}Mapper on ${ENTITY_CAMEL}ResponseModel {
  ${ENTITY_CAMEL}Entity toEntity() => ${ENTITY_CAMEL}Entity(id: id, title: title);
}

extension ${ENTITY_CAMEL}ListMapper on List<${ENTITY_CAMEL}ResponseModel> {
  List<${ENTITY_CAMEL}Entity> toEntityList() => map((e) => e.toEntity()).toList();
}
EOF

# ---------------------------
# Remote Data Source
# ---------------------------
cat <<EOF > "$DATA_REMOTE_DS_FILE"
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/response_model/base/base_response.dart';
part '${FEATURE_SNAKE}_remote_data_source.g.dart';

@RestApi()
abstract class ${ENTITY_CAMEL}RemoteDataSource {
  factory ${ENTITY_CAMEL}RemoteDataSource(Dio dio) = _${ENTITY_CAMEL}RemoteDataSource;

  @GET("/path-of-your-end-point")
  Future<${ENTITY_CAMEL}ResponseModel> fetchData();
}
EOF

# ---------------------------
# Local Data Source
# ---------------------------
cat <<EOF > "$DATA_LOCAL_DS_FILE"
import '../../models/response_model/base/base_response.dart';

class ${ENTITY_CAMEL}LocalDataSource {
  Future<List<${ENTITY_CAMEL}ResponseModel>> fetchCachedData() async {
    // Dummy data for UI
    return [
      ${ENTITY_CAMEL}ResponseModel(id: '1', title: 'Item 1', createdAt: '2026-01-07'),
      ${ENTITY_CAMEL}ResponseModel(id: '2', title: 'Item 2', createdAt: '2026-01-07'),
    ];
  }
}
EOF

# ---------------------------
# Wire the new dependencies into the Riverpod DI graph
# (core/injector/injected_providers.dart) — imports go above the `part`
# directive, providers get appended after the "append here" marker.
# ---------------------------
INJECTED_PROVIDERS_FILE="lib/core/injector/injected_providers.dart"

for IMPORT_LINE in \
  "import 'package:flutter_template/data/data_source/$FEATURE_SNAKE/${FEATURE_SNAKE}_local_data_source.dart';" \
  "import 'package:flutter_template/data/data_source/$FEATURE_SNAKE/${FEATURE_SNAKE}_remote_data_source.dart';" \
  "import 'package:flutter_template/data/repository_impl/$FEATURE_SNAKE/${FEATURE_SNAKE}_repository_impl.dart';" \
  "import 'package:flutter_template/domain/repository/$FEATURE_SNAKE/${FEATURE_SNAKE}_repository.dart';" \
  "import 'package:flutter_template/domain/use_cases/$FEATURE_SNAKE/get_${FEATURE_SNAKE}_usecase.dart';"
do
  if ! grep -Fxq "$IMPORT_LINE" "$INJECTED_PROVIDERS_FILE"; then
    insert_before "^part 'injected_providers.g.dart';\$" "$IMPORT_LINE" "$INJECTED_PROVIDERS_FILE"
  fi
done

if ! grep -Fq "${FEATURE_CAMEL}Repository(Ref ref)" "$INJECTED_PROVIDERS_FILE"; then
  cat <<EOF >> "$INJECTED_PROVIDERS_FILE"

@Riverpod(keepAlive: true)
${ENTITY_CAMEL}RemoteDataSource ${FEATURE_CAMEL}RemoteDataSource(Ref ref) =>
    ${ENTITY_CAMEL}RemoteDataSource(ref.watch(unauthenticatedDioProvider));

@Riverpod(keepAlive: true)
${ENTITY_CAMEL}LocalDataSource ${FEATURE_CAMEL}LocalDataSource(Ref ref) =>
    ${ENTITY_CAMEL}LocalDataSource();

@Riverpod(keepAlive: true)
${ENTITY_CAMEL}Repository ${FEATURE_CAMEL}Repository(Ref ref) =>
    ${ENTITY_CAMEL}RepositoryImpl(
      ref.watch(${FEATURE_CAMEL}RemoteDataSourceProvider),
      ref.watch(${FEATURE_CAMEL}LocalDataSourceProvider),
    );

@Riverpod(keepAlive: true)
Get${ENTITY_CAMEL}UseCase get${ENTITY_CAMEL}UseCase(Ref ref) =>
    Get${ENTITY_CAMEL}UseCase(ref.watch(${FEATURE_CAMEL}RepositoryProvider));
EOF
  echo "Wired ${ENTITY_CAMEL} dependencies into injected_providers.dart"
fi

# ---------------------------
# Notifier (Riverpod)
# ---------------------------
cat <<EOF > "$NOTIFIER_FILE"
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/error/response_error.dart';
import '../../../../core/injector/injected_providers.dart';
import '../../../../core/state_status/base_status.dart';
import '${FEATURE_SNAKE}_state.dart';

part '${FEATURE_SNAKE}_notifier.g.dart';

@riverpod
class ${ENTITY_CAMEL}Notifier extends _\$${ENTITY_CAMEL}Notifier {
  @override
  ${ENTITY_CAMEL}State build() => const ${ENTITY_CAMEL}State();

  Future<void> fetchAll() async {
    state = state.copyWith(status: const BaseStatus.loading());
    try {
      final list = await ref.read(get${ENTITY_CAMEL}UseCaseProvider).call();
      state = state.copyWith(
        status: const BaseStatus.success(),
        featureEntities: list,
      );
    } catch (e) {
      ref.read(loggerProvider).e(e);
      state = state.copyWith(status: BaseStatus.failure(ResponseError.from(e)));
    }
  }
}
EOF

# ---------------------------
# State
# ---------------------------
cat <<EOF > "$STATE_FILE"
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/state_status/base_status.dart';
import '../../../../domain/entity/base/base_entity.dart';

part '${FEATURE_SNAKE}_state.freezed.dart';

@freezed
sealed class ${ENTITY_CAMEL}State with _\$${ENTITY_CAMEL}State {
  const factory ${ENTITY_CAMEL}State({
    @Default([]) List<${ENTITY_CAMEL}Entity> featureEntities,
    @Default(BaseStatus.initial()) BaseStatus status,
  }) = _${ENTITY_CAMEL}State;
}
EOF

# ---------------------------
# Screens
# ---------------------------
cat <<EOF > "$SCREEN_FILE"
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/widgets.dart';
import 'notifier/${FEATURE_SNAKE}_notifier.dart';
import '${FEATURE_SNAKE}_landscape_view.dart';
import '${FEATURE_SNAKE}_portrait_view.dart';

@RoutePage()
class ${ENTITY_CAMEL}Screen extends Screen {
  const ${ENTITY_CAMEL}Screen({super.key});

  @override
  Widget buildViewWrapper({required Widget child}) {
    return _${ENTITY_CAMEL}Loader(child: child);
  }

  @override
  Widget buildMobilePortraitView(BuildContext context) {
    return const ${ENTITY_CAMEL}PortraitView();
  }

  @override
  Widget buildMobileLandscapeView(BuildContext context) {
    return const ${ENTITY_CAMEL}LandScapeView();
  }
}

/// Triggers the initial fetch once, when the screen mounts.
class _${ENTITY_CAMEL}Loader extends ConsumerStatefulWidget {
  const _${ENTITY_CAMEL}Loader({required this.child});

  final Widget child;

  @override
  ConsumerState<_${ENTITY_CAMEL}Loader> createState() =>
      _${ENTITY_CAMEL}LoaderState();
}

class _${ENTITY_CAMEL}LoaderState extends ConsumerState<_${ENTITY_CAMEL}Loader> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(${FEATURE_CAMEL}Provider.notifier).fetchAll(),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
EOF


# Portrait View
cat <<EOF > "$PORTRAIT_VIEW_FILE"
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/text/app_text.dart';
import 'notifier/${FEATURE_SNAKE}_notifier.dart';
import 'components/${FEATURE_SNAKE}_list_view.dart';
import '../../../core/state_status/base_status.dart';

class ${ENTITY_CAMEL}PortraitView extends ConsumerWidget {
  const ${ENTITY_CAMEL}PortraitView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(${FEATURE_CAMEL}Provider);

    return Scaffold(
      appBar: AppBar(title: AppText.titleLargeBold("$ENTITY_CAMEL Name")),
      body: switch (state.status) {
        Loading() => const Center(child: CircularProgressIndicator()),
        Success() =>
          state.featureEntities.isEmpty
              ? const Center(child: Text("No items found"))
              : ${ENTITY_CAMEL}ListView(items: state.featureEntities),
        Failure(:final responseError) => Center(
          child: AppText.bodyMedium(responseError.toString()),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
EOF

# Landscape View
cat <<EOF > "$LANDSCAPE_VIEW_FILE"
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/text/app_text.dart';
import 'notifier/${FEATURE_SNAKE}_notifier.dart';
import 'components/${FEATURE_SNAKE}_list_view.dart';
import '../../../core/state_status/base_status.dart';

class ${ENTITY_CAMEL}LandScapeView extends ConsumerWidget {
  const ${ENTITY_CAMEL}LandScapeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(${FEATURE_CAMEL}Provider);

    return Scaffold(
      appBar: AppBar(title: AppText.titleLargeBold("$ENTITY_CAMEL Name")),
      body: switch (state.status) {
        Loading() => const Center(child: CircularProgressIndicator()),
        Success() =>
          state.featureEntities.isEmpty
              ? const Center(child: Text("No items found"))
              : ${ENTITY_CAMEL}ListView(items: state.featureEntities),
        Failure(:final responseError) => Center(
          child: AppText.bodyMedium(responseError.toString()),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
EOF


# ---------------------------
# ListView Component
# ---------------------------
cat <<EOF > "$LIST_VIEW_FILE"
import 'package:flutter/material.dart';
import '../../../../domain/entity/base/base_entity.dart';

class ${ENTITY_CAMEL}ListView extends StatelessWidget {
  final List<${ENTITY_CAMEL}Entity> items;
  const ${ENTITY_CAMEL}ListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text('ID: \${item.id}'),
        );
      },
    );
  }
}
EOF

# ---------------------------
# Run build_runner
# ---------------------------
echo "🔹 Running build_runner..."
if command -v flutter >/dev/null 2>&1; then
  flutter pub get
  flutter pub run build_runner build --delete-conflicting-outputs
else
  dart pub get
  dart run build_runner build --delete-conflicting-outputs
fi

# ---------------------------
# Format the generated files (heredoc line lengths vary with feature name
# length, so this keeps output consistent regardless of $FEATURE_NAME).
# ---------------------------
dart format lib/domain lib/data lib/presentation/screen/$FEATURE_SNAKE lib/core/injector/injected_providers.dart


# ---------------------------
# Add route to app_router.dart
# ---------------------------
APP_ROUTER_FILE="lib/presentation/route/app_router.dart"
ROUTE_LINE="AutoRoute(page: ${ENTITY_CAMEL}Route.page),"

# Insert before the closing bracket of the routes list (the first '];' seen
# after the `get routes => [` line). awk, not sed, for the same GNU/BSD
# portability reason as insert_before() above.
if ! grep -Fq "$ROUTE_LINE" "$APP_ROUTER_FILE"; then
  awk -v route="$ROUTE_LINE" '
    /List<AutoRoute> get routes => \[/ { in_routes = 1 }
    in_routes && !inserted && /\];/ { print "    " route; inserted = 1 }
    { print }
  ' "$APP_ROUTER_FILE" > "$APP_ROUTER_FILE.tmp.$$" && mv "$APP_ROUTER_FILE.tmp.$$" "$APP_ROUTER_FILE"
  echo "Added ${ENTITY_CAMEL}Screen route to app_router.dart"
fi


echo "🎉 Feature '$FEATURE_NAME' generated successfully!"
