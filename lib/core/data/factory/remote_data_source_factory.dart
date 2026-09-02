import 'package:flutter_template/features/auth/data/data_source/auth_data_source.dart';
import 'package:flutter_template/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flutter_template/core/data/factory/data_source_factory.dart';
import 'package:flutter_template/features/user/data/data_source/remote/user_remote_data_source.dart';
import 'package:flutter_template/features/user/data/data_source/user_data_source.dart';

class RemoteDataSourceFactory implements DataSourceFactory {
  RemoteDataSourceFactory(this._userRemote, this._authRemote);

  final UserRemoteDataSource _userRemote;
  final AuthRemoteDataSource _authRemote;

  @override
  UserDataSource createUserDataSource() => _userRemote;

  @override
  AuthDataSource createAuthDataSource() => _authRemote;
}
