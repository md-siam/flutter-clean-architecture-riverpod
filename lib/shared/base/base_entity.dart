import 'package:freezed_annotation/freezed_annotation.dart';

// Every feature's domain entity is `part of` this file, so freezed emits a
// single base_entity.freezed.dart here instead of one generated file per
// feature. Add your new feature's entity path below.
part 'package:flutter_template/features/auth/domain/entity/login_entity.dart';
part 'package:flutter_template/features/user/domain/entity/user_entity.dart';

part 'base_entity.freezed.dart';
