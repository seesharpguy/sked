import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    print("navigating to $routeName");
    return navigatorKey.currentState
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  // Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
  //   return navigatorKey.currentState.pushNamedAndRemoveUntil(
  //       routeName, (Route<dynamic> route) => false,
  //       arguments: arguments);
  // }

  void goBack() {
    return navigatorKey.currentState.pop();
  }
}
