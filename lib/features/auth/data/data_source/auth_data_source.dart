import 'package:flutter_template/shared/base/base_request.dart';

abstract class AuthDataSource {
  Future<String> login(LoginRequestModel inputModel);
}
