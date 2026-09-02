import 'package:flutter_template/features/auth/data/models/login_request_model.dart';

abstract class AuthDataSource {
  Future<String> login(LoginRequestModel inputModel);
}
