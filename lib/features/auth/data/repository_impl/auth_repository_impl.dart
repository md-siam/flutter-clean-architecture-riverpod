import 'package:flutter_template/core/helper/secure_storage_service.dart';
import 'package:flutter_template/core/data/factory/data_source_factory.dart';
import 'package:flutter_template/features/auth/data/remapper/login_entity_to_request.dart';
import 'package:flutter_template/features/auth/domain/entity/login_entity.dart';
import 'package:flutter_template/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  AuthRepositoryImpl(this._factory, this._secureStorage);

  final DataSourceFactory _factory;
  final SecureStorageService _secureStorage;

  @override
  Future<void> login({required LoginEntity inputModel}) async {
    ///TODO: Bypass login (remove this)
    /*  await _factory.createAuthDataSource().login(
        inputModel.toRequestModel(),
      );*/
    await _secureStorage.setAccessToken("token");
  }
}
