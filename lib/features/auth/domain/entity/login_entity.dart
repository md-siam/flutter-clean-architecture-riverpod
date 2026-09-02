part of 'package:flutter_template/shared/base/base_entity.dart';

@freezed
abstract class LoginEntity with _$LoginEntity {
  const factory LoginEntity({required String email, required String pin}) =
      _LoginEntity;
}
