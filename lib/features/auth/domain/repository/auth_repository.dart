import 'package:flutter_template/features/auth/domain/entity/login_entity.dart';

abstract class AuthRepository {
  Future<void> login({required LoginEntity inputModel});
}
