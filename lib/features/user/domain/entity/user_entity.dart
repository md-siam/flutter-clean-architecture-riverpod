import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

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
