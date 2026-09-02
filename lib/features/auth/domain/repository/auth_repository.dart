import 'package:flutter_template/shared/base/base_entity.dart';

abstract class AuthRepository {
  Future<void> login({required LoginEntity inputModel});
}
