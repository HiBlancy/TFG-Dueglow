import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      // Configuración de rutas para navegación profesional
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}