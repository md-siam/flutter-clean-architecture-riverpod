import 'package:flutter_template/features/auth/data/data_source/auth_data_source.dart';
import 'package:flutter_template/features/user/data/data_source/user_data_source.dart';

/// The Abstract Factory interface.
/// It declares a set of methods for creating individual data sources.
abstract class DataSourceFactory {
  UserDataSource createUserDataSource();
  AuthDataSource createAuthDataSource();
}
