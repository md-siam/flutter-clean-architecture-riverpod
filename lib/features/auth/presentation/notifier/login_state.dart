part of 'login_notifier.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState({
    @Default(BaseStatus.initial()) BaseStatus loginStatus,
    LoginEntity? loginEntity,
  }) = _LoginState;
}
