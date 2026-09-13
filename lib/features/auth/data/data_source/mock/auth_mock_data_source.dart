import 'package:flutter_template/features/auth/data/data_source/auth_data_source.dart';
import 'package:flutter_template/features/auth/data/models/login_request_model.dart';

class AuthMockDataSource implements AuthDataSource {
  @override
  Future<String> login(LoginRequestModel inputModel) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (inputModel.email == 'test@gmail.com' && inputModel.pin == '1234') {
      return 'mock_token_123';
    }
    throw Exception('Invalid credentials');
  }
}
