import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:flutter_template/data/data_source/user/user_data_source.dart';
import 'package:flutter_template/data/models/response_model/base/base_response.dart';

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
