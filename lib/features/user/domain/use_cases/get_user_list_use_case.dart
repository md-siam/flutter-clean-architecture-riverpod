import 'package:flutter_template/shared/base/base_entity.dart';
import 'package:flutter_template/features/user/domain/repository/user_repository.dart';
import 'package:flutter_template/core/use_case/base_use_case.dart';

class GetUserListUseCase with BaseUseCase<List<UserEntity>> {
  GetUserListUseCase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<List<UserEntity>> execute() => _userRepository.getUserList();
}
