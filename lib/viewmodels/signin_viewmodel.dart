import 'package:flutter/material.dart';
import 'package:sked/base/base_model.dart';
import 'package:sked/services/authentication_service.dart';
import 'package:sked/utils/view_state.dart';
import 'package:sked/services/navigation_service.dart';
import 'package:sked/utils/routeNames.dart';
import 'package:sked/utils/locator.dart';

class SignInViewModel extends BaseModel {
  final AuthenticationService _auth = locator<AuthenticationService>();
  final NavigationService _navigationService = locator<NavigationService>();

  bool _userLoginAutoValidate = false;

  TextEditingController _passwordController = TextEditingController();

  TextEditingController _userIdController = TextEditingController();

  bool _passwordVisible = false;

  bool get passwordVisible => _passwordVisible;

  set passwordVisible(bool value) {
    _passwordVisible = value;
    notifyListeners();
  }

  TextEditingController get userIdController => _userIdController;

  set userIdController(TextEditingController value) {
    _userIdController = value;
    notifyListeners();
  }

  TextEditingController get passwordController => _passwordController;

  set passwordController(TextEditingController value) {
    _passwordController = value;
    notifyListeners();
  }

  bool get userLoginAutoValidate => _userLoginAutoValidate;
  set userLoginAutoValidate(bool value) {
    _userLoginAutoValidate = value;
    notifyListeners();
  }

  void loginWithGoogle() async {
    state = ViewState.Busy;
    try {
      await _auth.signInWithGoogle();
      state = ViewState.Idle;
      clearAllModels();
      _navigationService.navigateTo(RouteName.Home);
    } catch (e) {
      throw e;
    }
  }

  void loginAnonomously() async {
    state = ViewState.Busy;
    try {
      await _auth.signInAnonomously();
      state = ViewState.Idle;
      clearAllModels();
      _navigationService.navigateTo(RouteName.Home);
    } catch (e) {
      throw e;
    }
  }

  clearAllModels() {
    _userLoginAutoValidate = false;
    _passwordController = TextEditingController();
    _userIdController = TextEditingController();
    _passwordVisible = false;
  }
}
