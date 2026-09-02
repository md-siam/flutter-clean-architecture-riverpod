import 'package:flutter_template/shared/base/base_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getUserList();

  Future<UserEntity> getUserById({required String userId});
}
