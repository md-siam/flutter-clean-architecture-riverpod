part of 'package:flutter_template/shared/base/base_data_source.dart';

@RestApi()
abstract class AuthRemoteDataSource implements AuthDataSource {
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;

  @override
  @POST('/login')
  Future<String> login(@Body() LoginRequestModel inputModel);
}
