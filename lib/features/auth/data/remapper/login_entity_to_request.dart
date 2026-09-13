import 'package:flutter_template/features/auth/data/models/login_request_model.dart';
import 'package:flutter_template/features/auth/domain/entity/login_entity.dart';

extension LoginEntityMapper on LoginEntity {
  /// Maps a LoginEntity to a LoginRequestModel
  LoginRequestModel toRequestModel() {
    return LoginRequestModel(email: email, pin: pin);
  }
}
