import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sked/viewmodels/home_viewmodel.dart';

import 'package:sked/services/navigation_service.dart';
import 'package:sked/utils/locator.dart';
import 'package:sked/utils/routes.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  setLocator();

  runApp(Grateful8App());
}

class Grateful8App extends StatefulWidget {
  @override
  _Grateful8AppState createState() => _Grateful8AppState();
}

class _Grateful8AppState extends State<Grateful8App> {
  Locale locale;
  bool localeLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeViewModel>(
      create: (_) => HomeViewModel(),
      child: Center(
        child: MaterialApp(
          initialRoute: '/',
          navigatorKey: locator<NavigationService>().navigatorKey,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: Routes.onGenerateRoute,
          theme: ThemeData(
            primaryColor: Colors.black,
            fontFamily: 'FA',
          ),
        ),
      ),
    );
  }
}
