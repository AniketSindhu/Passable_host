import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:passable_host/config/config.dart';
import 'HomePage.dart';
import 'loginui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool login=prefs.getBool('login');
  await FlutterConfig.loadEnvVariables();
  runApp(login==null?MyApp1():login?MyApp():MyApp1());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pass-it-on',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        accentColor: AppColors.secondary,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      routes: {
        'login':(context)=>Login(),
        'homepage':(context)=>HomePage()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyApp1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pass-it-on',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        accentColor: AppColors.secondary,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Login(),
      routes: {
        'login':(context)=>Login(),
        'homepage':(context)=>HomePage()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

