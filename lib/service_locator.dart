import 'package:get_it/get_it.dart';
import 'package:idintity/auth_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {

    locator.registerLazySingleton(() => AuthenticationService());

}