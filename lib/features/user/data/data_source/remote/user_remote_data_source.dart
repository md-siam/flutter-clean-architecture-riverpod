import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:flutter_template/features/user/data/data_source/user_data_source.dart';
import 'package:flutter_template/shared/base/base_response.dart';

part 'user_remote_data_source.g.dart';

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
