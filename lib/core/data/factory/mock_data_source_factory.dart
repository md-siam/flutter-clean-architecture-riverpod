import 'package:flutter_template/features/auth/data/data_source/auth_data_source.dart';
import 'package:flutter_template/features/auth/data/data_source/mock/auth_mock_data_source.dart';
import 'package:flutter_template/core/data/factory/data_source_factory.dart';
import 'package:flutter_template/features/user/data/data_source/mock/user_mock_data_source.dart';
import 'package:flutter_template/features/user/data/data_source/user_data_source.dart';

class MockDataSourceFactory implements DataSourceFactory {
  MockDataSourceFactory(this._userMock, this._authMock);

  final UserMockDataSource _userMock;
  final AuthMockDataSource _authMock;

  @override
  UserDataSource createUserDataSource() => _userMock;

  @override
  AuthDataSource createAuthDataSource() => _authMock;
}
