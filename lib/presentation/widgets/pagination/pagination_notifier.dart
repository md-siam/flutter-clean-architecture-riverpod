import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/core/error/response_error.dart';
import 'package:flutter_template/core/state_status/base_status.dart';
import 'package:flutter_template/presentation/widgets/pagination/pagination_list.dart';
import 'package:flutter_template/presentation/widgets/pagination/pagination_state.dart';

/// Base [Notifier] for paginated lists. Subclass it, implement [fetchData],
/// and expose a concrete provider for it, e.g.:
///
/// ```dart
/// class UserPaginationNotifier extends PaginationNotifier<UserEntity, UserQuery> {
///   UserPaginationNotifier() : super(const UserQuery());
///
///   @override
///   Future<List<UserEntity>> fetchData({required int limit, required int offset}) {
///     ...
///   }
/// }
///
/// final userPaginationProvider = NotifierProvider.autoDispose<
///     UserPaginationNotifier, PaginationState<UserEntity, UserQuery>>(
///   UserPaginationNotifier.new,
/// );
/// ```
abstract class PaginationNotifier<T, P>
    extends Notifier<PaginationState<T, P>> {
  PaginationNotifier(this.initialParams);

  final P initialParams;

  P get params => state.params;

  bool _isRequestActive = false;

  @override
  PaginationState<T, P> build() => PaginationState<T, P>(
    pagination: PaginationList<T>.empty(),
    params: initialParams,
    status: const BaseStatus.initial(),
  );

  Future<List<T>> fetchData({required int limit, required int offset});

  Future<void> fetch() => _fetch(isRefresh: false);

  Future<void> refresh() => _fetch(isRefresh: true);

  void setParams(P params, {bool refresh = true}) {
    state = state.copyWith(params: params);
    if (refresh) this.refresh();
  }

  void patchParams(P Function(P current) updater, {bool refresh = true}) {
    setParams(updater(state.params), refresh: refresh);
  }

  void reset() {
    state = PaginationState<T, P>(
      pagination: PaginationList<T>.empty(),
      params: initialParams,
      status: const BaseStatus.initial(),
    );
  }

  Future<void> _fetch({required bool isRefresh}) async {
    final pagination = state.pagination;

    if (_isRequestActive) return;

    if (!isRefresh && (pagination.isLoadingMore || !pagination.hasMore)) {
      return;
    }

    _isRequestActive = true;

    final offset = isRefresh ? 0 : pagination.items.length;

    state = state.copyWith(
      status: isRefresh ? const BaseStatus.loading() : state.status,
      pagination: pagination.copyWith(isLoadingMore: !isRefresh),
    );

    try {
      final result = await fetchData(limit: pagination.limit, offset: offset);
      if (!ref.mounted) return;

      final updatedItems = isRefresh
          ? result
          : [...pagination.items, ...result];

      state = state.copyWith(
        pagination: pagination.copyWith(
          items: updatedItems,
          offset: updatedItems.length,
          hasMore: result.length >= pagination.limit,
          isLoadingMore: false,
        ),
        status: const BaseStatus.success(),
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        status: BaseStatus.failure(ResponseError.from(e)),
        pagination: pagination.copyWith(isLoadingMore: false),
      );
    } finally {
      _isRequestActive = false;
    }
  }
}
