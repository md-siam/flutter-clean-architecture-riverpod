import 'package:flutter_template/shared/base/base_response.dart';

abstract class UserDataSource {
  Future<List<UserResponseModel>> getUserList();
  Future<UserResponseModel> getUserById({required String userId});
}
