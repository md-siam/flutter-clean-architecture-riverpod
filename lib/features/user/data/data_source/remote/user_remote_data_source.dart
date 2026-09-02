part of 'package:flutter_template/shared/base/base_data_source.dart';

@RestApi()
abstract class UserRemoteDataSource implements UserDataSource {
  factory UserRemoteDataSource(Dio dio) = _UserRemoteDataSource;

  @override
  @GET('/users')
  Future<List<UserResponseModel>> getUserList();

  @override
  @GET('/users/{id}')
  Future<UserResponseModel> getUserById({@Path('id') required String userId});
}
