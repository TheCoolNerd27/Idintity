import 'package:get_it/get_it.dart';
import 'package:idintity/auth_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

GetIt locator = GetIt.instance;
final FirebaseAnalytics analytics = FirebaseAnalytics();

void setupLocator() {

    locator.registerLazySingleton(() => AuthenticationService());



}