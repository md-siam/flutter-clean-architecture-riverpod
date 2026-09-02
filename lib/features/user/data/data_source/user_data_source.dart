import 'package:flutter_template/features/user/data/models/user_response_model.dart';

abstract class UserDataSource {
  Future<List<UserResponseModel>> getUserList();
  Future<UserResponseModel> getUserById({required String userId});
}
