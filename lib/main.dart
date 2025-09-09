import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await Prefs.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PGI Connect',
        theme: ThemeData(
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 2,
            ),
            cardTheme: const CardThemeData(
                elevation: 1,
                surfaceTintColor: Colors.white,
                color: Colors.white)),
        home: SplashScreen());
  }
}
