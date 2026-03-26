// screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/bottom_app_bar.dart';
import '../widgets/main_toolbar.dart';
import '../constants/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  String _userName = '';
  String _userEmail = '';
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await _authService.getUserName();
    final email = await _authService.getUserEmail();
    if (mounted) {
      setState(() {
        _userName = name ?? 'Usuario';
        _userEmail = email ?? 'usuario@ejemplo.com';
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppConstants.routeHome);
        break;
      case 1:
        // Ya estamos en Profile
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      child: CustomAppBar(
        title: 'Mi Perfil',
        showDrawer: true,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 70, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                _userName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _userEmail,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.email, 'Correo electrónico', _userEmail),
                      const Divider(),
                      _buildInfoRow(Icons.phone, 'Teléfono', '+34 123 456 789'),
                      const Divider(),
                      _buildInfoRow(Icons.cake, 'Fecha de nacimiento', '01/01/1990'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}