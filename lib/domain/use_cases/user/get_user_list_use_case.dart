import 'package:flutter_template/domain/entity/base/base_entity.dart';
import 'package:flutter_template/domain/repository/user/user_repository.dart';
import 'package:flutter_template/domain/use_cases/base/base_use_case.dart';

class GetUserListUseCase with BaseUseCase<List<UserEntity>> {
  GetUserListUseCase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<List<UserEntity>> execute() => _userRepository.getUserList();
}
