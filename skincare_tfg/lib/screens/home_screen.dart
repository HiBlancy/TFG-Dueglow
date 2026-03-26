// screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/bottom_app_bar.dart';
import '../widgets/main_toolbar.dart';
import '../constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  String _userName = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await _authService.getUserName();
    if (mounted) {
      setState(() {
        _userName = name ?? 'Usuario';
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Navegar según el índice
    switch (index) {
      case 0:
        // Ya estamos en Home
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppConstants.routeProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      child: CustomAppBar(
        title: AppConstants.appName,
        showDrawer: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¡Hola $_userName!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Has iniciado sesión correctamente.\nPróximamente conectaremos con una base de datos.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}