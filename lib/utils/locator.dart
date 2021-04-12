import 'package:sked/viewmodels/home_viewmodel.dart';
import 'package:sked/viewmodels/signin_viewmodel.dart';
import 'package:sked/services/navigation_service.dart';
import 'package:sked/services/authentication_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setLocator() {
  locator.registerLazySingleton(() => SignInViewModel());
  locator.registerLazySingleton(() => HomeViewModel());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => AuthenticationService());
}
