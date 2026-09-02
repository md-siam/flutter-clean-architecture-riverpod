import 'package:flutter_template/shared/base/base_request.dart';
import 'package:flutter_template/shared/base/base_entity.dart';

extension LoginEntityMapper on LoginEntity {
  /// Maps a LoginEntity to a LoginRequestModel
  LoginRequestModel toRequestModel() {
    return LoginRequestModel(email: email, pin: pin);
  }
}
