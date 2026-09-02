import 'package:flutter_template/core/data/factory/data_source_factory.dart';
import 'package:flutter_template/features/user/data/data_source/user_data_source.dart';
import 'package:flutter_template/features/user/data/remapper/user_response_to_entity.dart';
import 'package:flutter_template/shared/base/base_entity.dart';
import 'package:flutter_template/features/user/domain/repository/user_repository.dart';

class UserRepositoryImpl extends UserRepository {
  UserRepositoryImpl(DataSourceFactory factory)
    : _userDataSource = factory.createUserDataSource();

  final UserDataSource _userDataSource;

  @override
  Future<List<UserEntity>> getUserList() async {
    final response = await _userDataSource.getUserList();
    return response.toUserEntities();
  }

  @override
  Future<UserEntity> getUserById({required String userId}) async {
    final response = await _userDataSource.getUserById(userId: userId);
    return response.toUserEntity();
  }
}
