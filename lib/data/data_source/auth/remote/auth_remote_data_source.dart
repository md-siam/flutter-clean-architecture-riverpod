import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:flutter_template/data/data_source/auth/auth_data_source.dart';
import 'package:flutter_template/data/models/request_model/base/base_request.dart';

part 'auth_remote_data_source.g.dart';

@RestApi()
abstract class AuthRemoteDataSource implements AuthDataSource {
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;

  @override
  @POST('/login')
  Future<String> login(@Body() LoginRequestModel inputModel);
}
