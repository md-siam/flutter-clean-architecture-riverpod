import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_template/core/error/response_error.dart';
import 'package:flutter_template/core/injector/injected_providers.dart';
import 'package:flutter_template/core/state_status/base_status.dart';
import 'package:flutter_template/shared/base/base_entity.dart';

part 'login_notifier.freezed.dart';
part 'login_notifier.g.dart';
part 'login_state.dart';

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  LoginState build() => const LoginState();

  Future<void> login(LoginEntity input) async {
    state = state.copyWith(loginStatus: const BaseStatus.loading());

    try {
      await ref.read(loginUseCaseProvider).execute(input);
      state = state.copyWith(
        loginStatus: const BaseStatus.success(),
        loginEntity: input,
      );
    } catch (e) {
      ref.read(loggerProvider).e(e);
      state = state.copyWith(
        loginStatus: BaseStatus.failure(ResponseError.from(e)),
      );
    }
  }
}
