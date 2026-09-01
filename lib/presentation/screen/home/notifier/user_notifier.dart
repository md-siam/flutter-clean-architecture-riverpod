import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_template/core/error/response_error.dart';
import 'package:flutter_template/core/injector/injected_providers.dart';
import 'package:flutter_template/core/state_status/base_status.dart';
import 'package:flutter_template/domain/exceptions/subscription_required_exception.dart';
import 'user_state.dart';

part 'user_notifier.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  UserState build() {
    final isSubscribed = ref
        .watch(getSubscriptionStatusUseCaseProvider)
        .execute();
    return UserState(isSubscribed: isSubscribed);
  }

  Future<void> getUserList() async {
    try {
      state = state.copyWith(
        status: const BaseStatus.loading(),
        isSubscriptionRequired: false,
      );
      final userList = await ref.read(getUserListUseCaseProvider).execute();
      state = state.copyWith(
        userList: userList,
        status: const BaseStatus.success(),
      );
    } on SubscriptionRequiredException {
      state = state.copyWith(
        status: const BaseStatus.initial(),
        isSubscriptionRequired: true,
      );
    } catch (e) {
      ref.read(loggerProvider).e(e);
      state = state.copyWith(status: BaseStatus.failure(ResponseError.from(e)));
    }
  }

  Future<void> toggleSubscription(bool value) async {
    await ref.read(setSubscriptionStatusUseCaseProvider).execute(value);
    state = state.copyWith(isSubscribed: value);
  }

  Future<void> subscribeAndRefresh() async {
    await toggleSubscription(true);
    await getUserList();
  }
}
