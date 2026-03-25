import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
  String _userName = '';

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

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> _profile() async {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('MiAppName', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildDrawer() => Drawer(
        child: SafeArea(
          child: Column(
            children: [
              _buildDrawerHeader(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(Icons.home, 'Inicio', () => Navigator.pop(context), isSelected: true),
                    const Divider(),
                    _buildDrawerItem(Icons.person, 'Mi Perfil', _profile),
                    _buildDrawerItem(Icons.settings, 'Configuración', () => _navigateTo('settings')),
                    _buildDrawerItem(Icons.info, 'Acerca de', () => _navigateTo('about')),
                    const Divider(),
                    _buildDrawerItem(Icons.logout, 'Cerrar sesión', _logout, iconColor: Colors.red, textColor: Colors.red),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Versión 1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ),
            ],
          ),
        ),
      );

  Widget _buildDrawerHeader() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
            const SizedBox(height: 12),
            Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
          ],
        ),
      );

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color? iconColor, Color? textColor, bool isSelected = false}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      tileColor: isSelected ? Colors.grey.shade100 : null,
      onTap: onTap,
    );
  }

  Widget _buildBody() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('¡Hola $_userName!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text(
                'Has iniciado sesión correctamente.\nPróximamente conectaremos con una base de datos.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  void _navigateTo(String screen) {
    Navigator.pop(context);
    // Implementar navegación cuando sea necesario
  }
}