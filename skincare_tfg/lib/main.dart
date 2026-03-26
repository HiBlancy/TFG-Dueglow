// main.dart
import 'package:flutter/material.dart';
import 'package:skincare_tfg/screens/about_screen.dart';
import 'package:skincare_tfg/screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'constants/app_constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      initialRoute: AppConstants.routeLogin,
      routes: {
        AppConstants.routeLogin: (context) => const LoginScreen(),
        AppConstants.routeHome: (context) => const HomeScreen(),
        AppConstants.routeRegister: (context) => const RegisterScreen(),
        AppConstants.routeProfile: (context) => const ProfileScreen(),
        AppConstants.routeSettings: (context) => const SettingsScreen(),
        AppConstants.routeAbout: (context) => const AboutScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}